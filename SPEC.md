# Craftee Specification

## Overview

Craftee is a terminal-based TUI application designed to streamline agentic software development workflows. It provides a unified interface for managing concurrent AI coding agents, reviewing changes, and committing work.

## Core Concepts

### Workspaces

A workspace represents a concurrent development idea or task. Each workspace:
- Optionally maps to a jujutsu (jj) workspace
- Contains zero or more running agents
- Maintains its own review state for changed files
- Has independent metadata (name, associated branch/commit info)

Users can quickly switch between workspaces within the TUI.

### Agents

An agent is a running instance of an LLM CLI tool (e.g., claude-code, codex, gemini) with an optional prompt. Agents:
- Are attached to a specific workspace
- Run as persistent processes until explicitly killed
- Can run concurrently within the same workspace
- Are configurable with a CLI tool path and optional prompt template
- Provide interactive terminal sessions

### Review State

Each workspace tracks which files have been reviewed:
- Review state is per-file, not per-hunk
- If a file is modified after being marked as reviewed, it becomes unreviewed again
- State is persisted locally in `.craftee/` directory
- State is workspace-specific

## UI Layout

### Common Elements

All views share:
- **Top bar**: Horizontal list of workspaces with current workspace highlighted
- **Main content area**: Changes based on current mode (agents, review, etc.)
- **Footer**: Keyboard shortcuts relevant to current context

### Agent View

```
┌─ [workspace-1] [workspace-2*] [workspace-3] ─────────────────────────┐
│                                                                       │
├───────────────────────┬───────────────────────────────────────────────┤
│ Agents (3)            │                                               │
│                       │                                               │
│ ▶ implement           │   Agent Terminal Output                       │
│   claude-code         │                                               │
│   idle (5m)           │   > User can interact here                    │
│                       │   > Full interactive session                  │
│   review              │   > ...                                       │
│   codex               │                                               │
│   running...          │                                               │
│                       │                                               │
│   test                │                                               │
│   claude-code         │                                               │
│   idle (1m)           │                                               │
│                       │                                               │
├───────────────────────┴───────────────────────────────────────────────┤
│ <SPC>a agents <SPC>r review <SPC>w workspace <SPC>c commit <SPC>p    │
│ push  h hide-sidebar  q quit                                          │
└───────────────────────────────────────────────────────────────────────┘
```

Layout:
- **Left column (20% width)**: List of agents in current workspace
  - Shows agent name, tool, and status
  - Can be hidden with keyboard shortcut to give agent terminal full width
- **Right column (80% width)**: Interactive terminal session for selected agent
  - Can expand to 100% width when sidebar hidden

### Review View

```
┌─ [workspace-1*] [workspace-2] [workspace-3] ─────────────────────────┐
│                                                                       │
├───────────────────────┬───────────────────────────────────────────────┤
│ Changes (4)           │                                               │
│                       │   Diff Viewer                                 │
│ ✓ src/auth.rs         │                                               │
│ · src/main.rs         │   - old line                                  │
│ · src/lib.rs          │   + new line                                  │
│ · tests/auth_test.rs  │   ...                                         │
│                       │                                               │
│                       │                                               │
│                       │                                               │
│                       │                                               │
│                       │                                               │
├───────────────────────┴───────────────────────────────────────────────┤
│ <SPC>a agents <SPC>r review <SPC>w workspace  d diff  r mark-reviewed│
│ n next  p previous  q quit                                            │
└───────────────────────────────────────────────────────────────────────┘
```

Layout:
- **Left column (20% width)**: List of changed files
  - `✓` indicates reviewed
  - `·` indicates not reviewed
  - Selected file highlighted
- **Right column (80% width)**: Diff viewer for selected file
  - Alternative: Could delegate to `jj diff` or similar tool and track review state separately

## Navigation

### Leader Key System

Primary navigation uses `<SPC>` (space) as leader key:

- `<SPC>a` - Agent actions menu (new, attach, kill)
- `<SPC>r` - Switch to review view
- `<SPC>w` - Workspace switcher/manager
- `<SPC>c` - Commit changes (launches commit agent)
- `<SPC>p` - Push to remote
- `h` - Hide/show sidebar (context-dependent)
- `q` - Quit

### Context-Specific Keys

**Agent View:**
- `<Enter>` on agent - Attach to agent terminal
- Arrow keys / `j/k` - Navigate agent list
- When attached to agent: full interactive control, `Esc` or `Ctrl-b` to detach

**Review View:**
- `d` - Show diff for selected file
- `r` - Mark selected file as reviewed / toggle review status
- `n` - Next file
- `p` - Previous file
- Arrow keys / `j/k` - Navigate file list

### Workspace Switcher

Pressing `<SPC>w` shows workspace management view:

```
┌─ Workspaces ─────────────────────────────────────┐
│                                                  │
│ ▶ feature-auth (current)                         │
│   2 agents, 4 changes (2 reviewed)               │
│   main @ abc123 | ↑2 ↓0                          │
│                                                  │
│   refactor-db                                    │
│   1 agent, 12 changes (0 reviewed)               │
│   main @ def456 | ↑5 ↓0                          │
│                                                  │
│   bugfix-login                                   │
│   0 agents, 2 changes (2 reviewed)               │
│   feature-x @ 789abc | ↑1 ↓0                     │
│                                                  │
│ + New workspace                                  │
│                                                  │
├──────────────────────────────────────────────────┤
│ <Enter> select  n new  d delete  <Esc> cancel   │
└──────────────────────────────────────────────────┘
```

## Data Storage

### Directory Structure

```
.craftee/
├── config/
│   └── workspaces.json          # Workspace metadata
├── workspaces/
│   ├── workspace-1/
│   │   ├── review-state.json    # Which files reviewed
│   │   └── agents.json          # Running agent configurations
│   ├── workspace-2/
│   │   ├── review-state.json
│   │   └── agents.json
│   └── ...
└── global-config.json           # Global settings, tool definitions
```

### State Files

**workspaces.json**:
```json
{
  "workspaces": [
    {
      "id": "workspace-1",
      "name": "feature-auth",
      "created": "2026-01-03T10:00:00Z",
      "jj_workspace": "feature-auth",  // optional
      "last_accessed": "2026-01-03T15:30:00Z"
    }
  ],
  "current": "workspace-1"
}
```

**review-state.json**:
```json
{
  "files": {
    "src/auth.rs": {
      "reviewed": true,
      "reviewed_at": "2026-01-03T15:00:00Z",
      "last_modified": "2026-01-03T14:55:00Z"
    },
    "src/main.rs": {
      "reviewed": false,
      "last_modified": "2026-01-03T15:30:00Z"
    }
  }
}
```

**agents.json**:
```json
{
  "agents": [
    {
      "id": "agent-1",
      "name": "implement",
      "tool": "claude-code",
      "command": "claude",
      "prompt": "",
      "pid": 12345,
      "started_at": "2026-01-03T14:00:00Z",
      "last_active": "2026-01-03T15:30:00Z",
      "status": "idle"
    }
  ]
}
```

**global-config.json**:
```json
{
  "tools": {
    "claude-code": {
      "command": "claude"
    },
    "codex": {
      "command": "codex"
    },
    "gemini": {
      "command": "gemini-cli"
    }
  },
  "default_tool": "claude-code",
  "theme": "default"
}
```

## Technical Stack

- **Language**: Rust
- **TUI Framework**: Ratatui (same as jjui)
- **Terminal Handling**: For interactive agent sessions, handle PTY allocation for subprocess control
- **Version Control**: Support both git and jujutsu, with preference for jj when `.jj/` directory exists

## Workflow Integration

Craftee is designed to be orthogonal to task planning/tracking systems like beads. It focuses on:
1. Managing concurrent AI agent sessions
2. Tracking file review state
3. Facilitating commits and pushes

It does NOT:
- Manage task/issue state (use beads or similar)
- Plan implementations (delegate to agents)
- Run validation/tests (delegate to agents or manual workflow)

## Future Considerations

- Agent prompt templates/macros
- Custom keyboard shortcut configuration
- Themes (following jjui patterns)
- Split-screen diff view options
- Integration hooks for external diff tools
- Session replay/logging
- Multi-repository workspace support
