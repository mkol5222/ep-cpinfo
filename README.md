# EP CPinfo Tools
Assume you have folder fill of Harmony ENDPOINT CPinfo files
and need accelerate way to get to relevant logs.

This repo is set of PowerShell functions for ZIP and CPinfo handling.

# INSTALLATION

```
PS> git clone https://github.com/mkol5222/ep-cpinfo.git
# load into current
PS> . ./ep-cpinfo/ep-cpinfo.git
```

## DEPENDENCIES
Using Out-ConsoleGridView for menu system
```
PS> Install-Module Microsoft.PowerShell.ConsoleGuiTools
PS> Import-Module Microsoft.PowerShell.ConsoleGuiTools
```

# USAGE

## Get certain file content
```
# choose and pipe to your filtering/processing commands
PS> Get-SelectedZipEntryContent -Filter cpda.log | select -First 5
```

## Extract file
```
# choose and extract
PS> Extract-SelectedZipEntry -Filter msinfo.nfo
# use it
PS> start ./msinfo.nfo
```

# GENERAL TOOLS

## Get list of files in ZIP archive
```
PS> Get-ZipEntries $PWD/cpinfo.PC007.02_08_2021_08_57.zip
``` 

## Extract file from ZIP archive
```
PS> Extract-ZipEntry $PWD/cpinfo.PC007.02_08_2021_08_57.zip Forensics\Files\ProgramData\CheckPoint\Logs\EFRService.log
``` 

## Choose file in menu
```
PS> $f = Get-ChildItem -Recurse '*.zip' | Out-ConsoleGridView -OutputMode Single
# use it later
PS> $f
``` 