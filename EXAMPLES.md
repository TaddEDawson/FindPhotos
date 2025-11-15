# FindPhotos Usage Examples

This document provides practical examples of using FindPhotos for common scenarios.

## Quick Start

### 1. Scan Current Directory

Simply run the script in any directory:

```powershell
./FindPhotos.ps1
```

This will scan the current directory and all subdirectories for photos.

### 2. Scan a Specific Directory

```powershell
./FindPhotos.ps1 -Path "C:\Users\YourName\Pictures"
```

Or on Linux/Mac:

```powershell
./FindPhotos.ps1 -Path "~/Pictures"
```

## Common Use Cases

### Find Duplicates Before Backup

Identify duplicate photos before creating a backup:

```powershell
./FindPhotos.ps1 -Path "D:\Photos" -ShowDuplicatesOnly -OutputFile "duplicates_report.csv"
```

This creates a CSV file listing all duplicate photos, which you can review before backing up.

### Scan External Drive

Scan a USB drive or external hard drive:

```powershell
./FindPhotos.ps1 -Path "E:\" -OutputFile "external_drive_photos.csv"
```

### Camera Import Folder

Check what's unique in your camera import folder:

```powershell
./FindPhotos.ps1 -Path "C:\Users\YourName\Pictures\Camera Import"
```

### Search Only RAW Files

If you shoot in RAW format:

```powershell
./FindPhotos.ps1 -Path "D:\Photography" -Extensions "*.cr2","*.nef","*.arw","*.dng"
```

This searches for Canon (.cr2), Nikon (.nef), Sony (.arw), and Adobe DNG (.dng) RAW files.

### Find JPEG Duplicates Only

Search only for JPEG files:

```powershell
./FindPhotos.ps1 -Path "C:\Pictures" -Extensions "*.jpg","*.jpeg" -ShowDuplicatesOnly
```

## Advanced Scenarios

### Multiple Folders Comparison

To compare photos across multiple folders, scan the parent directory:

```powershell
# If you have:
# C:\Photos\Vacation2023\
# C:\Photos\Backup\
# C:\Photos\Phone\

./FindPhotos.ps1 -Path "C:\Photos" -ShowDuplicatesOnly
```

This will find duplicates across all subdirectories.

### Photo Library Cleanup

1. First, get a full report:

```powershell
./FindPhotos.ps1 -Path "C:\MyPhotoLibrary" -OutputFile "full_report.csv"
```

2. Open the CSV in Excel or similar tool

3. Sort by "Status" column to see all duplicates

4. For each duplicate group (identified by matching Hash), keep one copy and delete the others

### Archive Planning

Calculate how much space you'll save by removing duplicates:

```powershell
./FindPhotos.ps1 -Path "D:\PhotoArchive" -ShowDuplicatesOnly
```

Look at the "Space wasted by duplicates" line in the summary.

### iPhone Photos

Search for HEIC files (iPhone photos):

```powershell
./FindPhotos.ps1 -Path "C:\iPhone Backup" -Extensions "*.heic","*.jpg"
```

## Interpreting Results

### Console Output

When you run FindPhotos, you'll see:

```
SUMMARY
============================================================
Total files processed: 150
Unique files: 130
Duplicate groups: 10
Total duplicate files: 20
Space wasted by duplicates: 45.6 MB
```

**Unique files**: Files that have no duplicates
**Duplicate groups**: Sets of identical files (a group of 3 identical files counts as 1 group)
**Total duplicate files**: The extra copies (in a group of 3, there are 2 duplicates)
**Space wasted**: Storage used by duplicate copies

### CSV Output

The CSV contains these columns:

- **Status**: "UNIQUE" or "DUPLICATE"
- **DuplicateCount**: How many copies exist (1 = unique, 2+ = duplicates)
- **FileName**: Name of the file
- **Directory**: Directory path
- **FullPath**: Complete file path
- **SizeBytes/SizeKB/SizeMB**: File size in different units
- **Hash**: SHA256 hash (identical files have identical hashes)
- **LastModified**: When the file was last modified
- **Created**: When the file was created

### Working with CSV in Excel

1. Open the CSV file in Excel
2. Add filters to the header row (Data > Filter)
3. Filter by "Status" = "DUPLICATE" to see only duplicates
4. Group by "Hash" to see which files are identical
5. For each hash group, decide which copy to keep based on LastModified or directory

## Performance Tips

### For Large Photo Libraries (10,000+ files)

Process in batches by year or event:

```powershell
# Year by year
./FindPhotos.ps1 -Path "C:\Photos\2023" -OutputFile "photos_2023.csv"
./FindPhotos.ps1 -Path "C:\Photos\2024" -OutputFile "photos_2024.csv"
```

### Skip Non-Photo Extensions

By default, FindPhotos searches for 14 different photo formats. If you only have JPEGs and PNGs, limit the search:

```powershell
./FindPhotos.ps1 -Path "C:\Photos" -Extensions "*.jpg","*.png"
```

This makes the initial file discovery faster.

## Troubleshooting

### "Requires PowerShell 7" Error

Make sure you're running PowerShell 7+:

```powershell
pwsh --version
```

If you're on PowerShell 5.x (Windows PowerShell), download PowerShell 7+ from:
https://github.com/PowerShell/PowerShell/releases

### Permission Errors

Run PowerShell as administrator if you're scanning system directories:

```powershell
# Windows: Right-click PowerShell and "Run as Administrator"
# Then run:
./FindPhotos.ps1 -Path "C:\Windows\System32"
```

### Very Large Files Taking Long Time

The script uses SHA256 hashing, which reads the entire file. For very large files (>100MB), hashing takes longer. This is normal and ensures accurate duplicate detection.

## Best Practices

1. **Test First**: Run on a small folder first to see how it works
2. **Export to CSV**: Always use `-OutputFile` for large scans so you can analyze later
3. **Backup First**: Before deleting any duplicates, ensure you have a backup
4. **Verify Duplicates**: Check a few files manually to ensure they're truly identical
5. **Keep Best Copy**: When deleting duplicates, keep the copy with the best filename or location

## Automation

### Scheduled Scans

Create a scheduled task (Windows) or cron job (Linux/Mac) to run regular scans:

**Windows Task Scheduler**:
```powershell
# Create a task that runs weekly
$action = New-ScheduledTaskAction -Execute "pwsh" -Argument "-File C:\Scripts\FindPhotos.ps1 -Path C:\Photos -OutputFile C:\Reports\photos_$(Get-Date -Format 'yyyy-MM-dd').csv"
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 2am
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "WeeklyPhotoScan"
```

**Linux/Mac Cron**:
```bash
# Edit crontab
crontab -e

# Add line (runs every Sunday at 2 AM):
0 2 * * 0 pwsh /home/user/scripts/FindPhotos.ps1 -Path /home/user/Pictures -OutputFile /home/user/reports/photos_$(date +\%Y-\%m-\%d).csv
```

### Batch Processing Multiple Folders

Create a script to scan multiple directories:

```powershell
# scan_all.ps1
$folders = @(
    "C:\Photos\Family",
    "C:\Photos\Vacation",
    "C:\Photos\Work",
    "D:\Backup\Photos"
)

foreach ($folder in $folders) {
    $folderName = Split-Path $folder -Leaf
    $outputFile = "C:\Reports\$folderName_$(Get-Date -Format 'yyyy-MM-dd').csv"
    ./FindPhotos.ps1 -Path $folder -OutputFile $outputFile
}
```

## Integration with Other Tools

### PowerShell Pipeline

Use FindPhotos output in PowerShell pipelines:

```powershell
# Find all duplicate JPEGs and move them to a review folder
./FindPhotos.ps1 -Path "C:\Photos" -OutputFile "temp.csv"
Import-Csv temp.csv | Where-Object { $_.Status -eq "DUPLICATE" -and $_.FileName -like "*.jpg" } | 
    ForEach-Object { Move-Item $_.FullPath "C:\ReviewDuplicates\" }
```

### Analysis in Python/R

The CSV output can be imported into Python or R for advanced analysis:

```python
# Python example
import pandas as pd

df = pd.read_csv('photos_report.csv')
duplicates = df[df['Status'] == 'DUPLICATE']
print(f"Total wasted space: {duplicates['SizeBytes'].sum() / 1024 / 1024:.2f} MB")
```

## Questions?

For issues or questions, please visit the GitHub repository.
