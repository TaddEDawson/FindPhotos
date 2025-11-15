#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Test script for FindPhotos.ps1

.DESCRIPTION
    Creates test photo files and validates FindPhotos.ps1 functionality
#>

# Ensure PowerShell 7+
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Error "This script requires PowerShell 7 or higher. Current version: $($PSVersionTable.PSVersion)"
    exit 1
}

Write-Host "FindPhotos Test Suite" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""

# Create temporary test directory
$tempPath = if ($IsWindows) { $env:TEMP } else { "/tmp" }
$testDir = Join-Path $tempPath "FindPhotos_Test_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -ItemType Directory -Path $testDir -Force | Out-Null
Write-Host "Created test directory: $testDir" -ForegroundColor Green

try {
    # Create test subdirectories
    $subDir1 = Join-Path $testDir "Folder1"
    $subDir2 = Join-Path $testDir "Folder2"
    New-Item -ItemType Directory -Path $subDir1 -Force | Out-Null
    New-Item -ItemType Directory -Path $subDir2 -Force | Out-Null

    # Create test files with content
    Write-Host "Creating test photo files..." -ForegroundColor Yellow

    # Unique file 1
    $file1 = Join-Path $subDir1 "photo1.jpg"
    "This is photo 1 - unique content" | Out-File -FilePath $file1 -Encoding UTF8

    # Unique file 2
    $file2 = Join-Path $subDir1 "photo2.png"
    "This is photo 2 - different unique content" | Out-File -FilePath $file2 -Encoding UTF8

    # Duplicate of file 1 (same content, different name and location)
    $file3 = Join-Path $subDir2 "photo1_copy.jpg"
    "This is photo 1 - unique content" | Out-File -FilePath $file3 -Encoding UTF8

    # Another duplicate of file 1
    $file4 = Join-Path $subDir2 "renamed_photo.jpeg"
    "This is photo 1 - unique content" | Out-File -FilePath $file4 -Encoding UTF8

    # Unique file 3
    $file5 = Join-Path $testDir "image.gif"
    "This is a GIF image with unique content" | Out-File -FilePath $file5 -Encoding UTF8

    Write-Host "Created 5 test files (3 unique, 2 duplicates)" -ForegroundColor Green
    Write-Host ""

    # Test 1: Basic functionality
    Write-Host "Test 1: Basic functionality - Find all photos" -ForegroundColor Cyan
    Write-Host "-" * 60 -ForegroundColor Gray
    & "$PSScriptRoot/FindPhotos.ps1" -Path $testDir
    Write-Host ""

    # Test 2: Show duplicates only
    Write-Host "Test 2: Show duplicates only" -ForegroundColor Cyan
    Write-Host "-" * 60 -ForegroundColor Gray
    & "$PSScriptRoot/FindPhotos.ps1" -Path $testDir -ShowDuplicatesOnly
    Write-Host ""

    # Test 3: CSV export
    Write-Host "Test 3: Export to CSV" -ForegroundColor Cyan
    Write-Host "-" * 60 -ForegroundColor Gray
    $csvFile = Join-Path $testDir "results.csv"
    & "$PSScriptRoot/FindPhotos.ps1" -Path $testDir -OutputFile $csvFile
    
    if (Test-Path $csvFile) {
        Write-Host "CSV export successful!" -ForegroundColor Green
        $csvContent = Import-Csv $csvFile
        Write-Host "CSV contains $($csvContent.Count) rows" -ForegroundColor Green
        Write-Host ""
    }
    else {
        Write-Host "CSV export failed!" -ForegroundColor Red
    }

    # Test 4: Specific extensions
    Write-Host "Test 4: Search for specific extensions (*.jpg only)" -ForegroundColor Cyan
    Write-Host "-" * 60 -ForegroundColor Gray
    & "$PSScriptRoot/FindPhotos.ps1" -Path $testDir -Extensions "*.jpg"
    Write-Host ""

    # Validation
    Write-Host "=" * 60 -ForegroundColor Cyan
    Write-Host "TEST VALIDATION" -ForegroundColor Cyan
    Write-Host "=" * 60 -ForegroundColor Cyan
    Write-Host "Expected results:" -ForegroundColor Yellow
    Write-Host "  - Total files: 5" -ForegroundColor White
    Write-Host "  - Unique files: 3" -ForegroundColor White
    Write-Host "  - Duplicate groups: 1 (with 3 copies of photo1)" -ForegroundColor White
    Write-Host ""
    Write-Host "Please verify the output above matches these expectations." -ForegroundColor Yellow
    Write-Host ""

    Write-Host "All tests completed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Test files location: $testDir" -ForegroundColor Gray
    Write-Host "You can manually review the test files if needed." -ForegroundColor Gray
}
catch {
    Write-Host "Test failed with error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
finally {
    # Prompt to clean up
    Write-Host ""
    $cleanup = Read-Host "Delete test directory? (y/n)"
    if ($cleanup -eq 'y') {
        Remove-Item -Path $testDir -Recurse -Force
        Write-Host "Test directory deleted." -ForegroundColor Green
    }
    else {
        Write-Host "Test directory preserved: $testDir" -ForegroundColor Yellow
    }
}
