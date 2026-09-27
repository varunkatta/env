# Claude Code skills

Claude Code skills kept in this repo. To install for all projects:

```
mkdir -p ~/.claude/skills && ln -s ~/work/code/personal/env/claude/skills/<name> ~/.claude/skills/<name>
```

## Available skills

- **pre-compaction-checkpoint**: Use before a context compaction (/compact), when the user says they are about to compact, or when asked to "record everything so nothing is lost". Materializes every fact, decision, approval, in-flight task and next step into durable files, so the session can resume exactly where it left off without hallucinating.
