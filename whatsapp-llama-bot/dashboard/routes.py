from fastapi import APIRouter, Request, Form, HTTPException
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from pathlib import Path
from starlette.testclient import TestClient
import json, os
import requests


router = APIRouter()
BASE_DIR = Path(__file__).resolve().parent
templates = Jinja2Templates(directory=str(BASE_DIR / "templates"))

DATA_DIR = Path("data")
DATA_DIR.mkdir(exist_ok=True)
MESSAGES_FILE = DATA_DIR / "messages.json"

if not MESSAGES_FILE.exists():
    MESSAGES_FILE.write_text("[]")

def load_messages():
    try:
        return json.loads(MESSAGES_FILE.read_text())
    except Exception:
        return []

def save_message(obj: dict):
    msgs = load_messages()
    msgs.insert(0, obj)
    msgs = msgs[:1000]
    MESSAGES_FILE.write_text(json.dumps(msgs, indent=2))

@router.get("/dashboard", response_class=HTMLResponse)
async def dashboard_index(request: Request):
    messages = load_messages()[:20]
    return templates.TemplateResponse("index.html", {"request": request, "messages": messages})

@router.get("/dashboard/send", response_class=HTMLResponse)
async def send_get(request: Request):
    return templates.TemplateResponse("send.html", {"request": request})

@router.post("/dashboard/send")
async def send_post(request: Request, to: str = Form(...), text: str = Form(...), preview_url: bool = Form(False)):
    """
    Send message directly to WhatsApp Cloud API (avoids TestClient and circular imports).
    Stores the outbound message entry in data/messages.json for the dashboard view.
    """
    # read config from env
    META_GRAPH_VERSION = os.getenv("META_GRAPH_VERSION", "v20.0")
    WHATSAPP_TOKEN = os.getenv("WHATSAPP_TOKEN")
    WHATSAPP_PHONE_NUMBER_ID = os.getenv("WHATSAPP_PHONE_NUMBER_ID")

    if not WHATSAPP_TOKEN or not WHATSAPP_PHONE_NUMBER_ID:
        raise HTTPException(status_code=500, detail="WhatsApp credentials not configured")

    url = f"https://graph.facebook.com/{META_GRAPH_VERSION}/{WHATSAPP_PHONE_NUMBER_ID}/messages"
    headers = {
        "Authorization": f"Bearer {WHATSAPP_TOKEN}",
        "Content-Type": "application/json",
    }
    payload = {
        "messaging_product": "whatsapp",
        "recipient_type": "individual",
        "to": to,
        "type": "text",
        "text": {"body": text, "preview_url": bool(preview_url)},
    }

    # send (synchronous request; dashboard handler is async but this blocking call is fine for small dev use)
    try:
        resp = requests.post(url, headers=headers, json=payload, timeout=30)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to contact WhatsApp API: {e}")

    if resp.status_code >= 300:
        # bubble the Graph API error for debugging
        raise HTTPException(status_code=500, detail=f"WhatsApp API error: {resp.status_code} {resp.text}")

    resp_json = resp.json()

    # Try to extract message id if present; otherwise use a temporary id
    msg_id = None
    try:
        # Graph returns {"messages":[{"id":"..."}]}
        msg_id = resp_json.get("messages", [{}])[0].get("id")
    except Exception:
        msg_id = None
    if not msg_id:
        msg_id = f"tmp-{to}"

    # persist to dashboard message store
    save_message({
        "id": msg_id,
        "from": os.getenv("WHATSAPP_PHONE_NUMBER_ID", "your_number"),
        "to": to,
        "text": text,
        "direction": "outbound"
    })

    # redirect back to dashboard
    return RedirectResponse(url="/dashboard", status_code=303)
