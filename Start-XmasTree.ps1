<#

.SYNOPSIS
A PowerShell module for playing the Xmas Tree (Tower of Hanoi) puzzle game.

.DESCRIPTION
Implements a recursive subproblems code pattern.

This script CANNOT be started from the ISE because keypress detection is used.

This script MUST be started from a real PowerShell console window.

Please consider giving to cancer research.

.INPUTS
None.

.OUTPUTS
A whole lot of fun.

.EXAMPLE
.\Start-XmasTree.ps1
Starts the program.

.NOTES
Instead of disks and rods, this holiday-themed "Tower of Hanoi" game is played
with boughs and bases.

MIT License

Copyright (c) 2023 TigerPointe Software, LLC

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

History:
01.00 2023-Oct-31 Scott S. Initial release.

.LINK
https://github.com/tigerpointe

.LINK
https://en.wikipedia.org/wiki/Tower_of_Hanoi

.LINK
https://braintumor.org/

.LINK
https://www.cancer.org/

#>

# Requires -Version 5.1

# Define the ASCII artwork (original image by Scott S.)
# Each disk level must contain three rows of text
$ascii = @"
           _/^\_
          <  o  >
           /.^.\
            /"\ 
          ( o o )
          '"'"'"'
        ./'"'"'"'\.
        ( o  o  o )
        "'"'"'"'"'"
      ./"'"'"'"'"'"\.
      ( o  o   o  o )
      '"'"'"'"'"'"'"'
    ./'"'"'"'"'"'"'"'\.
    ( O  O   O   O  O )
    "'"'"'"'"'"'"'"'"'"
  ./"'"'"'"'"'"'"'"'"'"\.
  ( O  O   O   O   O  O )
  '"'"'"'"'"'"'"'"'"'"'"'
./'"'"'"'"'"'"'"'"'"'"'"'\.
( O  O   O   O   O   O  O )
 "'"'"'"'"'"'"'"'"'"'"'"'"
         '=,...,='
     ..--..]###[..--..
=============X=============
"@;

function Start-Gameplay
# Starts the gameplay.
{
  param
  (
      [int]$height = 2      # tower height
    , [bool]$solve = $false # solve automatically
  )

  # Sanity checks for the minimum/maximum tower height
  if ($height -lt 2)
  {
    $height = 2; # 2 requires 3 moves ((2 ** height) - 1)
  }
  elseif ($height -gt 7)
  {
    $height = 7; # 7 requires 127 moves ((2 ** height) - 1)
  }

  # Split the artwork into lines (padded to equal widths)
  $ascii = $ascii.Replace("`r", "");
  $lines = $ascii.Split("`n");
  $width = $lines[$lines.Count - 1].Length;
  for ($idx = 0; $idx -lt $lines.Count; $idx++)
  {
    $lines[$idx] = $lines[$idx].PadRight($width);
  }

  # Create a new dictionary for the game data (can be saved as JSON)
  $data = @{};

  # Initialize the A, B, C rods and disk numbers
  $data["A"] = New-Object System.Collections.ArrayList(,@($height..1));
  $data["B"] = New-Object System.Collections.ArrayList($null);
  $data["C"] = New-Object System.Collections.ArrayList($null);

  # Initialize the state variables
  $data["disk"]   = $null;   # disk currently being moved
  $data["height"] = $height; # height of the tower
  $data["n"]      = 0;       # number of moves counter

  function Write-Disks
  # Writes all the disks contained on each rod.
  {

    # Loop through all rods A, B, C disk levels in reverse order
    for ($x = ($data["height"] - 1); $x -ge 0; $x--)
    {

      # Set the default colors
      $colorA = [System.ConsoleColor]::Green;
      $colorB = [System.ConsoleColor]::Green;
      $colorC = [System.ConsoleColor]::Green;

      # Set rod A level as disk or spaces
      if ($x -lt $data["A"].Count)
      {
        $idx   = ($data["A"][$x] - 1) * 3;
        $outA1 = $lines[$idx];
        $outA2 = $lines[$idx + 1];
        $outA3 = $lines[$idx + 2];
        if ($data["A"][$x] -eq 1)
        {
          $colorA = [System.ConsoleColor]::Yellow; # special top color
        }
      }
      else
      {
        $outA1 = (" " * $lines[0].Length);
        $outA2 = $outA1;
        $outA3 = $outA1;
      }

      # Set rod B level as disk or spaces
      if ($x -lt $data["B"].Count)
      {
        $idx   = ($data["B"][$x] - 1) * 3;
        $outB1 = $lines[$idx];
        $outB2 = $lines[$idx + 1];
        $outB3 = $lines[$idx + 2];
        if ($data["B"][$x] -eq 1)
        {
          $colorB = [System.ConsoleColor]::Yellow; # special top color
        }
      }
      else
      {
        $outB1 = (" " * $lines[0].Length);
        $outB2 = $outB1;
        $outB3 = $outB1;
      }

      # Set rod C level as disk or spaces
      if ($x -lt $data["C"].Count)
      {
        $idx   = ($data["C"][$x] - 1) * 3;
        $outC1 = $lines[$idx];
        $outC2 = $lines[$idx + 1];
        $outC3 = $lines[$idx + 2];
        if ($data["C"][$x] -eq 1)
        {
          $colorC = [System.ConsoleColor]::Yellow; # special top color
        }
      }
      else
      {
        $outC1 = (" " * $lines[0].Length);
        $outC2 = $outC1;
        $outC3 = $outC1;
      }

      # Write the disk level for rods A, B, C
      Write-Host -NoNewline -ForegroundColor $colorA -Object $outA1;
      Write-Host -NoNewline -ForegroundColor $colorB -Object $outB1;
      Write-Host -NoNewline -ForegroundColor $colorC -Object $outC1;
      Write-Host;
      Write-Host -NoNewline -ForegroundColor $colorA -Object $outA2;
      Write-Host -NoNewline -ForegroundColor $colorB -Object $outB2;
      Write-Host -NoNewline -ForegroundColor $colorC -Object $outC2;
      Write-Host;
      Write-Host -NoNewline -ForegroundColor $colorA -Object $outA3;
      Write-Host -NoNewline -ForegroundColor $colorB -Object $outB3;
      Write-Host -NoNewline -ForegroundColor $colorC -Object $outC3;
      Write-Host;

    }

    # Write the rod bases A, B, C
    $color = [System.ConsoleColor]::DarkGray;
    $out   = $lines[$lines.Count - 3];
    Write-Host -NoNewline -ForegroundColor $color `
               -Object $out;
    Write-Host -NoNewline -ForegroundColor $color `
               -Object $out;
    Write-Host -NoNewline -ForegroundColor $color `
               -Object $out;
    Write-Host;
    $color = [System.ConsoleColor]::DarkGray;
    $out   = $lines[$lines.Count - 2];
    Write-Host -NoNewline -ForegroundColor $color `
               -Object $out;
    Write-Host -NoNewline -ForegroundColor $color `
               -Object $out;
    Write-Host -NoNewline -ForegroundColor $color `
               -Object $out;
    Write-Host;

    # Write the rod labels A, B, C
    $label  = $lines[$lines.Count - 1].Replace("=", " ");
    $labelA = $label.Replace("X", "A");
    $labelB = $label.Replace("X", "B");
    $labelC = $label.Replace("X", "C");
    Write-Host -BackgroundColor Red -ForegroundColor White `
               -Object "$labelA$labelB$labelC";

  }

  function Step-ToSolve
  # Solves the game using a recursive subproblems code pattern.
  {
    param
    (
        [int]$disk      # disk number
      , [string]$source # source rod
      , [string]$target # target rod
      , [string]$spare  # spare rod
    )

    # Stop the recursion when no more disks can be moved
    if ($disk -lt 1) { return; }

    # Recursively move the next disk from the source to the spare
    Step-ToSolve -disk ($disk - 1) `
                 -source $source -target $spare -spare $target;

    # Move the current disk from the source to the target
    $idx   = $data[$source].IndexOf($disk);
    $value = $data[$source][$idx];
    $data[$source].RemoveAt($idx);
    [void]$data[$target].Add($value);
    $data["n"] += 1;
    Write-Host -Object `
      ("Moving bough $disk from $source onto $target " + `
      "(move $($data["n"].ToString("N0")))");
    Write-Disks;
    Start-Sleep -Seconds 2;

    # Recursively move the next disk from the spare to the target
    Step-ToSolve -disk ($disk - 1) `
                 -source $spare -target $target -spare $source;

  }

  function Save-Game
  # Saves the game data to a file.
  {
    $file = "$($PSCommandPath).txt";
    $content = (ConvertTo-Json -InputObject $data);
    $content | Set-Content -Path $file;
    Write-Host -Object "Game saved: $file";
    return $true;
  }

  function Restore-Game
  # Restores the game data from a file.
  # Converts JSON dot notation objects into array lists.
  {
    $file = "$($PSCommandPath).txt";
    if (Test-Path -Path $file)
    {
      $content = (Get-Content -Path $file);
      $object = ($content | ConvertFrom-Json);
      $data["A"] = New-Object System.Collections.ArrayList(,$object.A);
      $data["B"] = New-Object System.Collections.ArrayList(,$object.B);
      $data["C"] = New-Object System.Collections.ArrayList(,$object.C);
      $data["disk"]   = $object.disk;
      $data["height"] = $object.height;
      $data["n"]      = $object.n;
      Write-Host -Object "Game restored: $file";
      Write-Disks;
      if ($null -ne $data["disk"])
      {
        Write-Host -Object "Moving bough $($data["disk"]) onto ...";
      }
    }
    else
    {
      Write-Host -Object "File not found: $file";
    }
    return $true;
  }

  function Move-Disk
  # Moves a disk between rods.
  {
    param
    (
        $rod # rod name (A, B or C)
    )

    # If unset, pop the top disk from the source rod
    if (($null -eq $data["disk"]) -and ($data[$rod].Count -gt 0))
    {
      $idx = ($data[$rod].Count - 1);
      $data["disk"] = $data[$rod][$idx];
      $data[$rod].RemoveAt($idx);
      Write-Host -Object `
        "Moving bough $($data["disk"]) from $rod onto ...";
    }

    # Otherwise, append the popped disk to the target rod
    elseif ($null -ne $data["disk"])
    {
      $top = $null;
      if ($data[$rod].Count -gt 0)
      {
        $idx = ($data[$rod].Count - 1);
        $top = $data[$rod][$idx];
      }
      if (($null -eq $top) -or ($data["disk"] -lt $top))
      {
        [void]$data[$rod].Add($data["disk"]);
        $data["disk"] = $null;
        $data["n"]   += 1;
        Write-Host -Object "  ... $rod (move $($data["n"].ToString("N0")))";
        Write-Disks;
      }
      else
      {
        Write-Host -Object "  ... invalid move onto $rod, try again";
      }

    }

    # Check for a solution (all disks having been moved)
    if ($data["C"].Count -lt $data["height"])
    {
      return $true; # not solved, continue listening
    }
    $label = "moves";
    if ($data["n"] -eq 1) { $label = "move"; }
    Write-Host -Object `
      "Success, puzzle solved in $($data["n"].ToString("N0")) $label";
    return $false; # solved, stop listening

  }

  function Invoke-OnPress
  # Invokes the keypress event.
  {
    param
    (
        [ConsoleKey]$key # pressed key
    )
    switch ($key)
    {
      A       { return Move-Disk -rod 'A'; }
      B       { return Move-Disk -rod 'B'; }
      C       { return Move-Disk -rod 'C'; }
      L       { return Restore-Game; }
      R       { return Restore-Game; }
      S       { return Save-Game;    }
      Q       { return $false; }
      Escape  { return $false; }
      default { return $true;  } # for any other key, continue listening
    }
  }

  # Show the solution, if specified
  if ($solve)
  {
    Write-Host -Object "Solving, please wait ...`r`n";
    Write-Disks;
    Start-Sleep -Seconds 4;
    Step-ToSolve -disk $data["height"] -source "A" -target "C" -spare "B";
    return;
  }

  # Sanity check for the integrated scripting environment (ISE) and exit
  if ($null -ne $psISE)
  {
    throw "An interactive game can only be started from the console window.";
  }

  # Otherwise, begin listening for keypresses until False is returned
  Write-Host -Object "Good luck, move boughs by pressing A, B, or C ...`r`n";
  Write-Disks;
  $running = $true;
  while ($running)
  {

    # Wait for a keypress (blocking code pattern)
    $read = [Console]::ReadKey($true); # true = do not echo key value
    $running = Invoke-OnPress($read.Key);

  }

}

# Start the program interactively
try
{
  Clear-Host;
  Write-Host -BackgroundColor Red -ForegroundColor White `
             -Object "         THE XMAS TREE GAME (TOWER OF HANOI)         ";
  [int]$height = Read-Host -Prompt `
                   "Enter the Xmas tree height/difficulty level [2-7]";
  $solve = " ";
  while (-not "yn".Contains($solve))
  {
    $solve = Read-Host -Prompt `
               "Do you want the computer to play itself? [Y|N]";
    $solve = $solve.ToLower();
  }
  Write-Host -Object "  Move all of the boughs from base A to base C";
  Write-Host -Object "  Press A, B, or C to move a bough between two bases";
  Write-Host -Object `
    "  A larger bough cannot be placed on top of a smaller bough";
  Write-Host -Object `
    "  Each bough is numbered according to its ornament count";
  Write-Host -Object `
    "  Press S to save the game, R or L to restore/load a saved game";
  Write-Host -Object "  Press ESC or Q to quit";
  Start-Gameplay -height $height -solve ($solve -eq "y");
  Write-Host -ForegroundColor Cyan `
             -Object "MERRY CHRISTMAS AND HAPPY HOLIDAYS";
}
catch
{
  Write-Error -Message $_.Exception.Message;
}
finally
{
  Read-Host -Prompt "Press the ENTER key to exit the game";
}