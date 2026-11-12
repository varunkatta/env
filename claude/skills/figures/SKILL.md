---
name: figures
description: Use before you draw, edit or review any figure or diagram (Mermaid, SVG, a figure in a document, a page or an artifact), in any project, personal or Mastrix. Loads the owner's figure standard (content, layout, visual style, procedure) and gives a tool that renders each figure in the dark and the light theme and checks crossings, wires through or near boxes, arrow ends, labels, size, font and contrast.
---

# Figures

This skill is a loader. The standard and the procedure live in one place:
`~/work/code/personal/env/operating-model/procedures/figures.md`.

Read that file in full and follow it before you draw, edit or review a figure. Do not keep a copy of the rules
here; amend the procedure file instead.

The check tool is in this folder:

```bash
python3 ~/.claude/skills/figures/render_figures.py <file.md or file.mmd> <out folder> --width 1000
```

Open `figures-dark.html` and `figures-light.html` from the out folder in a browser. Each figure has a table
under it with PASS or FAIL and the faults. A script can read `window.FIGURE_CHECKS`. A figure that fails is
not shown to the owner.
