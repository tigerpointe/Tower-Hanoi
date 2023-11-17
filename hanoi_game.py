#!/usr/bin/env python3
""" A Python module for playing the Tower of Hanoi puzzle game.
https://en.wikipedia.org/wiki/Tower_of_Hanoi
History:
01.00 2023-Oct-16 Scott S. Initial release.

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


def play(height=0, solve=False):
    """ Starts the gameplay.
    PARAMETERS:
    height : tower height
    solve  : solve automatically
    """

    # Sanity check for the maximum tower height
    if (height > 12):  # 12 requires 4,095 moves ((2 ** height) - 1)
        height = 12    # higher values are unlikely to be playable

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
        """ Writes all the disks contained on each rod.
        The maximum width of each disk is two times the tower height.  Repeat
        the disk character based on the numeric disk value and RIGHT-justify
        to half of the maximum width (i.e., the height).  Next, slice enough
        characters from the tail to hold the numeric label.  Then, repeat the
        disk character again based on the numeric disk value and LEFT-justify
        to the other half of the maximum width (i.e., the height again).
        """
        for x in reversed(range(data['height'])):
            if (x < len(data['A'])):
                outA = ('=' * data['A'][x]).rjust(data['height'])
                outA = outA[:-len(str(data['A'][x]))] + str(data['A'][x])
                outA = outA + ('=' * data['A'][x]).ljust(data['height'])
            else:
                outA = '|'.rjust(data['height']) + ' '.ljust(data['height'])
            if (x < len(data['B'])):
                outB = ('=' * data['B'][x]).rjust(data['height'])
                outB = outB[:-len(str(data['B'][x]))] + str(data['B'][x])
                outB = outB + ('=' * data['B'][x]).ljust(data['height'])
            else:
                outB = '|'.rjust(data['height']) + ' '.ljust(data['height'])
            if (x < len(data['C'])):
                outC = ('=' * data['C'][x]).rjust(data['height'])
                outC = outC[:-len(str(data['C'][x]))] + str(data['C'][x])
                outC = outC + ('=' * data['C'][x]).ljust(data['height'])
            else:
                outC = '|'.rjust(data['height']) + ' '.ljust(data['height'])
            print('  :', outA, outB, outC)
        print('  :',
              'A'.rjust(data['height']) + ' '.ljust(data['height']),
              'B'.rjust(data['height']) + ' '.ljust(data['height']),
              'C'.rjust(data['height']) + ' '.ljust(data['height']))

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
        print('\r\nMoving disk', disk, 'from', source, 'onto', target,
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
            print('\r\nGame reloaded:', file)
            write_disks()
            if ((data['disk']) is not None):
                print('\r\nMoving disk', data['disk'], 'onto ...')
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
            print('\r\nMoving disk', data['disk'], 'from', rod, 'onto ...')

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
        print('\r\nSolving, please wait ...')
        write_disks()
        time.sleep(4)
        solve_game(disk=data['height'], source='A', target='C', spare='B')
        return

    # Otherwise, begin listening for keypresses until False is returned
    # (suppress input events from being passed back to the console)
    print('\r\nGood luck, move disks by pressing A, B, or C ...')
    write_disks()
    with Listener(on_press=on_press, suppress=True) as lstn:
        lstn.join()


# Start the program interactively
if __name__ == '__main__':
    try:
        print('\r\nTHE TOWER OF HANOI')
        height = int(input('Please enter a height for the tower [0-12]: '))
        solve = None
        while (solve != 'y') and (solve != 'n'):
            solve = input('Do you want the computer to play itself? [Y|N]: ')
            solve = solve.lower()
        print('  Move all of the disks from rod A to rod C')
        print('  Press A, B, or C to move a disk between two rods')
        print('  A larger disk cannot be placed on top of a smaller disk')
        print('  Press S to save the game, R or L to reload a saved game')
        print('  Press ESC or Q to quit')
        play(height=height, solve=(solve == 'y'))
        input('Press the ENTER key to exit the game: ')
    except Exception as e:
        print(str(e))
