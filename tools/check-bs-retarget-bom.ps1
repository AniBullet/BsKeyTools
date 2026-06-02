param([string]$Path)
$bytes = [IO.File]::ReadAllBytes($Path)
if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    [IO.File]::WriteAllBytes($Path, [byte[]]$bytes[3..($bytes.Length-1)])
    Write-Host "BOM removed: $Path"
} else {
    Write-Host "No BOM: $Path"
}
