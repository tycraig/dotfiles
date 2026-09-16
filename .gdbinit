# ===================================================
# GDB Configuration
# ===================================================

# Set disassembly syntax to Intel (default is AT&T)
set disassembly-flavor intel

# Command history persistence across sessions
set history save on
set history size 10000
set history filename ~/.gdb_history
set history remove-duplicates 50

# Output readability
set print pretty on
set print array on
set print array-indexes on
set print null-stop on

# Disable pagination prompts during long traces
set pagination off

# Confirm exit prompts disabled
set confirm off

# Follow child processes on fork when needed (optional)
# set follow-fork-mode child

# Load GEF if installed
python
import os
gef_path = os.path.expanduser("~/.local/share/gef/gef.py")
if os.path.exists(gef_path):
    gdb.execute(f"source {gef_path}")
end
