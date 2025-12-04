# Contributing to Hotpaws

## Development Setup

1. Clone the repository:
```bash
git clone https://github.com/listeomin/hotpaws.git
cd hotpaws
```

2. Build the project:
```bash
./scripts/build.sh
```

3. Run:
```bash
open build/Hotpaws.app
```

## Project Structure

See [project-doc.md]($/project-doc.md) for complete architecture documentation.

## Code Style

- Swift: Standard Swift conventions
- JavaScript: ES6+, no build tools
- Comments only for non-obvious logic
- Prefer clarity over cleverness

## Pull Request Process

1. Update README.md with details of changes if needed
2. Test on both Intel and Apple Silicon if possible
3. Ensure build script works
4. Update project-doc.md for architectural changes

## Core Principles

- **Beginners First**: Design for people new to terminal
- **No Surprises**: Never execute commands automatically
- **External Config**: Users customize via files, not code
- **Minimal Dependencies**: Standard macOS frameworks only

## Reporting Bugs

Include:
- macOS version
- Terminal app (Terminal.app / iTerm2 / Warp)
- Steps to reproduce
- Expected vs actual behavior

## Feature Requests

Before suggesting features, consider:
- Is this for beginners or power users?
- Can it be done via config files?
- Does it add complexity to the interface?
