# PowerShell script to delete files older than 30 days from the currently signed-in user's Downloads folder,
# clean C:\Lapwing, and create a desktop shortcut to C:\Lapwing.
# Define the log file path
$logPath = "C:\Temp\CleanupLog.txt"
# Create C:\Temp if it doesn't exist
if (-not (Test-Path -Path "C:\Temp")) {
   New-Item -Path "C:\Temp" -ItemType Directory
}
# Create C:\Lapwing if it doesn't exist
$lapwingFolder = "C:\Lapwing"
if (-not (Test-Path -Path $lapwingFolder)) {
   New-Item -Path $lapwingFolder -ItemType Directory
}
# Create a shortcut on the desktop to C:\Lapwing
$shortcutPath = Join-Path ([System.Environment]::GetFolderPath("Desktop")) "Lapwing.lnk"
if (-not (Test-Path -Path $shortcutPath)) {
   $WScriptShell = New-Object -ComObject WScript.Shell
   $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
   $shortcut.TargetPath = $lapwingFolder
   $shortcut.WorkingDirectory = $lapwingFolder
   $shortcut.Description = "Shortcut to Lapwing Folder"
   $shortcut.IconLocation = "shell32.dll, 3" # Default folder icon
   $shortcut.Save()
}
# Get the currently signed-in user's profile path
$userProfilePath = [System.Environment]::GetFolderPath("UserProfile")
$downloadsFolder = Join-Path $userProfilePath "Downloads"
# Check if the Downloads folder exists
if (Test-Path $downloadsFolder) {
   # Get all files older than 30 days in the Downloads folder
   $filesToDelete = Get-ChildItem $downloadsFolder -Recurse -File | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) }
   # Delete files in Downloads and log the actions
   foreach ($file in $filesToDelete) {
       try {
           Remove-Item $file.FullName -Force
           # Log the deletion
           $logEntry = "$(Get-Date) - Deleted from Downloads: $($file.FullName)"
           Add-Content -Path $logPath -Value $logEntry
       } catch {
           # Log any errors
           $logEntry = "$(Get-Date) - Error deleting from Downloads: $($file.FullName) - $_"
           Add-Content -Path $logPath -Value $logEntry
       }
   }
}
# Delete items older than 28 days in C:\Lapwing
$lapwingFiles = Get-ChildItem $lapwingFolder -Recurse -File | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-28) }
foreach ($file in $lapwingFiles) {
   try {
       Remove-Item $file.FullName -Force
       # Log the deletion
       $logEntry = "$(Get-Date) - Deleted from Lapwing: $($file.FullName)"
       Add-Content -Path $logPath -Value $logEntry
   } catch {
       # Log any errors
       $logEntry = "$(Get-Date) - Error deleting from Lapwing: $($file.FullName) - $_"
       Add-Content -Path $logPath -Value $logEntry
   }
}
# Indicate script completion
Add-Content -Path $logFile -Value "Cleanup completed on $currentDate."
Write-Host "Cleanup completed."
