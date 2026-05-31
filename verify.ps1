param(
  [string]$HermesRoot = "E:\AI\hermes\hermes-agent",
  [switch]$RunTests,
  [switch]$RunFullBaseline
)

$ErrorActionPreference = "Stop"
$script:Failed = 0

function Add-Check([bool]$Ok, [string]$Name, [string]$Detail = "") {
  $status = if ($Ok) { "OK" } else { "FAIL" }
  $line = "[$status] $Name"
  if ($Detail) {
    $line = "$line - $Detail"
  }
  Write-Host $line
  if (!$Ok) {
    $script:Failed++
  }
}

function Repo-Path([string]$RelativePath) {
  return Join-Path $HermesRoot $RelativePath
}

function Read-RepoFile([string]$RelativePath) {
  $path = Repo-Path $RelativePath
  if (!(Test-Path -LiteralPath $path)) {
    return $null
  }
  return Get-Content -Raw -LiteralPath $path
}

function Require-File([string]$RelativePath) {
  Add-Check (Test-Path -LiteralPath (Repo-Path $RelativePath)) $RelativePath
}

function Require-Text([string]$RelativePath, [string]$Needle, [string]$Name = "") {
  $content = Read-RepoFile $RelativePath
  $label = if ($Name) { $Name } else { "$RelativePath contains $Needle" }
  Add-Check ($null -ne $content -and $content.Contains($Needle)) $label
}

function Run-Step([string]$Name, [string]$WorkingDirectory, [string[]]$Command) {
  Add-Check $true "RUN $Name"
  Push-Location $WorkingDirectory
  try {
    & $Command[0] @($Command | Select-Object -Skip 1)
    Add-Check ($LASTEXITCODE -eq 0) $Name "exit $LASTEXITCODE"
  } catch {
    Add-Check $false $Name $_.Exception.Message
  } finally {
    Pop-Location
  }
}

Write-Host "hermes-tui-extension-core verify"
Write-Host "HermesRoot: $HermesRoot"

Add-Check (Test-Path -LiteralPath $HermesRoot) "Hermes root exists"

$requiredFiles = @(
  "ui-tui\src\domain\tuiModules.ts",
  "ui-tui\src\app\tuiModuleStore.ts",
  "ui-tui\src\app\tuiDoctor.ts",
  "ui-tui\src\components\tuiModuleHost.tsx",
  "ui-tui\src\components\appLayout.tsx",
  "ui-tui\src\app\createGatewayEventHandler.ts",
  "ui-tui\src\app\useMainApp.ts",
  "ui-tui\src\app\slash\commands\debug.ts",
  "ui-tui\src\app\slash\commands\core.ts",
  "ui-tui\src\gatewayTypes.ts",
  "ui-tui\src\__tests__\tuiModuleStore.test.ts",
  "ui-tui\src\__tests__\tuiModuleHost.test.tsx",
  "tui_gateway\server.py",
  "tests\test_tui_gateway_server.py"
)

foreach ($file in $requiredFiles) {
  Require-File $file
}

Require-Text "ui-tui\src\domain\tuiModules.ts" "TUI_EXTENSION_NAME = 'hermes-tui-extension-core'" "frontend extension name"
Require-Text "ui-tui\src\domain\tuiModules.ts" "TUI_EXTENSION_VERSION = '0.2.0'" "frontend extension version"
Require-Text "ui-tui\src\domain\tuiModules.ts" "TUI_EXTENSION_PROTOCOL_VERSION = 1" "frontend protocol version"
Require-Text "ui-tui\src\domain\tuiModules.ts" "'transcript.live_tail'" "live-tail slot exists"
Require-Text "ui-tui\src\app\tuiModuleStore.ts" "removeTuiModuleSnapshot" "module store can remove smoke state"
Require-Text "ui-tui\src\app\tuiModuleStore.ts" "markTuiModulesStale" "gateway-exit stale hook exists"
Require-Text "ui-tui\src\app\tuiDoctor.ts" "TUI_EXTENSION_VERSION" "doctor reports extension version"
Require-Text "ui-tui\src\components\tuiModuleHost.tsx" "selectTuiModulesForSlot" "module host reads slots"
Require-Text "ui-tui\src\components\appLayout.tsx" "TuiModuleHost" "layout mounts module host"
Require-Text "ui-tui\src\app\createGatewayEventHandler.ts" "case 'tui.module.update'" "gateway event handler receives module updates"
Require-Text "ui-tui\src\app\useMainApp.ts" "markTuiModulesStale" "gateway exit marks modules stale"
Require-Text "ui-tui\src\app\slash\commands\debug.ts" "name: 'tui-module-smoke'" "slash smoke command exists"
Require-Text "ui-tui\src\app\slash\commands\debug.ts" "SMOKE_MODULE_ID = 'tui_smoke'" "smoke module id is stable"
Require-Text "ui-tui\src\app\slash\commands\core.ts" "/tui-module-smoke [state|clear]" "help lists smoke command"
Require-Text "ui-tui\src\gatewayTypes.ts" "TuiExtensionVersionResponse" "gateway type for extension version"
Require-Text "ui-tui\src\gatewayTypes.ts" "TuiModuleUpdateResponse" "gateway type for module update"
Require-Text "tui_gateway\server.py" "_TUI_EXTENSION_VERSION = `"0.2.0`"" "backend extension version"
Require-Text "tui_gateway\server.py" '@method("tui.extension.version")' "backend version RPC"
Require-Text "tui_gateway\server.py" '@method("tui.module.update")' "backend module update RPC"
Require-Text "tui_gateway\server.py" "session_id required" "backend rejects missing session id"
Require-Text "tui_gateway\server.py" "unknown tui module state" "backend rejects unknown module state"
Require-Text "tests\test_tui_gateway_server.py" "test_tui_extension_version_rpc_reports_protocol" "backend version RPC test exists"
Require-Text "tests\test_tui_gateway_server.py" "test_tui_module_update_emits_scoped_snapshot" "backend update RPC test exists"

$domain = Read-RepoFile "ui-tui\src\domain\tuiModules.ts"
if ($null -ne $domain) {
  $match = [regex]::Match($domain, "export const DEFAULT_TUI_MODULES[\s\S]*?\n}")
  Add-Check ($match.Success -and !$match.Value.Contains("tui_smoke")) "smoke module is not enabled by default"
}

if ($RunTests) {
  $uiRoot = Repo-Path "ui-tui"
  Run-Step "type-check" $uiRoot @("npm", "run", "type-check")
  Run-Step "targeted frontend tests" $uiRoot @(
    "npm", "run", "test", "--", "--run",
    "src\__tests__\tuiModules.test.ts",
    "src\__tests__\tuiModuleStore.test.ts",
    "src\__tests__\tuiModuleHost.test.tsx",
    "src\__tests__\createGatewayEventHandler.test.ts",
    "src\__tests__\createSlashHandler.test.ts"
  )
  Run-Step "targeted backend tests" $HermesRoot @(
    "uv", "run", "python", "-m", "pytest", "-n0", "--timeout-method=thread",
    "tests\test_tui_gateway_server.py::test_tui_extension_version_rpc_reports_protocol",
    "tests\test_tui_gateway_server.py::test_tui_module_update_emits_scoped_snapshot",
    "tests\test_tui_gateway_server.py::test_tui_module_update_accepts_top_level_snapshot_fields",
    "tests\test_tui_gateway_server.py::test_tui_module_update_rejects_missing_session_id",
    "tests\test_tui_gateway_server.py::test_tui_module_update_rejects_unknown_state",
    "tests\test_tui_gateway_server.py::test_complete_slash_includes_tui_module_smoke_command",
    "tests\test_tui_gateway_server.py::test_commands_catalog_includes_tui_module_smoke_command",
    "-q"
  )
}

if ($RunFullBaseline) {
  $baseline = "E:\AI\github\hermes-tui-reverse-study\tools\run-no-regression-baseline.ps1"
  if (Test-Path -LiteralPath $baseline) {
    Run-Step "full no-regression baseline" $HermesRoot @(
      "pwsh", "-ExecutionPolicy", "Bypass", "-File", $baseline, "-Mode", "Full", "-RunZhVerify"
    )
  } else {
    Add-Check $false "full no-regression baseline" "missing $baseline"
  }
}

Write-Host ""
Write-Host "Summary failed: $Failed"

if ($Failed -gt 0) {
  exit 1
}
