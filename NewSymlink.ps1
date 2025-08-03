param (
    [string]$TargetPath
)

# Self-elevate if not admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Start-Process PowerShell -ArgumentList "-NoProfile","-ExecutionPolicy","Bypass","-File","`"$PSCommandPath`"","`"$TargetPath`"" -Verb RunAs
    exit
}

Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName System.Windows.Forms

# Get clipboard path
$source = [System.Windows.Forms.Clipboard]::GetText()

if (-not $source -or -not (Test-Path $source)) {
    [System.Windows.Forms.MessageBox]::Show("Clipboard does not contain a valid file or folder path.","New Symlink")
    exit 1
}

if (-not $TargetPath) {
    $TargetPath = Get-Location
}

# Use the original name of the source file/folder
$linkName = Split-Path $source -Leaf
$linkPath = Join-Path $TargetPath $linkName

# Auto-rename if a conflict exists
$counter = 1
while (Test-Path $linkPath) {
    $linkName = "$(Split-Path $source -Leaf)-link$counter"
    $linkPath = Join-Path $TargetPath $linkName
    $counter++
}

# Build mklink command
if (Test-Path $source -PathType Container) {
    $mklinkCmd = "mklink /D `"$linkPath`" `"$source`""
} else {
    $mklinkCmd = "mklink `"$linkPath`" `"$source`""
}

# Run mklink in elevated CMD
Start-Process cmd -ArgumentList "/c $mklinkCmd" -Wait -Verb RunAs

# Confirm success
if (Test-Path $linkPath) {
    [System.Windows.Forms.MessageBox]::Show("Symlink created successfully:`n$linkPath","New Symlink")
} else {
    [System.Windows.Forms.MessageBox]::Show("Failed to create symlink.","New Symlink")
}
