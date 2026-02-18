# Homebrew Tap for e-bash

This is the official Homebrew tap for [e-bash](https://github.com/OleksandrKucherenko/e-bash).

## Installation

### Stable Version

```bash
brew install artfulbits-se/tap/e-bash
```

### Nightly Version (Latest Development)

For users who want the latest features and fixes from the `master` branch:

```bash
brew install artfulbits-se/tap/e-bash-night
```

The nightly formula automatically upgrades to the latest `master` branch after installation. This is ideal for developers who want bleeding-edge features.

After installation, add to your shell profile:
```bash
# configure e-bash lib files location
export E_BASH="$HOME/.e-bash/.scripts"

# register helper scripts in path to make them available for usage
export PATH="$HOME/.e-bash/bin:$PATH"
```

## Upgrading

### Stable Version (via Homebrew)
```bash
brew upgrade e-bash
```

### Latest Development Version (Nightly)
```bash
e-bash --global upgrade latest
```

### Specific Version
```bash
e-bash --global upgrade v2.0.0
```

### List Available Versions
```bash
e-bash versions
```

## Documentation

See [e-bash documentation](https://github.com/OleksandrKucherenko/e-bash#readme).

## Contributing

### Local Testing

Before pushing changes to the tap repository, test the formula locally.

#### 1. Style Check (Fast)

```bash
# Check Ruby style compliance
brew style Formula/e-bash.rb
brew style Formula/e-bash-night.rb
```

#### 2. Docker Testing (Recommended)

Build a pre-warmed Docker image with dependencies installed:

```bash
# Build the test image (one-time setup, ~2 minutes)
docker build -t e-bash-test .

# Run style check
docker run --rm -v "$(pwd)/Formula:/formula:ro" e-bash-test

# Run full installation test
docker run --rm -v "$(pwd)/Formula:/formula:ro" e-bash-test bash -c '
mkdir -p /home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/local/homebrew-test/Formula
cp /formula/*.rb /home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/local/homebrew-test/Formula/
brew install local/test/e-bash-night
'
```

**Note**: Homebrew runs installations in a sandbox, so `~/.e-bash` verification inside Docker will show a sandboxed path. On real macOS/Linux machines, the formula installs to the actual `~/.e-bash`.

##### Manual Docker Testing Steps

For detailed testing and verification, follow these steps manually:

```bash
# Step 1: Build the test image
docker build -t e-bash-test .

# Step 2: Start an interactive container for testing
docker run --rm -it \
    -v "$(pwd)/Formula:/formula:ro" \
    -v "$(pwd)/../..:/e-bash-src:ro" \
    e-bash-test \
    bash

# Inside the container, run these commands:

# Step 3: Setup local tap
mkdir -p /home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/local/homebrew-test/Formula
cp /formula/e-bash-night.rb /formula/e-bash.rb /home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/local/homebrew-test/Formula/

# Step 4: Install tree for visualization (optional)
brew install tree

# Step 5: Run style check
brew style local/test/e-bash local/test/e-bash-night

# Step 6: Install the formula
brew install local/test/e-bash-night

# Step 7: Verify installation (note: sandboxed path)
cat /home/linuxbrew/.linuxbrew/bin/e-bash

# Step 8: Check Cellar contents
tree /home/linuxbrew/.linuxbrew/Cellar/e-bash-night
```

##### Verify Installation Structure

After `brew install`, verify the installation is correct:

```bash
# On your local machine (macOS/Linux with Homebrew)
# Run after: brew install artfulbits-se/tap/e-bash

# Check all required components exist
echo "=== Verifying ~/.e-bash installation ==="

# 1. Check directory structure
echo "1. Directory structure:"
test -d ~/.e-bash/.scripts && echo "   ✓ .scripts/ exists" || echo "   ✗ .scripts/ MISSING"
test -d ~/.e-bash/bin && echo "   ✓ bin/ exists" || echo "   ✗ bin/ MISSING"
test -d ~/.e-bash/.versions && echo "   ✓ .versions/ exists" || echo "   ✗ .versions/ MISSING"
test -d ~/.e-bash/.git && echo "   ✓ .git/ exists" || echo "   ✗ .git/ MISSING"

# 2. Check library modules (12 required)
echo ""
echo "2. Library modules (.scripts/):"
for module in _arguments _colors _commons _dependencies _dryrun _gnu _hooks _logger _self-update _semver _tmux _traps; do
    if test -f ~/.e-bash/.scripts/${module}.sh; then
        echo "   ✓ ${module}.sh"
    else
        echo "   ✗ ${module}.sh MISSING"
    fi
done

# 3. Check key executables
echo ""
echo "3. Key executables (bin/):"
test -x ~/.e-bash/bin/install.e-bash.sh && echo "   ✓ install.e-bash.sh" || echo "   ✗ install.e-bash.sh MISSING"
test -x ~/.e-bash/bin/git.semantic-version.sh && echo "   ✓ git.semantic-version.sh" || echo "   ✗ git.semantic-version.sh MISSING"

# 4. Check e-bash command wrapper
echo ""
echo "4. e-bash command:"
if command -v e-bash &>/dev/null; then
    echo "   ✓ e-bash command in PATH"
    echo "   Content: $(cat $(which e-bash))"
else
    echo "   ✗ e-bash command NOT in PATH"
fi

# 5. Check git configuration
echo ""
echo "5. Git configuration:"
cd ~/.e-bash 2>/dev/null && {
    git remote | grep -q "e-bash" && echo "   ✓ e-bash remote configured" || echo "   ✗ e-bash remote MISSING"
    test -f .gitignore && echo "   ✓ .gitignore exists" || echo "   ✗ .gitignore MISSING"
} || echo "   ✗ Cannot check git config"

# 6. Verify no development artifacts
echo ""
echo "6. Development artifacts (should NOT exist):"
for artifact in .claude .clavix .github .idea .lefthook .secrets .vscode .worktrees patches report spec AGENTS.md CLAUDE.md; do
    if test -e ~/.e-bash/$artifact; then
        echo "   ✗ $artifact should be removed"
    else
        echo "   ✓ $artifact not present"
    fi
done

echo ""
echo "=== Verification complete ==="
```

#### 3. Local Tap Testing

Create a local tap for full install testing:

```bash
# Create local tap
mkdir -p $(brew --repository)/Library/Taps/local/homebrew-test/Formula

# Copy formula
cp Formula/e-bash.rb $(brew --repository)/Library/Taps/local/homebrew-test/Formula/

# Install from local tap
brew install local/test/e-bash

# Test the installation
e-bash versions

# Clean up after testing
brew uninstall e-bash
rm -rf $(brew --repository)/Library/Taps/local/homebrew-test
rm -rf ~/.e-bash  # Remove global installation directory
```

#### 4. Pre-commit Checklist

- [ ] `brew style` passes with no errors
- [ ] Formula installs successfully locally
- [ ] `e-bash versions` shows installed version
- [ ] `e-bash --global upgrade latest` works
- [ ] README.md reflects any new commands or changes
- [ ] Version number and SHA256 are updated for new releases

### Expected Installation Structure

After successful installation, `~/.e-bash` should contain:

```
~/.e-bash/
├── .git/                    # Git repo (required for detection)
├── .gitignore               # Excludes .versions/
├── .scripts/                # Library modules (12 files)
│   ├── _arguments.sh
│   ├── _colors.sh
│   ├── _commons.sh
│   ├── _dependencies.sh
│   ├── _dryrun.sh
│   ├── _gnu.sh
│   ├── _hooks.sh
│   ├── _logger.sh
│   ├── _self-update.sh
│   ├── _semver.sh
│   ├── _tmux.sh
│   └── _traps.sh
├── .versions/               # Worktrees directory (empty initially)
├── bin/                     # Executable tools
│   ├── install.e-bash.sh    # Main installer/upgrade script
│   └── ... (other tools)
├── demos/                   # Demo scripts
└── docs/                    # Documentation
```

**NOT present** (cleaned up by formula):
- `.claude/`, `.clavix/`, `.github/`, `.idea/`, `.lefthook/`, `.secrets/`, `.vscode/`, `.worktrees/`
- `patches/`, `report/`, `spec/`
- `AGENTS.md`, `CLAUDE.md`, `mise.toml`

### Updating Version

When releasing a new version:

```bash
# Download new tarball and compute SHA256
curl -sL https://github.com/OleksandrKucherenko/e-bash/archive/refs/tags/vX.Y.Z.tar.gz | sha256sum

# Update Formula/e-bash.rb with:
# - url: new version URL
# - sha256: computed hash
# - version in e-bash-night.rb if needed
```
