# Unity Orchestrator

[한국어](README.ko.md)

A multi-agent orchestration plugin for Unity C# game development with Claude Code.

Planner → Implementer → Evaluator loop inspired by GAN architecture — one agent builds, another evaluates, preventing self-congratulatory assessments.

## How It Works

```
[Your Request]
       │
       ▼
  ┌─────────┐     Sprint plan + feature specs
  │ Planner │ ──→ .unity-orc/plans/*.md
  └─────────┘
       │
       ▼
  ┌──────────────┐     C# code + git commits
  │ Implementer  │ ──→ .unity-orc/unity-progress.md
  └──────────────┘
       │
       ▼
  ┌───────────┐     Pass → next feature
  │ Evaluator │ ──→
  └───────────┘     Fail → feedback to Implementer
```

## Installation

```bash
# From GitHub
claude plugin add https://github.com/cookapps-yhkim2/unity-orchestrator
```

## Quick Start

1. **Initialize** your project:
   > "프로젝트 초기화해줘" / "Initialize my project"

2. **Plan** your sprint:
   > "스프린트 계획 세워줘" / "Let's plan the next sprint"

3. **Implement** → the Implementer agent writes C# code following Unity best practices

4. **Evaluate** → the Evaluator agent reviews against acceptance criteria

5. **Iterate** → fix feedback and move to the next feature

## Components

### Skills

| Skill | Purpose |
|-------|---------|
| **unity-init** | Project initialization, `.unity-orc/` setup |
| **unity-sprint** | Sprint contract negotiation and management |
| **unity-csharp** | Unity C# coding guide, patterns, and conventions |
| **unity-gamedesign** | Game design documentation (balancing, AI behavior trees) |

### Agents

| Agent | Role | Model |
|-------|------|-------|
| **Planner** | Analyzes requirements → creates sprint plans | claude-opus-4-6 |
| **Implementer** | Writes C# code → git commits | inherit |
| **Evaluator** | Verifies implementation → pass/fail reports | inherit |

### Hooks

| Event | Action |
|-------|--------|
| **SessionStart** | Auto-loads project context (progress, features, git log) |
| **PreToolUse** | Checks C# coding conventions on `.cs` file writes |
| **Stop** | Reminds to update progress and commit changes |

## File-Based State Management

All agent communication happens through files in `.unity-orc/`:

```
.unity-orc/
├── unity-progress.md       # Overall progress tracking
├── feature_list.json       # Feature list + completion status
├── plans/                  # Sprint plans
│   └── open-questions.md   # Open questions
└── evaluations/            # Evaluation reports
```

## External Tool Connectors

Connect your favorite tools via `CONNECTORS.md`:

| Category | Placeholder | Options |
|----------|------------|---------|
| Project Tracker | `~~project tracker~~` | Jira, Linear, Asana, Trello |
| Source Control | `~~source control~~` | GitHub, GitLab, Bitbucket |
| Docs | `~~docs~~` | Confluence, Notion, Obsidian |
| Chat | `~~chat~~` | Slack, Discord, Microsoft Teams |

## Core Principles

- **GAN-inspired evaluation**: The Evaluator never trusts the Implementer's self-assessment
- **File-based state**: All state persists across sessions via `.unity-orc/`
- **Sprint contracts**: Agree on "what to build & how to verify" before coding
- **One feature at a time**: Small units, frequent commits

## License

MIT
