# Helix Typing Trainer

This repository is a set of scripts for `pwsh` that allow you to practice typing.

## How it work

For start:

``` pwsh
./start_typing.ps1 [FILENAME] [NUMBER OF LINES] 
```

## Dependencies

- Git
- Helix
- Powershell
- Wezterm

## Tips

If you have a code repository and want to practice typing from it, you can use the following trick:

``` pwsh
.\start_typing.ps1 (Get-Random (ls [PATH TO REPO] -Recurse -Filter "*.c")) 15
```
