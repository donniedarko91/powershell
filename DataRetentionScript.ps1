# Define the path to the Downloads folder
$downloadsFolder = [System.IO.Path]::Combine($env:USERPROFILE, 'Downloads')
# Define the log file path in a user-accessible directory
$logDir = [System.IO.Path]::Combine($env:USERPROFILE, 'CleanupLogs')
$logFile = [System.IO.Path]::Combine($logDir, 'CleanupLog.txt')
# Create the log directory if it does not exist
if (-not (Test-Path -Path $logDir)) {
   New-Item -ItemType Directory -Path $logDir
}
# Get the current date
$currentDate = Get-Date
# Get all files and folders in the Downloads folder
$items = Get-ChildItem -Path $downloadsFolder
# Check if there are any items to process
if ($items.Count -eq 0) {
   Add-Content -Path $logFile -Value "No items found in the Downloads folder."
   Write-Host "No items found in the Downloads folder."
} else {
   # Loop through each item and delete if older than 30 days
   foreach ($item in $items) {
       if ($item.LastWriteTime -lt $currentDate.AddDays(-30)) {
           if ($item.PSIsContainer) {
               # If the item is a folder, remove it
               Remove-Item $item.FullName -Recurse -Force
               Add-Content -Path $logFile -Value "Folder: $($item.FullName) deleted on $currentDate"
               Write-Host "Deleted folder: $($item.FullName)"
           } else {
               # If the item is a file, remove it
               Remove-Item $item.FullName -Force
               Add-Content -Path $logFile -Value "File: $($item.FullName) deleted on $currentDate"
               Write-Host "Deleted file: $($item.FullName)"
           }
       } else {
           Write-Host "Not deleting (too new): $($item.FullName)"
       }
   }
}
# Indicate script completion
Add-Content -Path $logFile -Value "Cleanup completed on $currentDate."
Write-Host "Cleanup completed."