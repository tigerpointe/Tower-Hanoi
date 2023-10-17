#!/usr/bin/env python3
""" A Python module for solving the Tower of Hanoi puzzle.
https://en.wikipedia.org/wiki/Tower_of_Hanoi
History:
01.00 2023-Oct-10 Scott S. Initial release.

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


def solve(height=0):
    """ Solves the puzzle using a recursive subproblems code pattern.
    PARAMETERS:
    height : tower height
    """

    # Initialize the rods and disk numbers (later accessed using closure)
    rods = {}
    rods['A'] = list((x + 1) for x in reversed(range(height)))
    rods['B'] = list()
    rods['C'] = list()

    # Initialize the move counters (later updated using nonlocal keyword)
    total = (2 ** height) - 1
    count = 0

    def write():
        """ Writes the disk numbers contained on each rod."""
        print('  A:', '  '.join(map(str, rods['A'])))
        print('  B:', '  '.join(map(str, rods['B'])))
        print('  C:', '  '.join(map(str, rods['C'])))

    def move(n=0, source='A', target='C', spare='B'):
        """ Moves a disk from the source to the target by way of a spare.
        PARAMETERS:
        n      : disk number
        source : source rod
        target : target rod
        spare  : spare rod
        """

        nonlocal count  # required to assign an updated value

        # Stop the recursion when no more disks can be moved
        if (n < 1):
            return

        # Recursively move the next disk from the source to the spare
        move(n=(n - 1), source=source, target=spare, spare=target)

        # Move the current disk from the source to the target
        rods[target].append(rods[source].pop(rods[source].index(n)))
        count += 1

        # Write the output message
        print(f'{count:,}:', 'Moved disk', n, 'from', source, 'to', target)
        write()

        # Recursively move the next disk from the spare to the target
        move(n=(n - 1), source=spare, target=target, spare=source)

    # Write the output header
    print('Solving for', height, 'disks in', f'{total:,}', 'moves ...')
    write()

    # Solve the puzzle recursively, starting with the largest disk and then
    # working backwards
    move(n=height)
    print('Solution completed.')


# Start the program interactively
if __name__ == '__main__':
    height = int(input('Enter a height for the tower: '))
    solve(height)
