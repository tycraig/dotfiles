# Development Environment Technical Specification and Operator Manual

This document provides technical instructions and reference tables for the portable offline development environment.
The environment contains Neovim (LazyVim), Zsh, tmux, WezTerm, lazygit, zoxide, GEF, bat, delta, tealdeer, and eza.
You can run this environment directly on a Linux operating system, or connect to a Linux system through SSH from a Windows host.

---

## 1. Daily Operator Reference

### 1.1 Vim Foundation Reference

#### Cursor Movement
| Keybinding | Action |
| :--- | :--- |
| `h` | Move cursor left |
| `j` | Move cursor down |
| `k` | Move cursor up |
| `l` | Move cursor right |
| `w` | Move cursor forward to the start of the next word |
| `b` | Move cursor backward to the start of the previous word |
| `e` | Move cursor forward to the end of the current word |
| `ge` | Move cursor backward to the end of the previous word |
| `0` | Move cursor to the start of the current line |
| `^` | Move cursor to the first non-blank character of the current line |
| `$` | Move cursor to the end of the current line |
| `gg` | Move cursor to the first line of the file |
| `G` | Move cursor to the last line of the file |
| `:<number>` | Move cursor to line number `<number>` |
| `%` | Move cursor to matching parenthesis, bracket, or brace |
| `f<char>` | Move cursor forward to character `<char>` on current line |
| `F<char>` | Move cursor backward to character `<char>` on current line |
| `t<char>` | Move cursor forward to one character before `<char>` |
| `T<char>` | Move cursor backward to one character after `<char>` |
| `;` | Repeat last `f`, `F`, `t`, or `T` command forward |
| `,` | Repeat last `f`, `F`, `t`, or `T` command backward |

#### Basic Editing Operations
| Keybinding | Action |
| :--- | :--- |
| `i` | Enter insert mode before cursor |
| `I` | Enter insert mode at the start of the line |
| `a` | Enter insert mode after cursor |
| `A` | Enter insert mode at the end of the line |
| `o` | Insert a new line below cursor and enter insert mode |
| `O` | Insert a new line above cursor and enter insert mode |
| `s` | Delete current character and enter insert mode |
| `S` | Delete current line and enter insert mode |
| `x` | Delete character under cursor |
| `r<char>` | Replace character under cursor with `<char>` |
| `u` | Undo previous action |
| `Ctrl + r` | Redo undone action |
| `.` | Repeat previous editing action |

#### Text Object Operations
Combine an operator (`d` for delete, `c` for change, `y` for copy) with an object scope (`i` for inner, `a` for around).

| Keybinding | Action |
| :--- | :--- |
| `ciw` | Change current inner word |
| `diw` | Delete current inner word |
| `yiw` | Copy current inner word |
| `ci"` | Change text inside matching quotation marks |
| `da"` | Delete text and matching quotation marks |
| `ci(` or `cib` | Change text inside matching parentheses |
| `da(` or `dab` | Delete text and matching parentheses |
| `ci{` or `ciB` | Change text inside matching curly braces |
| `da{` or `daB` | Delete text and matching curly braces |
| `cit` | Change text inside HTML or XML tag |
| `dat` | Delete text and matching HTML or XML tag |
| `cip` | Change inner paragraph |
| `dap` | Delete full paragraph |

#### Visual Mode Operations
| Keybinding | Action |
| :--- | :--- |
| `v` | Enter character-wise visual mode |
| `V` | Enter line-wise visual mode |
| `Ctrl + v` | Enter block-wise visual mode |
| `>` | Shift selected lines right |
| `<` | Shift selected lines left |
| `y` | Copy visual selection |
| `d` | Delete visual selection |
| `c` | Delete visual selection and enter insert mode |

#### Window and Split Management
| Keybinding | Action |
| :--- | :--- |
| `Ctrl + w s` | Split active window horizontally |
| `Ctrl + w v` | Split active window vertically |
| `Ctrl + w q` | Close active split window |
| `Ctrl + w o` | Close all split windows except active window |
| `Ctrl + w =` | Make all split windows equal height and width |
| `Ctrl + w +` | Increase split window height |
| `Ctrl + w -` | Decrease split window height |
| `Ctrl + w >` | Increase split window width |
| `Ctrl + w <` | Decrease split window width |

---

### 1.2 Terminal Multiplexing (tmux)
Default prefix key: `Ctrl+a`.

#### Window and Session Controls
| Keybinding | Action |
| :--- | :--- |
| `Prefix + c` | Create a new tmux window |
| `Prefix + ,` | Rename active tmux window |
| `Prefix + &` | Terminate active tmux window |
| `Prefix + n` | Move focus to next window |
| `Prefix + p` | Move focus to previous window |
| `Prefix + <0-9>` | Move focus to window index number `<0-9>` |
| `Prefix + w` | Show interactive tree of sessions and windows |
| `Prefix + d` | Detach active session safely |
| `Prefix + $` | Rename current session |
| `Prefix + ?` | Display complete list of tmux keybindings |

#### Pane Controls
| Keybinding | Action |
| :--- | :--- |
| `Prefix + \|` | Split active pane vertically (side-by-side) |
| `Prefix + -` | Split active pane horizontally (top-to-bottom) |
| `Prefix + h` | Move focus to left pane |
| `Prefix + j` | Move focus to lower pane |
| `Prefix + k` | Move focus to upper pane |
| `Prefix + l` | Move focus to right pane |
| `Prefix + z` | Toggle zoom for current pane |
| `Prefix + x` | Close current pane |
| `Prefix + !` | Break active pane out into a separate window |
| `Prefix + q` | Display pane index numbers |
| `Prefix + Ctrl + h/j/k/l` | Resize active pane in steps of 5 cells |

#### Copy and Scrollback Mode
| Keybinding | Action |
| :--- | :--- |
| `Prefix + [` | Enter copy mode |
| `q` | Exit copy mode |
| `v` | Begin text selection (while in copy mode) |
| `y` | Copy selected text to clipboard and exit copy mode |
| `Prefix + ]` | Paste clipboard buffer into active pane |

---

### 1.3 Neovim and LazyVim Reference
Leader key: `<Space>`.

#### File and Buffer Navigation
| Keybinding | Action |
| :--- | :--- |
| `<Space><Space>` | Search files in project root directory |
| `<Space> /` | Search text patterns across project (ripgrep) |
| `<Space> f b` | Search active buffers |
| `<Space> f r` | Search recent file history |
| `<Space> f f` | Search files from current working directory |
| `<Space> e` | Open file explorer tree (Neo-tree) |
| `<Space> s g` | Open Grug-far search and replace interface |
| `[b` | Move focus to previous buffer tab |
| `]b` | Move focus to next buffer tab |
| `<Space> b d` | Close active buffer without altering window layout |
| `<Space> b o` | Close all buffers except active buffer |
| `<Space> w` | Save modifications to active buffer |
| `<Space> q` | Exit active Neovim buffer or window |

#### File Explorer Sub-commands
| Keybinding | Action |
| :--- | :--- |
| `H` | Toggle visibility of hidden files |
| `I` | Toggle visibility of Git-ignored files |
| `a` | Create a new file or directory |
| `d` | Delete selected file or directory |
| `r` | Rename selected file or directory |
| `c` | Copy selected file or directory |
| `m` | Move selected file or directory |
| `R` | Refresh file tree structure |
| `Alt + w` | Toggle focus between explorer pane and search input |

#### Language Server Protocol (LSP) Controls
| Keybinding | Action |
| :--- | :--- |
| `gd` | Jump to symbol definition |
| `gr` | Show all references to symbol |
| `gI` | Jump to symbol implementation |
| `gy` | Jump to type definition |
| `K` | Display hover documentation for symbol |
| `gK` | Display signature help for active function parameters |
| `[d` | Jump to previous diagnostic item |
| `]d` | Jump to next diagnostic item |
| `[e` | Jump to previous diagnostic error |
| `]e` | Jump to next diagnostic error |
| `<Space> c a` | Open available code actions |
| `<Space> c r` | Rename symbol project-wide |
| `<Space> c f` | Format active file |
| `<Space> c d` | Show line diagnostic information |
| `<Space> x x` | Toggle Trouble diagnostics panel |

#### Git Workspace Controls (Gitsigns)
| Keybinding | Action |
| :--- | :--- |
| `]h` | Jump to next modified hunk |
| `[h` | Jump to previous modified hunk |
| `<Space> g h s` | Stage change hunk under cursor |
| `<Space> g h r` | Reset change hunk under cursor |
| `<Space> g h p` | Preview change hunk under cursor |
| `<Space> g h b` | Show Git blame annotation for current line |
| `<Space> g B` | Show Git blame annotation for entire buffer |
| `<Space> g h d` | Show unified diff for current file |

#### Interactive Debugging (nvim-dap)
| Keybinding | Action |
| :--- | :--- |
| `<Space> d b` | Set or remove breakpoint on current line |
| `<Space> d c` | Start debugging or continue execution |
| `<Space> d i` | Step execution into function call |
| `<Space> d o` | Step execution out of current function |
| `<Space> d O` | Step execution over current instruction line |
| `<Space> d u` | Toggle debugging visual interface (DAP UI) |
| `<Space> d t` | Terminate active debugging session |
| `<Space> d r` | Open debug REPL interface |

#### Interface State Toggles
| Keybinding | Action |
| :--- | :--- |
| `<Space> u d` | Enable or disable diagnostic annotations |
| `<Space> u f` | Enable or disable automated formatting on save |
| `<Space> u l` | Enable or disable line numbering |
| `<Space> u s` | Enable or disable spell checking |
| `<Space> u I` | Enable or disable LSP inlay hints |
| `Ctrl + h` | Move focus to left split or tmux pane |
| `Ctrl + j` | Move focus to lower split or tmux pane |
| `Ctrl + k` | Move focus to upper split or tmux pane |
| `Ctrl + l` | Move focus to right split or tmux pane |

---

### 1.4 Shell and Command-Line Interface (Zsh, Vi-Mode, fzf)
| Keybinding | Input State | Action |
| :--- | :--- | :--- |
| `Ctrl + r` | Interactive shell | Search command history with interactive fzf preview |
| `Ctrl + t` | Interactive shell | Search file paths and append result to active prompt |
| `Alt + c` | Interactive shell | Search directories and change directory immediately |
| `Right Arrow` | Interactive shell | Accept inline autosuggestion |
| `Ctrl + e` | Interactive shell | Accept inline autosuggestion |
| `Esc` or `jk` | Prompt input line | Switch to Vi normal mode (Cursor shape: `\|` -> `█`) |
| `i` | Vi normal mode | Switch to Vi insert mode before cursor |
| `a` | Vi normal mode | Switch to Vi insert mode after cursor |
| `v` | Vi normal mode | Open active command string in full Neovim editor |

---

### 1.5 Terminal Front-End Controls (WezTerm)
| Keybinding | Action |
| :--- | :--- |
| `Ctrl + Shift + c` | Copy selected text to host clipboard |
| `Ctrl + Shift + v` | Paste text from host clipboard |
| `Ctrl + Shift + f` | Open text search scrollback bar |
| `Ctrl + +` | Increase font size |
| `Ctrl + -` | Decrease font size |
| `Ctrl + 0` | Reset font size to default |
| `Ctrl + Shift + t` | Open new WezTerm tab |
| `Ctrl + Shift + w` | Close active WezTerm tab |
| `Ctrl + Tab` | Move focus to next WezTerm tab |
| `Ctrl + Shift + Tab` | Move focus to previous WezTerm tab |

---

### 1.6 Lazygit Reference

Use lazygit for terminal-based Git repository management.

#### Shell Commands
| Command | Action |
| :--- | :--- |
| `lg` | Open lazygit in current Git repository |
| `dotgit` | Open lazygit for the bare dotfiles repository (`~/.dotfiles`) |

#### Primary Keybindings
| Keybinding | Action |
| :--- | :--- |
| `1` - `5` | Jump to panel (1: Status, 2: Files, 3: Branches, 4: Commits, 5: Stash) |
| `Space` | Stage or unstage selected file or change |
| `c` | Open commit dialog |
| `P` | Push commits to remote repository |
| `p` | Pull commits from remote repository |
| `z` | Undo previous Git operation |
| `d` | Discard changes in selected file or hunk |
| `q` | Exit lazygit |
| `?` | Display keybinding help menu |

---

### 1.7 Smart Directory Navigation (Zoxide)

Zoxide tracks frequently used directories and calculates directory rankings based on access frequency.

#### Commands
| Command | Action |
| :--- | :--- |
| `z <dir>` | Navigate directly to directory path `<dir>` |
| `z <pattern>` | Navigate to highest-ranked matching directory |
| `zi <pattern>` | Open interactive selection filtered by `<pattern>` with fzf |
| `z -` | Navigate to previous working directory |
| `z ..` | Navigate to parent directory |
| `zi` | Open interactive selection with fzf |

---

### 1.8 Low-Level Debugging (GDB & GEF)

GEF extends GDB with architecture context, memory mapping, and exploit development features.

#### Session Startup
Start GDB with a target binary:
```bash
gdb <executable>
```

#### Key GEF Commands
| Command | Action |
| :--- | :--- |
| `context` | Display registers, code, stack, and backtrace |
| `registers` | Inspect CPU registers |
| `checksec` | Inspect binary security protections |
| `vmmap` | Display virtual memory map |
| `pattern create <size>` | Generate cyclic pattern of `<size>` bytes for buffer offset calculation |
| `pattern search <val>` | Search cyclic pattern offset for value `<val>` |
| `quit` or `q` | Exit GDB session |

---

### 1.9 Syntax-Highlighted File Viewing (bat)

Use `bat` for syntax-highlighted file viewing and `fzf` previews.

#### Commands
| Command | Action |
| :--- | :--- |
| `bat <file>` | Display file contents with syntax highlighting and line numbers |
| `bat -p <file>` | Display raw file contents without line numbers or headers |
| `cat <file>` | Aliased to `bat --paging=never` |

---

### 1.10 Syntax-Highlighted Diff Viewer (delta)

Delta provides language syntax highlighting and line-level diff formatting for Git.

#### Usage
Delta activates automatically for standard Git commands and lazygit diff panels:
```bash
git diff
git show
git log -p
```

---

### 1.11 Offline Command Cheatsheets (tealdeer / tldr)

Tealdeer provides offline syntax examples for terminal utilities.
The pages database is pre-cached for offline operation.

#### Commands
| Command | Action |
| :--- | :--- |
| `tldr <command>` | Display practical usage examples for `<command>` |
| `tldr --list` | List all cached command manual pages |
| `tldr --update` | Refresh local cheatsheet cache from remote repository |

---

### 1.12 Modern Directory Listings (eza)

`eza` replaces standard `ls` with color-coded metadata, Git branch states, and file icons.

#### Commands
| Command | Action |
| :--- | :--- |
| `ls` | List files with type indicators and icons (`eza -F --icons=auto`) |
| `ll` | Long format with permissions, sizes, Git status, and icons (`eza -laF --git --icons=auto`) |
| `lt` | Two-level directory tree view (`eza --tree --level=2 --icons=auto`) |

---

### 1.13 Ergonomic Shell and Git Helpers

#### Shell Shortcuts
| Command | Action |
| :--- | :--- |
| `mcd <dir>` | Create directory and enter it immediately |
| `path` | Display each directory in `PATH` on a separate line |
| `ports` | Display listening network sockets and active ports |
| `mem` | Display system memory usage in human-readable units |
| `..` | Move to parent directory |

#### Git Aliases
| Command | Action |
| :--- | :--- |
| `git prune-local` | Delete local branches whose remote tracking branches were removed |
| `git pf` | Safe force push (`push --force-with-lease`) |
| `dfs` | Display dotfiles Git status (`dotfiles status`) |
| `dotgit` | Open dotfiles repository in Lazygit interface |

---

## 2. Offline System Deployment

### 2.1 Target System Configuration (Linux)

#### Step 1: Install prerequisite packages
Verify that the host operating system includes core administration tools.

For Fedora / RHEL systems:
```bash
sudo dnf install -y zsh tmux util-linux-user git curl tar zstd xz unzip fontconfig eza
```

For Ubuntu / Debian systems:
```bash
sudo apt-get update && sudo apt-get install -y zsh tmux git curl tar zstd xz-utils unzip fontconfig eza
```

Verify that the host operating system includes WezTerm.
For Fedora / RHEL systems:
```bash
sudo dnf copr enable wezfurlong/wezterm-nightly
sudo dnf install wezterm
```

#### Step 2: Transfer deployment archive
Target deployment archives use Zstandard compression (`dev-bundle-latest.tar.zst`).
Copy `dev-bundle-latest.tar.zst` and `dev-bundle-latest.tar.zst.sha256` to the target machine.
Place the files in the `$HOME` directory.

#### Step 3: Verify checksum and extract archive
Verify the SHA-256 checksum first:
```bash
sha256sum -c dev-bundle-latest.tar.zst.sha256
```

Extract the deployment archive into your home directory:
```bash
tar -I zstd -xf dev-bundle-latest.tar.zst -C "$HOME"
```

#### Step 4: Execute configuration script
Execute the post-extraction configuration script:
```bash
~/.local/bin/install.sh
```

The `install.sh` script executes these actions:
1. Migrates an existing `~/.gitconfig` to `~/.gitconfig.local` to preserve your host Git settings.
2. Moves conflicting dotfiles (`.zshrc`, `.tmux.conf`, Neovim data) to `~/.dotfiles-backup/<timestamp>/`.
3. Restores bare Git tracking in `~/.dotfiles`.
4. Resolves tools via tiered system package priority, normalizes Ubuntu names (`fdfind`, `batcat`), and deploys fallback binaries from `~/.local/share/dev-bundle/`.
5. Creates the symbolic link `~/.local/bin/nvim` that points to `.local/opt/nvim-linux-x86_64/bin/nvim`.
6. Compiles WezTerm terminfo definitions into `~/.terminfo/`.
7. Refreshes font configuration caches for JetBrains Mono Nerd Font.
8. Rebuilds manual page databases.
9. Configures Zsh as the default shell, or appends an execution guard to `~/.bashrc`.
10. Executes an automated system health check for all core tools (`rg`, `fd`, `fzf`, `starship`, `nvim`, `lazygit`, `zoxide`, `bat`, `delta`, `tldr`, `eza`).

#### Step 5: Start environment
Execute this command to start your session:
```bash
exec zsh
```

---

### 2.2 Windows Host Setup (WezTerm)

1. Extract the portable `WezTerm-windows.zip` archive into a directory (for example: `C:\Tools\WezTerm\`).
2. Copy `.config/wezterm/wezterm.lua` to `C:\Users\<User>\.config\wezterm\wezterm.lua`.
3. Start `wezterm.exe`.
4. Connect to the Linux target host through SSH:
   ```cmd
   ssh username@target-ip
   ```

Text copied in Neovim or tmux transfers to the Windows system clipboard through standard OSC 52 escape sequences.

---

### 2.3 Environment Removal and Baseline Reset (uninstall.sh)

Use `uninstall.sh` to remove the offline environment and restore your previous baseline configuration.

#### Automated Actions
The `uninstall.sh` script executes these actions:
1. Deletes repository-tracked dotfiles from `$HOME`.
2. Deletes the bare Git tracking repository at `~/.dotfiles`.
3. Restores your original dotfiles from the most recent backup directory in `~/.dotfiles-backup/`.
4. Removes the interactive Zsh execution guard from `~/.bashrc`.
5. Removes whitelisted environment binaries from `~/.local/bin/`.
6. Removes application runtimes, Mason packages, Lazy plugins, and GEF assets.
7. Purges environment manual pages and rebuilds manual page and font caches.

#### Removal Procedure
Execute `uninstall.sh` directly if the environment is active:
```bash
~/.local/bin/uninstall.sh
```

To extract and execute `uninstall.sh` directly from a deployment archive:
```bash
tar -I zstd -xf dev-bundle-latest.tar.zst .local/bin/uninstall.sh
~/.local/bin/uninstall.sh
```

Pass the `--yes` or `-y` flag to bypass the interactive confirmation prompt:
```bash
~/.local/bin/uninstall.sh --yes
```

Reset your terminal session after uninstallation:
```bash
exec bash
```

---

### 2.4 Offline Deployment Verification Procedure

Follow this test procedure to verify offline installation on an isolated target system:

1. Copy `dev-bundle-latest.tar.zst` and `dev-bundle-latest.tar.zst.sha256` to the target system.
2. Remove any previous test installation:
   ```bash
   tar -I zstd -xf dev-bundle-latest.tar.zst .local/bin/uninstall.sh
   ~/.local/bin/uninstall.sh --yes
   ```
3. Disconnect network interfaces to simulate an air-gapped system:
   ```bash
   nmcli networking off
   ```
4. Verify the SHA-256 archive checksum:
   ```bash
   sha256sum -c dev-bundle-latest.tar.zst.sha256
   ```
5. Extract the archive into your home directory:
   ```bash
   tar -I zstd -xf dev-bundle-latest.tar.zst -C "$HOME"
   ```
6. Execute the post-extraction configuration script:
   ```bash
   ~/.local/bin/install.sh
   ```
7. Start the shell and verify that all tools function offline:
   ```bash
   exec zsh
   lazygit --version
   zoxide --version
   eza --version
   nvim --headless "+qa"
   gdb -batch -ex "gef" -ex "quit"
   ```
8. Re-enable networking after verification:
   ```bash
   nmcli networking on
   ```

---

## 3. Maintenance and Updates (Factory Host)

### 3.1 Directory Structure
```text
~
├── .dotfiles/                  <- Bare Git repository (tracks files in $HOME)
├── .cache/
│   └── tealdeer/               <- Pre-seeded offline command cheatsheet cache
├── .clang-format               <- C/C++ formatting specification
├── .config/
│   ├── dotfiles/               <- Technical documentation and cheat sheet
│   ├── lazygit/                <- Lazygit configuration (delta pager integration)
│   ├── nvim/                   <- Neovim and LazyVim configuration
│   ├── ruff/                   <- Python linting and formatting configuration
│   ├── wezterm/                <- WezTerm terminal configuration
│   └── starship.toml           <- Prompt settings
├── .gdbinit                    <- GDB initialization script and GEF loader
├── .gitconfig                  <- Tracked Git configuration with delta pager
├── .local/
│   ├── bin/                    <- Standalone executables and operational scripts
│   ├── opt/                    <- Extracted application trees (Neovim runtime)
│   ├── env-manifest.txt        <- Toolchain version record
│   └── share/
│       ├── dev-bundle/         <- Canonical offline payload cache (binaries, packaging source)
│       ├── fonts/              <- JetBrains Mono font files
│       ├── gef/                <- GEF (GDB Enhanced Features) script
│       ├── man/                <- Manual pages
│       ├── nvim/lazy/          <- Downloaded plugins and compiled Tree-sitter parsers
│       ├── nvim/mason/         <- Language servers, formatters, and debuggers
│       └── zsh/                <- Zsh plugins and completion definitions
├── .terminfo/                  <- Compiled terminal capabilities
├── .tmux.conf                  <- Multiplexer configuration
├── .zshenv                     <- Shell environment, language settings, and non-interactive PATH
└── .zshrc                      <- Zsh configuration and interactive shell setup
```

---

### 3.2 Bare Git Repository Controls

The bare repository uses the `dotfiles` command configured in `.zshrc`:

```bash
# Check status of tracked configuration files
dotfiles status

# Add a modified configuration file
dotfiles add ~/.config/nvim/lua/config/options.lua

# Commit modifications to history
dotfiles commit -m "Update option settings"

# Push commits to remote Git repository
dotfiles push
```

---

### 3.3 Update Operations

Execute `update.sh` on an internet-connected system to update components:

```bash
# Routine Sync: Check and update Zsh plugins, Neovim plugins, Treesitter parsers, and Mason
update.sh

# Toolchain Update: Check and update rg, fd, fzf, starship, lazygit, zoxide, bat, delta, and tealdeer
update.sh --tools

# Runtime Update: Download latest stable Neovim runtime into .local/opt
update.sh --nvim

# Terminfo Update: Compare and recompile WezTerm terminfo definitions
update.sh --terminfo

# Full Update: Execute all update modules
update.sh --all

# Force Rebuild: Ignore version checks and create a new bundle
update.sh --force

# Manual Archive Creation: Create package bundle without updating software
bundle.sh
```

---

### 3.4 Binary Whitelist and Environment Extension

The `bundle.sh` script uses a binary whitelist (`BIN_WHITELIST`) to filter executables in `~/.local/bin`.
This whitelist prevents host tools, temporary binaries, and host agents from polluting the offline bundle.
Only approved tools package into the standalone deployment archive.

Follow this procedure to add a new tool to the environment:

1. Copy the binary into `~/.local/bin/` and stage a standalone copy in `~/.local/share/dev-bundle/bin/`.
   The `dev-bundle/bin` cache stores canonical offline payloads. This cache ensures that `bundle.sh` can package tools even when package managers replace binaries in `~/.local/bin`.
2. Set executable permissions on both copies:
   ```bash
   chmod +x ~/.local/bin/<tool-name>
   chmod +x ~/.local/share/dev-bundle/bin/<tool-name>
   ```
3. Open `~/.local/bin/bundle.sh` in an editor.
4. Add the binary name to the `BIN_WHITELIST` array.
5. Open `~/.local/bin/generate_manifest.sh` in an editor.
6. Add a version check command for the binary to record the version in `env-manifest.txt`.
7. Add manual pages for the tool to `~/.local/share/man/man1/`.
8. Add shell completions for the tool to `~/.local/share/zsh/site-functions/`.
9. Open `~/.config/dotfiles/README.md` to document the tool commands and keybindings.
10. Execute `bundle.sh` to generate the updated deployment archive:
    ```bash
    bundle.sh
    ```
11. Verify that the new binary exists in the archive.

---

### 3.5 Machine-Specific Overrides (.zshrc.local and .gitconfig.local)

The environment provides local configuration hooks.
Use these hooks to define machine-specific settings without modifying tracked repository files.

#### Shell Overrides (~/.zshrc.local)
Create `~/.zshrc.local` to define machine-specific environment variables, proxies, or paths.
Zsh sources `~/.zshrc.local` automatically at startup if the file exists:
```bash
# Example ~/.zshrc.local
export HTTP_PROXY="http://proxy.example.internal:8080"
export HTTPS_PROXY="http://proxy.example.internal:8080"
```

#### Git Identity Overrides (~/.gitconfig.local)
The tracked `~/.gitconfig` file includes `~/.gitconfig.local` automatically.
During deployment, `install.sh` automatically migrates any pre-existing `~/.gitconfig` into `~/.gitconfig.local`.
This migration retains your pre-existing user name, email, credentials, and work proxies.
If `~/.gitconfig.local` does not exist, create it manually to configure your work identity or signing key:
```ini
[user]
    name = Tyler
    email = user@work-domain.internal
    # signingkey = ~/.ssh/id_ed25519.pub
```
This configuration keeps your work identity separate from the public dotfiles repository.


