param(
    [Parameter(Mandatory)]
    [string]$FileName,

    [int]$LinesCount = 1
)

$FileName = (Get-Item -Path $FileName).FullName
echo $FileName

$lines = Get-Content -Path $FileName

if ($lines.Length -lt $LinesCount)
{
    $LineCount = $lines.Length;
}

$lines_not_in_exercise = $lines.Length - $LinesCount 

$delta = 0
if ($lines_not_in_exercise -gt 0)
{
    $delta = Get-Random $lines_not_in_exercise
}

$ExerciseName = $FileName + ".exercise";
if( Test-Path -Path $ExerciseName )
{
    echo "exercise name exist!";
    return;
}

for ($i = 0; $i -lt $delta; $i++)
{
    $lines[$i] | Out-File $ExerciseName -Append
}

$totalCharactesCount = 0;

for ($i = $delta; $i -lt ($delta + $LinesCount); $i++)
{
    "" | Out-File $ExerciseName -Append
    $totalCharactesCount += $lines[$i].Length;
}


for ($i = ($delta + $LinesCount); $i -lt $lines.Length; $i++)
{
    $lines[$i] | Out-File $ExerciseName -Append
}

$hx_line = $delta + 1;

wezterm-gui --config-file (Join-Path $PSScriptRoot .wezterm_back.lua) start -- hx -w $PSScriptRoot ("$FileName" + ":$hx_line")
sleep 0.1
$start = Get-Date;

$buf = $env:WEZTERM_LOG
$env:WEZTERM_LOG = "wezterm_gui=info"
$lines = wezterm --config-file (Join-Path $PSScriptRoot .wezterm_front.lua) start -- hx -w $PSScriptRoot ("$ExerciseName" + ":$hx_line") *>&1
$env:WEZTERM_LOG = $buf
git diff --no-index $FileName $ExerciseName

$pattern = "(\d{2}):(\d{2}):(\d{2})\.(\d{3})  INFO   wezterm_gui::termwindow::keyevent > key_event KeyEvent \{.*key: ([^,]*), modifiers: ([^,]*), .* key_is_down: (\w+), raw.*\}"

if( $LastExitCode -eq 0 )
{
    $keyPressedCount = 0;
    $lines | Select-String -Pattern $pattern |
    Foreach-Object {
        $mHour, $mMin, $mSec, $mMillisec, $mKey, $mModifiers, $mIsKeyDown = $_.Matches[0].Groups[1..7].Value
        if ( ($mKey.substring(0, 4) -eq "Char") -and ($mIsKeyDown -eq "true") ) {
            $keyPressedCount++;
            # [PSCustomObject] @{
            #     Time = [int]$mHour*60*60*1000 + [int]$mMin*60*1000 + [int]$mSec*1000 + [int]$mMillisec
            #     Key = $mKey
            #     Modifiers = $mModifiers
            #     IsKeyDown = $mIsKeyDown -eq "true"
            # }
        }
    }

    $time = (Get-Date) - $start;
    echo ("Complete with {0:mm}:{0:ss}.{1:000}" -f $time, ($time.Milliseconds))
    echo "Characters $totalCharactesCount"
    echo "Key Pressed Count $keyPressedCount"
    echo ("Speed {0:f2} char/min" -f ($totalCharactesCount/$time.TotalMinutes))
    echo ("Char/Key Ratio {0:f2} %" -f (100.0 * $totalCharactesCount/$keyPressedCount))
}
else
{
    echo "Exercise fault!"
}


rm $ExerciseName
