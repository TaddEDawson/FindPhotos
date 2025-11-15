# FindPhotos

PowerShell 7+ application that finds photos on a drive, generates hashes, and identifies unique files for archiving.

## Features

- 🔍 **Photo Discovery**: Recursively searches directories for photo files
- 🔐 **Hash Generation**: Generates SHA256 hashes for each photo file
- 📊 **Duplicate Detection**: Identifies duplicate files based on hash comparison
- 📈 **Progress Tracking**: Shows real-time progress during hash computation
- 💾 **CSV Export**: Optional export of results to CSV format
- 🎯 **Flexible Filtering**: Show all files or only duplicates
- 📏 **Storage Analysis**: Calculates wasted space from duplicate files

## Requirements

- PowerShell 7.0 or higher

## Installation

1. Clone this repository or download `FindPhotos.ps1`
2. Ensure PowerShell 7+ is installed on your system

Check your PowerShell version:
```powershell
pwsh --version
```

## Usage

### Basic Usage

Search current directory for photos:
```powershell
./FindPhotos.ps1
```

Search a specific directory:
```powershell
./FindPhotos.ps1 -Path "C:\Pictures"
```

### Show Only Duplicates

Display only duplicate files:
```powershell
./FindPhotos.ps1 -Path "C:\Pictures" -ShowDuplicatesOnly
```

### Export Results

Export results to CSV file:
```powershell
./FindPhotos.ps1 -Path "C:\Pictures" -OutputFile "photo-report.csv"
```

### Custom File Extensions

Search for specific photo types:
```powershell
./FindPhotos.ps1 -Path "C:\Pictures" -Extensions "*.jpg","*.png"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `Path` | String | No | Current directory | Root path to search for photos |
| `Extensions` | String[] | No | Common photo formats | File extensions to search for |
| `OutputFile` | String | No | None | CSV file path for exporting results |
| `ShowDuplicatesOnly` | Switch | No | False | Show only duplicate files |

## Default Photo Extensions

The script searches for these file types by default:
- `.jpg`, `.jpeg` - JPEG images
- `.png` - PNG images
- `.gif` - GIF images
- `.bmp` - Bitmap images
- `.tiff`, `.tif` - TIFF images
- `.webp` - WebP images
- `.heic` - HEIC images (iPhone)
- `.raw`, `.cr2`, `.nef`, `.arw`, `.dng` - Camera RAW formats

## Output

The script provides:

1. **Console Output**: Summary statistics and file listings
2. **CSV Export** (optional): Detailed report with columns:
   - Status (UNIQUE/DUPLICATE)
   - DuplicateCount
   - FileName
   - Directory
   - FullPath
   - SizeBytes, SizeKB, SizeMB
   - Hash (SHA256)
   - LastModified
   - Created

## Examples

### Example 1: Basic Search
```powershell
./FindPhotos.ps1 -Path "~/Pictures"
```

Output:
```
FindPhotos - Photo Discovery and Hash Generation Tool
============================================================
Searching path: /home/user/Pictures
Extensions: *.jpg, *.jpeg, *.png, ...

Found 150 photo file(s)

Generating file hashes...

============================================================
SUMMARY
============================================================
Total files processed: 150
Unique files: 130
Duplicate groups: 10
Total duplicate files: 20
Space wasted by duplicates: 45.6 MB
```

### Example 2: Find and Export Duplicates
```powershell
./FindPhotos.ps1 -Path "D:\Photos" -ShowDuplicatesOnly -OutputFile "duplicates.csv"
```

### Example 3: Specific Camera RAW Files
```powershell
./FindPhotos.ps1 -Path "E:\DCIM" -Extensions "*.cr2","*.nef","*.arw"
```

## How It Works

1. **Discovery**: Recursively searches the specified path for files matching photo extensions
2. **Hashing**: Computes SHA256 hash for each file to create unique fingerprint
3. **Analysis**: Groups files by hash to identify duplicates
4. **Reporting**: Displays summary statistics and file details
5. **Export**: Optionally exports detailed results to CSV

## Use Cases

- **Archive Planning**: Identify unique photos before backing up to save storage space
- **Photo Library Cleanup**: Find and remove duplicate photos across folders
- **Storage Optimization**: Calculate how much space duplicates are consuming
- **Photo Migration**: Ensure you're only copying unique files when consolidating libraries
- **Duplicate Detection**: Find identical photos with different names or in different locations

## Performance Notes

- Hash generation is I/O intensive and may take time for large collections
- Progress is displayed every 10 files processed
- Files are processed sequentially to manage memory usage
- For very large photo libraries (10,000+ files), consider processing in batches

## Troubleshooting

**Script won't run**: Ensure you're using PowerShell 7+
```powershell
pwsh --version
```

**Permission errors**: Run PowerShell as administrator or check file permissions

**Out of memory**: Process smaller directories or use filters to reduce file count

## License

This project is open source and available for use.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.
