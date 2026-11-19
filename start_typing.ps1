param(
    [Parameter(Mandatory)]
    [string]$FileName,

    [int]$LinesCount = 1
)

$FileName = (Get-Item -Path $FileName).FullName

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
wezterm --config-file (Join-Path $PSScriptRoot .wezterm_front.lua) start -- hx -w $PSScriptRoot ("$ExerciseName" + ":$hx_line")

git diff --no-index $FileName $ExerciseName

if( $LastExitCode -eq 0 )
{
    $time = (Get-Date) - $start;
    echo ("Complete with {0:mm}:{0:ss}.{1:000}" -f $time, ($time.Milliseconds))
    echo "Characters $totalCharactesCount"
    echo ("Speed {0:f2} char/min" -f ($totalCharactesCount/$time.TotalMinutes))
}
else
{
    echo "Exercise fault!"
}

rm $ExerciseName

