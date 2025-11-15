#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Find photos on a drive and identify unique files for archiving using hash comparison.

.DESCRIPTION
    This script searches for photo files in a specified directory and its subdirectories.
    It generates SHA256 hashes for each file to identify duplicates, helping you archive
    only unique photos.

.PARAMETER Path
    The root path to search for photos. Defaults to current directory.

.PARAMETER Extensions
    Array of photo file extensions to search for. Defaults to common photo formats.

.PARAMETER OutputFile
    Optional CSV file path to export results. If not specified, results display in console.

.PARAMETER ShowDuplicatesOnly
    If specified, only shows duplicate files instead of all files.

.EXAMPLE
    .\FindPhotos.ps1 -Path "C:\Pictures"
    Searches for photos in C:\Pictures and displays all unique and duplicate files.

.EXAMPLE
    .\FindPhotos.ps1 -Path "C:\Pictures" -ShowDuplicatesOnly
    Searches for photos and displays only the duplicates.

.EXAMPLE
    .\FindPhotos.ps1 -Path "C:\Pictures" -OutputFile "results.csv"
    Searches for photos and exports results to a CSV file.

.NOTES
    Requires PowerShell 7+
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Path = ".",
    
    [Parameter(Mandatory=$false)]
    [string[]]$Extensions = @("*.jpg", "*.jpeg", "*.png", "*.gif", "*.bmp", "*.tiff", "*.tif", "*.webp", "*.heic", "*.raw", "*.cr2", "*.nef", "*.arw", "*.dng"),
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFile,
    
    [Parameter(Mandatory=$false)]
    [switch]$ShowDuplicatesOnly
)

# Ensure PowerShell 7+
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Error "This script requires PowerShell 7 or higher. Current version: $($PSVersionTable.PSVersion)"
    exit 1
}

# Resolve the path to absolute path
$Path = Resolve-Path -Path $Path -ErrorAction Stop

Write-Host "FindPhotos - Photo Discovery and Hash Generation Tool" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "Searching path: $Path" -ForegroundColor Yellow
Write-Host "Extensions: $($Extensions -join ', ')" -ForegroundColor Yellow
Write-Host ""

# Find all photo files
Write-Host "Discovering photo files..." -ForegroundColor Green
$photoFiles = @()
foreach ($ext in $Extensions) {
    $files = Get-ChildItem -Path $Path -Filter $ext -Recurse -File -ErrorAction SilentlyContinue
    $photoFiles += $files
}

if ($photoFiles.Count -eq 0) {
    Write-Host "No photo files found in the specified path." -ForegroundColor Yellow
    exit 0
}

Write-Host "Found $($photoFiles.Count) photo file(s)" -ForegroundColor Green
Write-Host ""

# Calculate hashes and build file information
Write-Host "Generating file hashes (this may take a while)..." -ForegroundColor Green
$fileInfoList = @()
$processedCount = 0

foreach ($file in $photoFiles) {
    $processedCount++
    
    # Show progress
    if ($processedCount % 10 -eq 0 -or $processedCount -eq $photoFiles.Count) {
        Write-Progress -Activity "Computing file hashes" -Status "Processing $processedCount of $($photoFiles.Count)" -PercentComplete (($processedCount / $photoFiles.Count) * 100)
    }
    
    try {
        # Generate SHA256 hash
        $hash = Get-FileHash -Path $file.FullName -Algorithm SHA256 -ErrorAction Stop
        
        $fileInfo = [PSCustomObject]@{
            FullPath = $file.FullName
            FileName = $file.Name
            Directory = $file.DirectoryName
            Size = $file.Length
            SizeKB = [math]::Round($file.Length / 1KB, 2)
            SizeMB = [math]::Round($file.Length / 1MB, 2)
            Hash = $hash.Hash
            LastModified = $file.LastWriteTime
            Created = $file.CreationTime
        }
        
        $fileInfoList += $fileInfo
    }
    catch {
        Write-Warning "Failed to process file: $($file.FullName) - $($_.Exception.Message)"
    }
}

Write-Progress -Activity "Computing file hashes" -Completed
Write-Host ""

# Group by hash to find duplicates
Write-Host "Analyzing for duplicates..." -ForegroundColor Green
$groupedByHash = $fileInfoList | Group-Object -Property Hash

$uniqueFiles = $groupedByHash | Where-Object { $_.Count -eq 1 } | ForEach-Object { $_.Group[0] }
$duplicateGroups = $groupedByHash | Where-Object { $_.Count -gt 1 }

# Display summary
Write-Host ""
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "Total files processed: $($fileInfoList.Count)" -ForegroundColor White
Write-Host "Unique files: $($uniqueFiles.Count)" -ForegroundColor Green
Write-Host "Duplicate groups: $($duplicateGroups.Count)" -ForegroundColor Yellow
if ($duplicateGroups.Count -gt 0) {
    $totalDuplicateFiles = ($duplicateGroups | ForEach-Object { $_.Count - 1 } | Measure-Object -Sum).Sum
    $duplicateWaste = ($duplicateGroups | ForEach-Object { 
        $groupSize = $_.Group[0].Size
        $copies = $_.Count - 1
        $groupSize * $copies
    } | Measure-Object -Sum).Sum
    Write-Host "Total duplicate files: $totalDuplicateFiles" -ForegroundColor Yellow
    Write-Host "Space wasted by duplicates: $([math]::Round($duplicateWaste / 1MB, 2)) MB" -ForegroundColor Yellow
}
Write-Host ""

# Display results
if ($ShowDuplicatesOnly) {
    if ($duplicateGroups.Count -eq 0) {
        Write-Host "No duplicate files found!" -ForegroundColor Green
    }
    else {
        Write-Host "DUPLICATE FILES:" -ForegroundColor Yellow
        Write-Host "=" * 60 -ForegroundColor Yellow
        
        $groupNum = 1
        foreach ($group in $duplicateGroups) {
            Write-Host ""
            Write-Host "Duplicate Group #$groupNum ($($group.Count) copies, $([math]::Round($group.Group[0].SizeMB, 2)) MB each):" -ForegroundColor Cyan
            Write-Host "Hash: $($group.Name)" -ForegroundColor Gray
            
            foreach ($file in $group.Group) {
                Write-Host "  - $($file.FullPath)" -ForegroundColor White
                Write-Host "    Modified: $($file.LastModified)" -ForegroundColor Gray
            }
            $groupNum++
        }
    }
}
else {
    # Show all files with duplicate indicator
    Write-Host "ALL FILES:" -ForegroundColor Cyan
    Write-Host "=" * 60 -ForegroundColor Cyan
    
    $results = @()
    foreach ($group in $groupedByHash) {
        $isDuplicate = $group.Count -gt 1
        
        foreach ($file in $group.Group) {
            $results += [PSCustomObject]@{
                IsDuplicate = $isDuplicate
                DuplicateCount = $group.Count
                FileName = $file.FileName
                SizeMB = $file.SizeMB
                Hash = $file.Hash
                FullPath = $file.FullPath
                LastModified = $file.LastModified
            }
        }
    }
    
    # Display in table format
    $results | Sort-Object -Property IsDuplicate -Descending | 
        Format-Table -Property @{Label="Status"; Expression={if($_.IsDuplicate){"DUPLICATE"}else{"UNIQUE"}}}, 
                               @{Label="Copies"; Expression={$_.DuplicateCount}},
                               FileName, 
                               @{Label="Size(MB)"; Expression={$_.SizeMB}},
                               FullPath -AutoSize
}

# Export to CSV if requested
if ($OutputFile) {
    Write-Host ""
    Write-Host "Exporting results to: $OutputFile" -ForegroundColor Green
    
    $exportData = @()
    foreach ($group in $groupedByHash) {
        $isDuplicate = $group.Count -gt 1
        
        foreach ($file in $group.Group) {
            $exportData += [PSCustomObject]@{
                Status = if($isDuplicate){"DUPLICATE"}else{"UNIQUE"}
                DuplicateCount = $group.Count
                FileName = $file.FileName
                Directory = $file.Directory
                FullPath = $file.FullPath
                SizeBytes = $file.Size
                SizeKB = $file.SizeKB
                SizeMB = $file.SizeMB
                Hash = $file.Hash
                LastModified = $file.LastModified
                Created = $file.Created
            }
        }
    }
    
    $exportData | Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8
    Write-Host "Export complete!" -ForegroundColor Green
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green
