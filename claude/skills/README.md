# Claude Code skills

Claude Code skills kept in this repo. To install for all projects:

```
mkdir -p ~/.claude/skills && ln -s ~/work/code/personal/env/claude/skills/<name> ~/.claude/skills/<name>
```

The same skill files work for Codex. Install them there too, so both agents run the same procedure:

```
mkdir -p ~/.codex/skills && ln -s ~/work/code/personal/env/claude/skills/<name> ~/.codex/skills/<name>
```

## Available skills

- **pre-compaction-checkpoint**: Use before a context compaction (/compact), when the user says they are about to compact, or when asked to "record everything so nothing is lost". Materializes every fact, decision, approval, in-flight task and next step into durable files, so the session can resume exactly where it left off without hallucinating.
  This skill is a thin loader; the procedure itself is `operating-model/procedures/checkpoint.md`.
- **figures**: Use before you draw, edit or review any figure or diagram, in any project. Loads the owner's figure standard and gives a tool that renders each Mermaid figure in the dark and the light theme and checks crossings, wires through or near boxes, arrow ends, labels, size, font and contrast.
  This skill is a thin loader; the standard and the procedure are `operating-model/procedures/figures.md`. The tool is `render_figures.py` with `figure_checks.js`.
