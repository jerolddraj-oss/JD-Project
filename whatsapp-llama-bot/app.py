"""
Project: WhatsApp Messaging App using LangChain + LangGraph
Author: Jivi (for JD)
Runtime: Python 3.10+

What you get in this single file:
- A FastAPI app exposing:
  • GET  /webhook    -> webhook verification (Meta)
  • POST /webhook    -> receives WhatsApp Cloud API callbacks
  • POST /send       -> sends an outbound WhatsApp message (text)
  • POST /send-template -> sends an approved template message
- A LangGraph workflow to process inbound messages (classify -> respond -> send)
- A thin WhatsApp client for Meta's Cloud API

———————————
Quick Start
———————————
1) Create a WhatsApp Cloud API app in Meta for Developers and note:
   • WHATSAPP_TOKEN           = permanent/long-lived access token
   • WHATSAPP_PHONE_NUMBER_ID = Phone Number ID (from WhatsApp > API Setup)
   • WHATSAPP_VERIFY_TOKEN    = a secret string you choose for webhook verification

2) Create .env with these vars:

   WHATSAPP_TOKEN="EAAG..."
   WHATSAPP_PHONE_NUMBER_ID="1234567890"
   WHATSAPP_VERIFY_TOKEN="super-secret"
   META_GRAPH_VERSION="v20.0"

   # Choose ONE provider below
   # Groq (hosted Llama)
   MODEL_PROVIDER="groq"
   LLAMA_MODEL="llama-3.1-8b-instant"   # or llama-3.1-70b-versatile
   GROQ_API_KEY="grq_..."

   # OR Ollama (local Llama)
   # MODEL_PROVIDER="ollama"
   # OLLAMA_BASE_URL="http://localhost:11434"  # optional
   # (Make sure to `ollama pull llama3.1:8b`)

3) Install dependencies:
   pip install fastapi uvicorn pydantic requests python-dotenv langchain langgraph networkx
   # If using Groq:
   pip install langchain-groq
   # If using Ollama:
   pip install langchain-community

4) Run locally:
   uvicorn app:app --reload --port 8080

5) Expose localhost to the internet for webhook testing (e.g., ngrok http 8080)
   Set Webhook URL in Meta: https://<public-url>/webhook
   Verify Token: the same string as WHATSAPP_VERIFY_TOKEN

Notes:
- This example sends plain text messages. For templates/media/interactive types, extend WhatsAppClient.send_message() or use /send-template.
- Within 24h of the last user message, you can send freeform text (session). Outside 24h, you must use an approved template.
- Follow WhatsApp Business Platform policies.
"""

# app.py

from __future__ import annotations
import os
import re
import json
import hmac
import hashlib
import asyncio
from typing import Any, Dict, Optional, TypedDict, Literal

import requests
from fastapi import FastAPI, Request, HTTPException, Response, Header, BackgroundTasks
from pydantic import BaseModel
from dotenv import load_dotenv
from fastapi.staticfiles import StaticFiles
from dashboard.routes import router as dashboard_router


# LangGraph / LangChain imports are optional — we handle missing libs gracefully
try:
    from langchain.prompts import ChatPromptTemplate
except Exception:
    ChatPromptTemplate = None

try:
    from langchain_groq import ChatGroq  # pip install langchain-groq
except Exception:
    ChatGroq = None

try:
    from langchain_community.chat_models import ChatOllama  # pip install langchain-community
except Exception:
    ChatOllama = None

# LangGraph (state graph) — optional; if not available we use simple sequential calls
try:
    from langgraph.graph import StateGraph, END
except Exception:
    StateGraph = None
    END = None

load_dotenv()

# -----------------------
# Config
# -----------------------
META_GRAPH_VERSION = os.getenv("META_GRAPH_VERSION", "v20.0")
WHATSAPP_TOKEN = os.getenv("WHATSAPP_TOKEN")
WHATSAPP_PHONE_NUMBER_ID = os.getenv("WHATSAPP_PHONE_NUMBER_ID")
WHATSAPP_VERIFY_TOKEN = os.getenv("WHATSAPP_VERIFY_TOKEN", "super-secret")
FACEBOOK_APP_SECRET = os.getenv("FACEBOOK_APP_SECRET")  # optional, for verifying signature header

MODEL_PROVIDER = os.getenv("MODEL_PROVIDER", "groq").lower()
LLAMA_MODEL = os.getenv("LLAMA_MODEL", "llama-3.1-8b-instant")
GROQ_API_KEY = os.getenv("GROQ_API_KEY")
OLLAMA_BASE_URL = os.getenv("OLLAMA_BASE_URL", "http://localhost:11434")

if not WHATSAPP_TOKEN or not WHATSAPP_PHONE_NUMBER_ID:
    print("[WARN] WHATSAPP_TOKEN or WHATSAPP_PHONE_NUMBER_ID is not configured. Outbound won't work until configured.")

# -----------------------
# WhatsApp client (sync) - we will call it from background thread
# -----------------------
class WhatsAppClient:
    def __init__(self, phone_number_id: str, token: str, graph_version: str = META_GRAPH_VERSION):
        self.base_url = f"https://graph.facebook.com/{graph_version}/{phone_number_id}"
        self.token = token

    def send_message(self, to: str, text: str, preview_url: bool = False) -> Dict[str, Any]:
        url = f"{self.base_url}/messages"
        headers = {
            "Authorization": f"Bearer {self.token}",
            "Content-Type": "application/json",
        }
        payload = {
            "messaging_product": "whatsapp",
            "recipient_type": "individual",
            "to": to,
            "type": "text",
            "text": {"body": text, "preview_url": preview_url},
        }
        r = requests.post(url, headers=headers, json=payload, timeout=30)
        try:
            r.raise_for_status()
        except Exception as e:
            # return the response text for debugging
            raise RuntimeError(f"WhatsApp API error {r.status_code}: {r.text}") from e
        return r.json()

wa_client = WhatsAppClient(WHATSAPP_PHONE_NUMBER_ID or "", WHATSAPP_TOKEN or "")

# -----------------------
# Minimal LLM wrapper: tries to use ChatGroq/ChatOllama if present,
# otherwise falls back to a simple rule-based classifier/response.
# We expose an `invoke(messages_or_prompt)` method that returns an object with `.content` text.
# -----------------------
class LLMResponse:
    def __init__(self, content: str):
        self.content = content

class LLMWrapper:
    def __init__(self):
        self.provider = MODEL_PROVIDER
        # If using Groq we could pass API key via environment; ChatGroq usage depends on lib version
        if self.provider == "groq" and ChatGroq is not None:
            try:
                # ChatGroq signature may differ depending on package version — we construct a client here.
                self.client = ChatGroq(model=LLAMA_MODEL, temperature=0.4)
                print("[INFO] Using ChatGroq LLM client.")
            except Exception as e:
                print("[WARN] Failed to initialize ChatGroq:", e)
                self.client = None
        elif self.provider == "ollama" and ChatOllama is not None:
            try:
                self.client = ChatOllama(model=os.getenv("OLLAMA_MODEL", "llama3.1:8b"), base_url=OLLAMA_BASE_URL, temperature=0.4)
                print("[INFO] Using Ollama LLM client.")
            except Exception as e:
                print("[WARN] Failed to initialize ChatOllama:", e)
                self.client = None
        else:
            self.client = None
            if self.provider not in {"groq", "ollama"}:
                print(f"[WARN] Unknown MODEL_PROVIDER={self.provider}; falling back to rule-based responder.")
            else:
                print("[WARN] LLM provider requested but library not installed; falling back to rule-based responder.")

    def invoke(self, prompt_input: Any) -> LLMResponse:
        """
        Accept either a prepared prompt object (e.g., messages) or a simple str.
        We'll attempt to call the underlying client if available; otherwise use rules.
        """
        # If we have a client, try to call it in a way that is as generic as possible.
        if self.client is not None:
            try:
                # Many chat models accept a single string or messages structure; try a couple of common patterns.
                # We keep this generic — if a specific project uses ChatGroq/ChatOllama, adapt here.
                if hasattr(self.client, "chat"):  # hypothetical API
                    out = self.client.chat(prompt_input)
                    text = getattr(out, "content", str(out))
                    return LLMResponse(str(text))
                if hasattr(self.client, "generate"):
                    out = self.client.generate(prompt_input)
                    # out may be complex; try to extract text
                    if isinstance(out, str):
                        return LLMResponse(out)
                    if hasattr(out, "generations"):
                        # langchain-like
                        try:
                            text = out.generations[0][0].text
                            return LLMResponse(text)
                        except Exception:
                            pass
                    return LLMResponse(str(out))
                # Try generic call
                out = self.client(prompt_input)
                return LLMResponse(getattr(out, "content", str(out)))
            except Exception as e:
                print("[WARN] LLM client invocation failed; falling back to rule-based. Error:", e)

        # Fallback rule-based behavior
        text = ""
        if isinstance(prompt_input, str):
            msg = prompt_input
        elif isinstance(prompt_input, dict):
            # if passed as a single dict with 'msg' key
            msg = prompt_input.get("msg") or str(prompt_input)
        else:
            msg = str(prompt_input)

        msg_lower = (msg or "").strip().lower()
        # simple classification rules
        if any(g in msg_lower for g in ("hi", "hello", "hey", "good morning", "good evening")):
            text = "Hello! How can I help you today?"
        elif "help" in msg_lower or "book" in msg_lower or "pickup" in msg_lower:
            text = "I can help you book a pickup. What date and time works for you?"
        else:
            text = "Sorry, I didn't understand. Can you please rephrase?"

        return LLMResponse(text)

llm = LLMWrapper()

# -----------------------
# LangGraph-like workflow: if langgraph is installed, use it; otherwise use simple sequence
# -----------------------
class ChatState(TypedDict, total=False):
    user_number: str
    user_text: str
    intent: Literal["greeting", "help", "fallback"]
    reply_text: str

# Basic prompts (used only if langchain ChatPromptTemplate is available or for readability)
if ChatPromptTemplate is not None:
    intent_prompt = ChatPromptTemplate.from_messages([
        ("system", "You classify the user's intent. Return one of: greeting, help, fallback."),
        ("human", "User message: {msg}\nAnswer with only the label."),
    ])
    reply_prompt = ChatPromptTemplate.from_messages([
        ("system", "You are a concise assistant for business messaging."),
        ("human", "User ({user_number}) said: {msg}.\nReply concisely."),
    ])
else:
    intent_prompt = None
    reply_prompt = None

def classify_intent(state: ChatState) -> ChatState:
    msg = state.get("user_text", "") or ""
    # Try LLM classify; fallback to rules
    try:
        if intent_prompt and hasattr(llm, "invoke"):
            # send lightweight input
            label = llm.invoke({"msg": msg}).content.strip().lower()
        else:
            # rule-based
            if any(x in msg.lower() for x in ("hi", "hello", "hey")):
                label = "greeting"
            elif any(x in msg.lower() for x in ("book", "pickup", "help", "schedule")):
                label = "help"
            else:
                label = "fallback"
    except Exception as e:
        print("[WARN] classify_intent failed:", e)
        label = "fallback"
    if label not in {"greeting", "help", "fallback"}:
        label = "fallback"
    state["intent"] = label
    return state

def draft_reply(state: ChatState) -> ChatState:
    msg = state.get("user_text", "") or ""
    user = state.get("user_number", "")
    try:
        out = llm.invoke({"msg": msg, "user_number": user}).content.strip()
    except Exception as e:
        print("[WARN] draft_reply LLM failed:", e)
        out = "Sorry — I'm having trouble. Please try again shortly."
    state["reply_text"] = out
    return state

def send_whatsapp_sync(state: ChatState) -> ChatState:
    # Synchronous send (for background thread)
    to = re.sub(r"\D", "", state.get("user_number", ""))
    text = state.get("reply_text", "")
    if not to or not text:
        print("[WARN] send_whatsapp_sync missing to/text")
        return state
    if WHATSAPP_TOKEN and WHATSAPP_PHONE_NUMBER_ID:
        try:
            resp = wa_client.send_message(to=to, text=text)
            print(f"[INFO] Replied to {to}: {text[:80]}... resp={resp}")
        except Exception as e:
            print(f"[ERROR] send_whatsapp failed: {e}")
    else:
        print(f"[DRY-RUN] Would send to {to}: {text}")
    return state

# If langgraph is present, compile a graph; otherwise we will run the 3-step pipeline directly
if StateGraph is not None:
    workflow = StateGraph(ChatState)
    workflow.add_node("classify", classify_intent)
    workflow.add_node("reply", draft_reply)
    workflow.add_node("send", send_whatsapp_sync)
    workflow.set_entry_point("classify")
    workflow.add_edge("classify", "reply")
    workflow.add_edge("reply", "send")
    workflow.add_edge("send", END)
    compiled_graph = workflow.compile()
else:
    compiled_graph = None

# -----------------------
# FastAPI app and endpoints
# -----------------------
app = FastAPI(title="WhatsApp LangGraph Bot")
app.mount("/dashboard/static", StaticFiles(directory="dashboard/static"), name="dashboard_static")
app.include_router(dashboard_router)


@app.get("/")
async def root():
    return {
        "ok": True,
        "app": "WhatsApp LangGraph Bot",
        "model_provider": MODEL_PROVIDER,
        "llama_model": LLAMA_MODEL
    }

# Request models
class SendRequest(BaseModel):
    to: str
    text: str
    preview_url: Optional[bool] = False

class TemplateRequest(BaseModel):
    to: str
    name: str
    language: str = "en_US"
    components: Optional[list] = None

# Helper: verify X-Hub-Signature-256 if FACEBOOK_APP_SECRET set
def verify_signature(raw_body: bytes, signature_header: Optional[str]) -> bool:
    if not FACEBOOK_APP_SECRET:
        return True  # not configured
    if not signature_header:
        print("[WARN] Missing X-Hub-Signature-256 header")
        return False
    computed = "sha256=" + hmac.new(FACEBOOK_APP_SECRET.encode("utf-8"), msg=raw_body, digestmod=hashlib.sha256).hexdigest()
    return hmac.compare_digest(computed, signature_header)

# Webhook GET verification; Meta may send hub.* params
@app.get("/webhook")
async def webhook_verify(req: Request):
    q = dict(req.query_params)
    print("[WEBHOOK VERIFY] query_params:", q)
    mode = q.get("hub.mode") or q.get("mode")
    token = q.get("hub.verify_token") or q.get("verify_token") or q.get("hub.verify_token")
    challenge = q.get("hub.challenge") or q.get("challenge")
    if mode == "subscribe" and token == WHATSAPP_VERIFY_TOKEN and challenge is not None:
        # Return raw challenge (string)
        return Response(content=str(challenge), media_type="text/plain")
    raise HTTPException(status_code=403, detail="Verification failed")

# POST webhook: process inbound messages
@app.post("/webhook")
async def receive_webhook(req: Request, x_hub_signature_256: Optional[str] = Header(None), background_tasks: BackgroundTasks = None):
    raw = await req.body()
    # verify signature if configured
    if not verify_signature(raw, x_hub_signature_256):
        raise HTTPException(status_code=401, detail="Invalid signature")
    try:
        body = json.loads(raw.decode("utf-8") or "{}")
    except Exception:
        body = {}
    # quick debug print
    print("[WEBHOOK] incoming payload (truncated):", json.dumps(body)[:2000])

    try:
        entries = body.get("entry", [])
        # there may be multiple entries/changes; iterate them
        for entry in entries:
            changes = entry.get("changes", []) or []
            for change in changes:
                value = change.get("value", {}) or {}
                messages = value.get("messages") or []
                for msg in messages:
                    from_num = msg.get("from")
                    msg_type = msg.get("type")
                    if msg_type == "text":
                        user_text = msg.get("text", {}).get("body", "")
                    elif msg_type == "interactive":
                        user_text = (
                            msg.get("interactive", {}).get("button_reply", {}).get("title") or
                            msg.get("interactive", {}).get("list_reply", {}).get("title") or
                            ""
                        )
                    else:
                        user_text = f"[Unsupported {msg_type}]"
                    state: ChatState = {"user_number": from_num, "user_text": user_text}
                    # Run the pipeline in background to keep webhook quick
                    loop = asyncio.get_running_loop()
                    if compiled_graph is not None:
                        # langgraph compiled_graph.invoke may be blocking -> run in executor
                        loop.run_in_executor(None, compiled_graph.invoke, state)
                    else:
                        # run our simple pipeline in background thread
                        loop.run_in_executor(None, lambda s=state: send_whatsapp_sync(draft_reply(classify_intent(s))))
    except Exception as e:
        print(f"[ERROR] Webhook handling failed: {e}\nPayload: {json.dumps(body)[:1000]}")

    return {"received": True}

# Outbound send (runs sync send in background thread via run_in_executor)
@app.post("/send")
async def send_message(req: SendRequest):
    if not (WHATSAPP_TOKEN and WHATSAPP_PHONE_NUMBER_ID):
        raise HTTPException(status_code=500, detail="WhatsApp credentials not configured")
    to = re.sub(r"\D", "", req.to)
    text = req.text
    loop = asyncio.get_running_loop()
    try:
        result = await loop.run_in_executor(None, wa_client.send_message, to, text, bool(req.preview_url))
        return {"sent": True, "response": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Template send
@app.post("/send-template")
async def send_template(req: TemplateRequest):
    if not (WHATSAPP_TOKEN and WHATSAPP_PHONE_NUMBER_ID):
        raise HTTPException(status_code=500, detail="WhatsApp credentials not configured")
    url = f"https://graph.facebook.com/{META_GRAPH_VERSION}/{WHATSAPP_PHONE_NUMBER_ID}/messages"
    headers = {"Authorization": f"Bearer {WHATSAPP_TOKEN}", "Content-Type": "application/json"}
    payload = {
        "messaging_product": "whatsapp",
        "to": req.to,
        "type": "template",
        "template": {
            "name": req.name,
            "language": {"code": req.language},
            **({"components": req.components} if req.components else {}),
        },
    }
    r = requests.post(url, headers=headers, json=payload, timeout=30)
    if r.status_code >= 300:
        raise HTTPException(status_code=500, detail=r.text)
    return {"sent": True, "response": r.json()}

