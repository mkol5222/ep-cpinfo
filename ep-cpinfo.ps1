
# Module is using console grid view UI. You may be required to:
#   Install-Module Microsoft.PowerShell.ConsoleGuiTools
#   Import-Module Microsoft.PowerShell.ConsoleGuiTools

# get all CPinfo archives in currect folder and subfolders
function Get-CPInfoFiles () {
    Get-ChildItem -Recurse 'cpinfo.*.*.zip'
}

# give choice of CPinfo archives in current directory tree
function Select-CPInfoFile () {
    Get-CPInfoFiles | Out-ConsoleGridView -OutputMode Single
}

# .NET ZIP file support
[Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') | Out-Null

function isValidZipPath($Path) {
    if (-Not ($Path | Test-Path) ) {
        throw "File or folder does not exist"
    }
    if (-Not ($Path | Test-Path -PathType Leaf) ) {
        throw "The Path argument must be a file. Folder paths are not allowed."
    }
    if ($Path -notmatch "(\.zip)") {
        throw "The file specified in the path argument must be zip"
    }
    return $true 
}

# list of all files in archive
function Get-ZipEntries {
    param(
        [ValidateScript({
                return isValidZipPath($_)
            })]
        [System.IO.FileInfo]$Path
    )
    [IO.Compression.ZipFile]::OpenRead($Path).Entries
}

# select one of files in archive
function Select-ZipEntry {
    param(
        [ValidateScript({
                return isValidZipPath($_)
            })]
        [System.IO.FileInfo]$Path,
        [String] $Filter
    )
    Get-ZipEntries $Path | Out-ConsoleGridView -OutputMode Single -Filter $Filter
}

# give choice of CPinfo archive and contained files
function Select-CPInfoFileAndZipEntry  {
    param
    (
      [String]
      $Filter
    )
    # Write-Host "Select-CPInfoFileAndZipEntry Filter $Filter"
    $zipFile = Select-CPInfoFile
    if ($zipFile) {
        $entry = Get-ZipEntries $zipFile.FullName | Out-ConsoleGridView -OutputMode Single -Filter $Filter
    }
    else {
        $entry = $null
    }
    return [PSCustomObject]@{ZipFileName = $zipFile.FullName; EntryFileName = $entry.FullName }
}

# extract archived file content to pipe
function Get-ZipEntryContent {
    param(
        [ValidateScript({
                return isValidZipPath($_)
            })]
        [System.IO.FileInfo]$zipFilename,
        [String]$entryFullname
    )
    $zip = [io.compression.zipfile]::OpenRead($zipFilename)
    if ($zip) {
        $files = ($zip.Entries | Where-Object { $_.FullName -eq $entryFullname })
        if (!$files) {
            throw "ZIP entry '${entryFullname}' not found"
        }
        $file = $files[0]
        if ($file) {
            $stream = $file.Open()
 
            $reader = New-Object IO.StreamReader($stream)
            while ( $text = $reader.ReadLine() ) {
                Write-Output $text
            }
       
            $reader.Close()
            $stream.Close()
        }
        else {
            throw "Unable to read '${entryFullname}' from ZIP"
        }
        $zip.Dispose()
    }
}

# choose archive file and pipe it
function Get-SelectedZipEntryContent {
    param
    (
      [String]
      $Filter
    )
    # Write-Host "Get-SelectedZipEntryContent Filter $Filter"

    $files = Select-CPInfoFileAndZipEntry -Filter $Filter
    if ($files) {
        Get-ZipEntryContent $files.ZipFileName $files.EntryFileName
    }
}

# extract file from ZIP to current folder
function Extract-ZipEntry {
    param(
        [ValidateScript({
                return isValidZipPath($_)
            })]
        [System.IO.FileInfo]$zipFilename,
        [String]$entryFullname
    )

    $zip = [io.compression.zipfile]::OpenRead($zipFilename)
    $files = ($zip.Entries | Where-Object { $_.FullName -eq $entryFullname })
    if (!$files) {
        throw "ZIP entry '${entryFullname}' not found in '$zipFilename'"
    }
    $file = $files[0]
    if ($file) {
        if ("$PWD/$($file.Name)" | Test-Path) {
            throw "File '$PWD/$($file.Name)' already exists"
        }
        Write-Host "Extracting $PWD/$($file.Name)"
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($file, "$PWD/$($file.Name)", $true)
    }
    $zip.Dispose()
}

# choose and extract one file
function Extract-SelectedZipEntry {
    param
    (
      [String]
      $Filter
    )
    # Write-Host "Extract-SelectedZipEntry Filter $Filter"

    $files = Select-CPInfoFileAndZipEntry -Filter $Filter
    if ($files) {
        Extract-ZipEntry $files.ZipFileName $files.EntryFileName
    }
}