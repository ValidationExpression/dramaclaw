# 本地启动导演工作台（无 Docker、无 Codex，使用 Claude 作为 Agent 后端）
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$workspace = Split-Path -Parent $root
$gatewayExe = Join-Path $workspace 'dramaclaw-gateway\dramaclaw-gateway.exe'
$logs = Join-Path $root 'state\logs'
New-Item -ItemType Directory -Force $logs | Out-Null

$env:ST_EDITION = 'ce'
$env:ST_CONTROL_PLANE_DSN = ''
$env:ST_REDIS_URL = ''
$env:ST_CELERY_BROKER_URL = ''
$env:ST_CELERY_RESULT_BACKEND = ''
$env:NOVELVIDEO_DATA_ROOT = $root
$env:NOVELVIDEO_STATE_DIR = Join-Path $root 'state'
$env:NOVELVIDEO_OUTPUT_DIR = Join-Path $root 'output'
$env:NOVELVIDEO_RUNTIME_DIR = Join-Path $root 'runtime'
$env:NOVELVIDEO_API_URL = 'http://127.0.0.1:8780'
$env:DRAMACLAW_API_URL = 'http://127.0.0.1:8780'
$env:SUPERTALE_API_URL = 'http://127.0.0.1:8780'
$env:DRAMACLAW_CHAT_BACKEND = 'codex'
$env:CODEX_BIN = Join-Path $root '.venv\Lib\site-packages\codex_cli_bin\bin\codex.exe'
$env:CODEBUDDY_SAFE_DELETE_ENABLED = '0'
$env:SQLITE_PATH = (Join-Path $root 'state\newapi\one-api.db').Replace('\', '/')
$env:PORT = '3000'

function Start-LocalService {
    param(
        [string] $Name,
        [int] $Port,
        [string] $FilePath,
        [string[]] $Arguments,
        [string] $WorkingDirectory
    )

    $listening = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
    if ($listening) {
        Write-Host "$Name 已在端口 $Port 运行"
        return
    }
    if (-not (Test-Path $FilePath)) {
        throw "$Name 启动文件不存在：$FilePath"
    }
    $startArgs = @{
        FilePath               = $FilePath
        WorkingDirectory       = $WorkingDirectory
        PassThru               = $true
        WindowStyle            = 'Hidden'
        RedirectStandardOutput = (Join-Path $logs "$Name.out.log")
        RedirectStandardError  = (Join-Path $logs "$Name.err.log")
    }
    if ($Arguments -and $Arguments.Count -gt 0) {
        $startArgs['ArgumentList'] = $Arguments
    }
    $process = Start-Process @startArgs
    Write-Host "$Name 已启动 (PID $($process.Id))，端口 $Port"
}

Start-LocalService -Name 'gateway' -Port 3000 -FilePath $gatewayExe `
    -Arguments @() -WorkingDirectory (Split-Path -Parent $gatewayExe)
Start-LocalService -Name 'api' -Port 8780 -FilePath (Join-Path $root '.venv\Scripts\novelvideo.exe') `
    -Arguments @('api', '--host', '127.0.0.1', '--port', '8780') -WorkingDirectory $root
Start-LocalService -Name 'frontend' -Port 5173 -FilePath 'pnpm.cmd' `
    -Arguments @('dev', '--host', '127.0.0.1', '--port', '5173') -WorkingDirectory (Join-Path $root 'frontend')

Write-Host '导演工作台：http://127.0.0.1:5173'
Write-Host '视频模型：MiniMax-H3-local（远程 ComfyUI 192.168.44.104:8188）'
