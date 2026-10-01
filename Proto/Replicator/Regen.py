import time
import random
import sys
import os

# Enable ANSI escape sequences on Windows if needed
if os.name == 'nt':
    os.system('color')

chars = "1234567890:qwertyuiop:0987654321"

# Adjust the width of the matrix effect (number of columns)
width = 32

try:
    print("\033[1;32m") # Set terminal text to bright green
    while True:
        # Create a line of random characters mixed with spaces
        line = "".join(random.choice(chars) if random.random() > 0.4 else " " for _ in range(width))
        sys.stdout.write(line + "\n")
        sys.stdout.flush()
        time.sleep(0.05) # Control the falling speed
except KeyboardInterrupt:
    print("\033[0m") # Reset terminal colors on exit
