# ----- start_bot.ps1 -----
# 1) Go to the project folder
Set-Location "C:\WINDOWS\JD_Project\whatsapp-llama-bot"

# 2) Activate the venv
. ".\.venv\Scripts\Activate.ps1"

# 3) Optional: make logs folder
if (-not (Test-Path ".\logs")) { New-Item -ItemType Directory -Path ".\logs" | Out-Null }

# 4) Start the server and write logs (runs in foreground)
#    Use -Host 0.0.0.0 if you want LAN access; 127.0.0.1 is fine for local only.
$ts = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
python -m uvicorn app:app --host 127.0.0.1 --port 8080 --log-level info *>> ".\logs\uvicorn_$ts.log"
