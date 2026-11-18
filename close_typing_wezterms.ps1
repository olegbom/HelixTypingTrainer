param(
    [Parameter(Mandatory)]
    [string]$FileName
)

function Get-WindowByTitle($WindowTitle="*")
{
    Write-Verbose "WindowTitle is: $WindowTitle"
    if($WindowTitle -eq "*")
    {
        Write-Verbose "WindowTitle is *, print all windows title"
        Get-Process | Where-Object {$_.MainWindowTitle}
    }
    else
    {
        Write-Verbose "WindowTitle is $WindowTitle"
        Get-Process | Where-Object {$_.MainWindowTitle -like "*$WindowTitle*"}
    }
}

function StopWezterm($window_name)
{
    $window = Get-WindowByTitle $window_name
    if($window)
    {
        Stop-Process -InputObject $window
    }
}

git diff --no-index ($FileName.Substring(0, $FileName.Length - 9)) $FileName 

if( $LastExitCode -eq 0 )
{
    StopWezterm "TypingWeztermHelixBack"
    StopWezterm "TypingWeztermHelixFront"
}



