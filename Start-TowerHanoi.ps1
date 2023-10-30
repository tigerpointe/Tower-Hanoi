<#

.SYNOPSIS
A PowerShell module for playing the Tower of Hanoi puzzle game.

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
.\Start-TowerHanoi.ps1
Starts the program.

.NOTES
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
01.00 2023-Oct-19 Scott S. Initial release.
01.01 2023-Oct-25 Scott S. Approved verbs for function names.

.LINK
https://en.wikipedia.org/wiki/Tower_of_Hanoi

.LINK
https://braintumor.org/

.LINK
https://www.cancer.org/

#>

# Requires -Version 5.1

function Start-Gameplay
# Starts the gameplay.
{
  param
  (
      [int]$height = 0      # tower height
    , [bool]$solve = $false # solve automatically
  )

  # Sanity check for the maximum tower height
  if ($height -gt 12)
  {               # 12 requires 4,095 moves ((2 ** height) - 1)
    $height = 12; # higher values are unlikely to be playable
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
  # The maximum width of each disk is two times the tower height.  Repeat
  # the disk character based on the numeric disk value and RIGHT-justify
  # to half of the maximum width (i.e., the height).  Next, slice enough
  # characters from the tail to hold the numeric label.  Then, repeat the
  # disk character again based on the numeric disk value and LEFT-justify
  # to the other half of the maximum width (i.e., the height again).
  {
    for ($x = ($data["height"] - 1); $x -ge 0; $x--)
    {
      if ($x -lt $data["A"].Count)
      {
        $outA = ("=" * $data["A"][$x]).PadLeft($data["height"]);
        $outA = $outA.Substring(0, `
                  $outA.Length - $data["A"][$x].ToString().Length);
        $outA = $outA + $data["A"][$x].ToString();
        $outA = $outA + ("=" * $data["A"][$x]).PadRight($data["height"]);
      }
      else
      {
        $outA = "|".PadLeft($data["height"]);
        $outA = $outA + " ".PadRight($data["height"]);
      }
      if ($x -lt $data["B"].Count)
      {
        $outB = ("=" * $data["B"][$x]).PadLeft($data["height"]);
        $outB = $outB.Substring(0, `
                  $outB.Length - $data["B"][$x].ToString().Length);
        $outB = $outB + $data["B"][$x].ToString();
        $outB = $outB + ("=" * $data["B"][$x]).PadRight($data["height"]);
      }
      else
      {
        $outB = "|".PadLeft($data["height"]);
        $outB = $outB + " ".PadRight($data["height"]);
      }
      if ($x -lt $data["C"].Count)
      {
        $outC = ("=" * $data["C"][$x]).PadLeft($data["height"]);
        $outC = $outC.Substring(0, `
                  $outC.Length - $data["C"][$x].ToString().Length);
        $outC = $outC + $data["C"][$x].ToString();
        $outC = $outC + ("=" * $data["C"][$x]).PadRight($data["height"]);
      }
      else
      {
        $outC = "|".PadLeft($data["height"]);
        $outC = $outC + " ".PadRight($data["height"]);
      }
      Write-Host -Object "  : $($outA) $($outB) $($outC)";
    }
    Write-Host -NoNewline -Object "  : ";
    Write-Host -NoNewline -Object "A".PadLeft($data["height"]);
    Write-Host -NoNewline -Object " ".PadRight($data["height"]);
    Write-Host -NoNewline -Object " ";
    Write-Host -NoNewline -Object "B".PadLeft($data["height"]);
    Write-Host -NoNewline -Object " ".PadRight($data["height"]);
    Write-Host -NoNewline -Object " ";
    Write-Host -NoNewline -Object "C".PadLeft($data["height"]);
    Write-Host -NoNewline -Object " ".PadRight($data["height"]);
    Write-Host;
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
      ("`r`nMoving disk $disk from $source onto $target " + `
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
      Write-Host -Object "`r`nGame restored: $file";
      Write-Disks;
      if ($null -ne $data["disk"])
      {
        Write-Host -Object "`r`nMoving disk $($data["disk"]) onto ...";
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
        "`r`nMoving disk $($data["disk"]) from $rod onto ...";
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
    Write-Host -Object "`r`nSolving, please wait ...";
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
  Write-Host -Object "`r`nGood luck, move disks by pressing A, B, or C ...";
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
  Write-Host -Object "`r`nTHE TOWER OF HANOI";
  [int]$height = Read-Host -Prompt `
                   "Please enter a height for the tower [0-12]";
  $solve = " ";
  while (-not "yn".Contains($solve))
  {
    $solve = Read-Host -Prompt `
               "Do you want the computer to play itself? [Y|N]";
    $solve = $solve.ToLower();
  }
  Write-Host -Object "  Move all of the disks from rod A to rod C";
  Write-Host -Object "  Press A, B, or C to move a disk between two rods";
  Write-Host -Object `
    "  A larger disk cannot be placed on top of a smaller disk";
  Write-Host -Object `
    "  Press S to save the game, R or L to restore/load a saved game";
  Write-Host -Object "  Press ESC or Q to quit";
  Start-Gameplay -height $height -solve ($solve -eq "y");
  Read-Host -Prompt "Press the ENTER key to exit the game";
}
catch
{
  Write-Error -Message $_.Exception.Message;
}