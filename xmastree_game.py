#!/usr/bin/env python3
""" A Python module for playing the Xmas Tree (Tower of Hanoi) puzzle game.
https://github.com/tigerpointe
https://en.wikipedia.org/wiki/Tower_of_Hanoi
History:
01.00 2023-Oct-31 Scott S. Initial release.

Instead of disks and rods, this holiday-themed "Tower of Hanoi" game is played
with boughs and bases.

ANSI Color Escape Codes, ESC = \033 (ASCII Hex Value)
(ex. foreground black '\033[30m' and background white '\033[47m')
COLOR   FG BG
Reset   0  0
Black   30 40
Red     31 41
Green   32 42
Yellow  33 43
Blue    34 44
Magenta 35 45
Cyan    36 46
White   37 47
Default 39 49
Gray    90 100 (Bright Black)

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

Please consider giving to cancer research.
https://braintumor.org/
https://www.cancer.org/
"""

# Requires:  pip install pynput
# (using a keypress library improves the game playability over text inputs)
from pynput.keyboard import Key, Listener
import json
import os
import time

# Enable the console escape codes
os.system('')

# Define the ASCII artwork (original image by Scott S.)
# Each disk level must contain three rows of text
# Escape the backslashes and double-quotes
ascii = """
          _/^\\_
         <  o  >
          /.^.\\
           /\"\\
         ( o o )
         '\"'\"'\"'
       ./'\"'\"'\"'\\.
       ( o  O  o )
       \"'\"'\"'\"'\"'\"
     ./\"'\"'\"'\"'\"'\"\\.
     ( o  O   O  o )
     '\"'\"'\"'\"'\"'\"'\"'
   ./'\"'\"'\"'\"'\"'\"'\"'\\.
   ( o  O   o   O  o )
   \"'\"'\"'\"'\"'\"'\"'\"'\"'\"
 ./\"'\"'\"'\"'\"'\"'\"'\"'\"'\"\\.
 ( o  O   o   o   O  o )
 '\"'\"'\"'\"'\"'\"'\"'\"'\"'\"'\"'
/'\"'\"'\"'\"'\"'\"'\"'\"'\"'\"'\"'\\
.o  O   o   O   o   O  o.
\"'\"'\"'\"'\"'\"'\"'\"'\"'\"'\"'\"'\"
        '=,...,='
    ..--..]###[..--..
============X============
"""


def play(height=2, solve=False):
    """ Starts the gameplay.
    PARAMETERS:
    height : tower height
    solve  : solve automatically
    """

    # Sanity checks for the minimum/maximum tower height
    if (height < 2):
        height = 2  # 2 requires 3 moves ((2 ** height) - 1)
    elif (height > 7):
        height = 7  # 7 requires 127 moves ((2 ** height) - 1)

    # Split the artwork into lines (padded to equal widths)
    lines = ascii.splitlines()
    del lines[0]
    width = len(lines[len(lines) - 1])
    for idx in range(len(lines)):
        lines[idx] = lines[idx].rstrip()
        lines[idx] = lines[idx].ljust(width)

    # Create a new dictionary for the game data (can be saved as JSON)
    data = {}

    # Initialize the A, B, C rods and disk numbers
    data['A'] = list((x + 1) for x in reversed(range(height)))
    data['B'] = list()
    data['C'] = list()

    # Initialize the state variables
    data['disk'] = None      # disk currently being moved
    data['height'] = height  # height of the tower
    data['n'] = 0            # number of moves counter

    def write_disks():
        """ Writes all the disks contained on each rod."""

        # Loop through all rods A, B, C disk levels in reverse order
        for x in reversed(range(data['height'])):

            # Set the default colors
            colorA = '\033[32m'
            colorB = '\033[32m'
            colorC = '\033[32m'
            small = '\033[35mo\033[32m'
            large = '\033[36mO\033[32m'
            reset = '\033[0m'

            # Set rod A level as disk or spaces
            if (x < len(data['A'])):
                idx = (data['A'][x] - 1) * 3
                outA1 = lines[idx]
                outA2 = lines[idx + 1]
                outA3 = lines[idx + 2]
                if ((data['A'][x] == 1)):
                    colorA = '\033[33m'  # special top color
                else:
                    outA2 = outA2.replace('o', small)  # ornament color
                    outA2 = outA2.replace('O', large)  # ornament color
            else:
                outA1 = ' ' * len(lines[0])
                outA2 = outA1
                outA3 = outA1

            # Set rod B level as disk or spaces
            if (x < len(data['B'])):
                idx = (data['B'][x] - 1) * 3
                outB1 = lines[idx]
                outB2 = lines[idx + 1]
                outB3 = lines[idx + 2]
                if ((data['B'][x] == 1)):
                    colorB = '\033[33m'  # special top color
                else:
                    outB2 = outB2.replace('o', small)  # ornament color
                    outB2 = outB2.replace('O', large)  # ornament color
            else:
                outB1 = ' ' * len(lines[0])
                outB2 = outB1
                outB3 = outB1

            # Set rod C level as disk or spaces
            if (x < len(data['C'])):
                idx = (data['C'][x] - 1) * 3
                outC1 = lines[idx]
                outC2 = lines[idx + 1]
                outC3 = lines[idx + 2]
                if ((data['C'][x] == 1)):
                    colorC = '\033[33m'  # special top color
                else:
                    outC2 = outC2.replace('o', small)  # ornament color
                    outC2 = outC2.replace('O', large)  # ornament color
            else:
                outC1 = ' ' * len(lines[0])
                outC2 = outC1
                outC3 = outC1

            # Write the disk level for rods A, B, C
            print(colorA, outA1, colorB, outB1, colorC, outC1, reset, sep='')
            print(colorA, outA2, colorB, outB2, colorC, outC2, reset, sep='')
            print(colorA, outA3, colorB, outB3, colorC, outC3, reset, sep='')

        # Write the rod bases A, B, C
        color = '\033[90m'
        reset = '\033[0m'
        out = lines[len(lines) - 3]
        print(color, out, out, out, reset, sep='')
        out = lines[len(lines) - 2]
        print(color, out, out, out, reset, sep='')

        # Write the rod labels A, B, C
        color = '\033[37m\033[41m'
        reset = '\033[0m'
        label = (lines[len(lines) - 1]).replace('=', ' ')
        labelA = label.replace('X', 'A')
        labelB = label.replace('X', 'B')
        labelC = label.replace('X', 'C')
        print(color, labelA, labelB, labelC, reset, sep='')

    def solve_game(disk, source, target, spare):
        """ Solves the game using a recursive subproblems code pattern.
        PARAMETERS:
        disk   : disk number
        source : source rod
        target : target rod
        spare  : spare rod
        """

        # Stop the recursion when no more disks can be moved
        if (disk < 1):
            return

        # Recursively move the next disk from the source to the spare
        solve_game(disk=(disk - 1), source=source, target=spare, spare=target)

        # Move the current disk from the source to the target
        data[target].append(data[source].pop(data[source].index(disk)))
        data['n'] += 1
        print('Moving bough', disk, 'from', source, 'onto', target,
              f"(move {data['n']:,})")
        write_disks()
        time.sleep(2)

        # Recursively move the next disk from the spare to the target
        solve_game(disk=(disk - 1), source=spare, target=target, spare=source)

    def save_game():
        """ Saves the game data to a file."""
        file = os.path.basename(__file__) + '.txt'
        f = open(file, 'w')
        f.write(json.dumps(data))
        f.close()
        print('Game saved:', file)
        return True

    def reload_game():
        """ Reloads the game data from a file."""
        nonlocal data  # required for assigning a new value
        file = os.path.basename(__file__) + '.txt'
        if (os.path.isfile(file)):
            f = open(file, 'r')
            data = json.loads(f.read())
            f.close()
            print('Game reloaded:', file)
            write_disks()
            if ((data['disk']) is not None):
                print('Moving bough', data['disk'], 'onto ...')
        else:
            print('File not found:', file)
        return True

    def move_disk(rod):
        """Moves a disk between rods.
        PARAMETERS:
        rod : rod name (A, B or C)
        """

        # If unset, pop the top disk from the source rod
        if (data['disk'] is None) and (len(data[rod]) > 0):
            data['disk'] = data[rod].pop()
            print('Moving bough', data['disk'], 'from', rod, 'onto ...')

        # Otherwise, append the popped disk to the target rod
        elif (data['disk'] is not None):
            top = None
            if (len(data[rod]) > 0):
                top = data[rod][-1]
            if (top is None) or (data['disk'] < top):
                data[rod].append(data['disk'])
                data['disk'] = None
                data['n'] += 1
                print('  ...', rod, f"(move {data['n']:,})")
                write_disks()
            else:
                print('  ... invalid move onto ', rod, ', try again', sep='')

        # Check for a solution (all disks having been moved)
        if (len(data['C']) < data['height']):
            return True  # not solved, continue listening
        label = 'moves'
        if (data['n'] == 1):
            label = 'move'
        print('Success, puzzle solved in', f"{data['n']:,}", label)
        return False  # solved, stop listening

    def on_press(key):
        """Handles the keypress event.
        PARAMETERS:
        key : pressed key
        """
        if (hasattr(key, 'char')):
            if (key.char == 'a'):
                return move_disk(rod='A')
            elif (key.char == 'b'):
                return move_disk(rod='B')
            elif (key.char == 'c'):
                return move_disk(rod='C')
            elif (key.char == 'l'):
                return reload_game()
            elif (key.char == 'r'):
                return reload_game()
            elif (key.char == 's'):
                return save_game()
            elif (key.char == 'q'):
                return False
        else:
            if (key == Key.esc):
                return False
        return True  # for any other key, continue listening

    # Show the solution, if specified
    if (solve):
        print('Solving, please wait ...\r\n')
        write_disks()
        time.sleep(4)
        solve_game(disk=data['height'], source='A', target='C', spare='B')
        return

    # Otherwise, begin listening for keypresses until False is returned
    # (suppress input events from being passed back to the console)
    print('Good luck, move boughs by pressing A, B, or C ...\r\n')
    write_disks()
    with Listener(on_press=on_press, suppress=True) as lstn:
        lstn.join()


def clear():
    """Clears the console."""
    if (os.name == 'nt'):
        _ = os.system('cls')  # Microsoft Windows
    else:
        _ = os.system('clear')  # all others


# Start the program interactively
if __name__ == '__main__':
    try:
        clear()
        color = '\033[37m\033[41m'
        reset = '\033[0m'
        print(color, '         THE XMAS TREE GAME (TOWER OF HANOI)         ',
              reset, sep='')
        height = int(
            input('Enter the Xmas tree height/difficulty level [2-7]: '))
        solve = None
        while (solve != 'y') and (solve != 'n'):
            solve = input('Do you want the computer to play itself? [Y|N]: ')
            solve = solve.lower()
        print('  Move all of the boughs from base A to base C')
        print('  Press A, B, or C to move a bough between two bases')
        print('  A larger bough cannot be placed on top of a smaller bough')
        print('  Each bough is numbered according to its ornament count')
        print('  Press S to save the game, R or L to reload a saved game')
        print('  Press ESC or Q to quit')
        play(height=height, solve=(solve == 'y'))
        color = '\033[36m'
        reset = '\033[0m'
        print(color, 'MERRY CHRISTMAS AND HAPPY HOLIDAYS', reset, sep='')
    except Exception as e:
        print(str(e))
    finally:
        print('\033[0m', end='')  # tidy up, just in case
        input('Press the ENTER key to exit the game: ')
