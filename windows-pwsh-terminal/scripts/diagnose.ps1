# Read-only диагностика терминального окружения (pwsh + WezTerm).
# Ничего не меняет — только печатает отчёт. Запуск: pwsh -File diagnose.ps1

Write-Host "=== pwsh ===" -ForegroundColor Cyan
"PSVersion : $($PSVersionTable.PSVersion)"
$pp = $PROFILE.CurrentUserCurrentHost
"Profile   : $pp (exists: $(Test-Path $pp))"

Write-Host "`n=== CLI tools на PATH ===" -ForegroundColor Cyan
$tools = 'starship','atuin','fzf','fd','rg','zoxide','eza','bat','delta',
         'lazygit','yazi','gh','carapace','btm','dust','duf','procs','glow','tldr'
foreach ($t in $tools) {
    $c = Get-Command $t -ErrorAction SilentlyContinue
    "{0,-10} {1}" -f $t, ($(if ($c) { 'ok' } else { '—' }))
}

Write-Host "`n=== PowerShell-модули ===" -ForegroundColor Cyan
foreach ($m in 'PSReadLine','PSFzf','PSCompletions') {
    $mod = Get-Module $m -ListAvailable | Select-Object -First 1
    "{0,-13} {1}" -f $m, ($(if ($mod) { $mod.Version } else { 'не установлен' }))
}

Write-Host "`n=== PSReadLine ===" -ForegroundColor Cyan
try {
    $o = Get-PSReadLineOption
    "PredictionSource : $($o.PredictionSource)"
    "HistorySavePath  : $($o.HistorySavePath)"
    "History exists   : $(Test-Path $o.HistorySavePath)"
} catch { "PSReadLine не загружен в этой сессии" }

Write-Host "`n=== Инициализации в профиле ===" -ForegroundColor Cyan
if (Test-Path $pp) {
    $txt = Get-Content $pp -Raw
    $patterns = 'starship init','zoxide init','atuin init','Set-PsFzfOption',
                'carapace _carapace','Invoke-Starship-PreCommand'
    foreach ($pat in $patterns) {
        "{0,-26} {1}" -f $pat, ($(if ($txt -match [regex]::Escape($pat)) { 'есть' } else { 'нет' }))
    }
} else { "Профиль не найден" }

Write-Host "`n=== WezTerm ===" -ForegroundColor Cyan
$wz = "$env:USERPROFILE\.wezterm.lua"
"Config: $wz (exists: $(Test-Path $wz))"
if (Get-Command wezterm -ErrorAction SilentlyContinue) {
    "wezterm CLI: ok  (валидация: wezterm --config-file `"$wz`" show-keys)"
}
