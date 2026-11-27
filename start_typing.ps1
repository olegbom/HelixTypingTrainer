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

$totalCharsCount = 0;

for ($i = $delta; $i -lt ($delta + $LinesCount); $i++)
{
    "" | Out-File $ExerciseName -Append
    $totalCharsCount += $lines[$i].Length;
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
    $deletePressedCount = 0;
    $lines | Select-String -Pattern $pattern |
    Foreach-Object {
        $mHour, $mMin, $mSec, $mMillisec, $mKey, $mModifiers, $mIsKeyDown = $_.Matches[0].Groups[1..7].Value
        if ( ($mKey.substring(0, 4) -eq "Char") -and ($mIsKeyDown -eq "true") ) {
            $keyPressedCount++;
            if( $mKey -eq "Char('\u{8}')" )
            {
                $deletePressedCount++;
            }
            # [PSCustomObject] @{
            #     Time = [int]$mHour*60*60*1000 + [int]$mMin*60*1000 + [int]$mSec*1000 + [int]$mMillisec
            #     Key = $mKey
            #     Modifiers = $mModifiers
            #     IsKeyDown = $mIsKeyDown -eq "true"
            # }
        }
    }

    $time = (Get-Date) - $start;
    $results = @(
        [PSCustomObject] @{ Parameter = "Duration"; Value = "{0:mm}:{0:ss}.{1:000}" -f $time, ($time.Milliseconds) }
        [PSCustomObject] @{ Parameter = "Characters"; Value = "$totalCharsCount" }
        [PSCustomObject] @{ Parameter = "Key Pressed"; Value = "$keyPressedCount" }
        [PSCustomObject] @{ Parameter = "Delete Pressed"; Value = "$deletePressedCount" }
        [PSCustomObject] @{ Parameter = "Speed"; Value = "{0:f2} char/min" -f ($totalCharsCount/$time.TotalMinutes) }
        [PSCustomObject] @{ Parameter = "Char/Key Ratio"; Value = "{0:f2} %" -f (100.0 * $totalCharsCount/$keyPressedCount) }
        [PSCustomObject] @{ Parameter = "1 - Delete/Char"; Value = "{0:f2} %" -f (100.0 * (1 - $deletePressedCount/$totalCharsCount)) }
    )

    $results | Format-Table
}
else
{
    echo "Exercise fault!"
}


rm $ExerciseName
