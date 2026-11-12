# Figures: the standard and the procedure

A procedure any agent follows, in any harness and in any project, personal or Mastrix. Use it before you
draw, edit or review a figure (a diagram in a document, a page or an artifact). The owner set it on
2026-11-12: "all diagrams we generate should be beautiful and arrows mostly non curvy and overlapping",
"I want these diagram making skills and preferences be part of my personal repo too".

This file owns the owner's figure standard. In a Mastrix repository, decision-authority's
`support-docs/documentation-discipline.md` § Figures and `architecture-docs/architecture.md` § "Layout follows
the wires" hold the company's copy; where the two differ, follow the stricter rule. The skill
`claude/skills/figures` loads this file and holds the render-and-check tool.

## 1. Content

| # | Rule |
|---|---|
| C1 | One concern for each figure. Topology, governance and a call sequence are three figures |
| C2 | A figure is high level, or it is a close view of one component. Never both |
| C3 | Each box is a real part, with the name that the code gives it. A part that is not built is dashed, and the text says so |
| C4 | Each wire has a number (①, ②, …). A table under the figure gives `# \| From \| To \| Parameters \| Notes`; Notes link the document or code that specifies that interface |
| C5 | A wire starts at the component that sends it, not at the group around it |
| C6 | Deployment boundaries are drawn: for example the Mac, the customer's account, the cloud, the vendor |
| C7 | Dashed means "not built". A stacked box means "one of many" |
| C8 | A figure that shows the members of a datamodel shows all of them |
| C9 | Text beside the figure explains each box in plain words |

## 2. Layout

| # | Rule | Check (section 5) |
|---|---|---|
| L1 | **Rows follow the calls.** Choose one main direction (left to right, or top to bottom). A box that only calls into one other box sits one row (or column) after it | inspect |
| L2 | A shared store sits on the row of the box that uses it most; it is not "called down into" | inspect |
| L3 | **Each box sits level with what its wires reach**, so wires are short and flat | inspect |
| L4 | Wires are straight lines or right-angle lines. No curves, no diagonal lines | `curved`, `diagonal` = 0 |
| L5 | **No wire crosses another wire, and no wire crosses a box.** A wire whose straight line would cross a box bends once, at a right angle, where both legs clear every box | `crossings`, `throughBox` = 0 |
| L6 | **Clearance:** a wire stays at least 12 pixels away from every box it does not connect, and from every group title | `grazing` = 0 |
| L7 | **Arrow ends:** a wire leaves and enters a box at the middle third of a side, at a right angle to that side, never at a corner | `badEnds` = 0 |
| L8 | Two wires never share one track | `sharedTrack` = 0 |
| L9 | At most 9 boxes and 10 wires in one figure, and at most 4 wires on one box. More: split the figure (C1) | `boxes`, `wires`, `maxDegree` |
| L10 | At most one wire goes against the main direction, and it has a label | inspect |
| L11 | A box label has 4 words or fewer on each line, and 2 lines or fewer. Detail goes in the wire table | inspect |
| L12 | A wire number sits on its wire and touches no box, no other label and no group title | `labelOverlap` = 0 |
| L13 | Boxes of one kind have one size and sit on one grid, with equal space between them | inspect |
| L14 | Groups do not overlap, and a nested group's title does not touch its parent's title | `groupOverlap` = 0 |
| L15 | The figure fits its page with no side scroll: 1,000 pixels for a document column, 1,600 pixels for a full screen | `width` |

## 3. Visual style

| # | Rule | Check |
|---|---|---|
| V1 | Dark theme first; the figure is also readable in the light theme | both renders |
| V2 | Three fill colours at most, each with one meaning, and a legend: for example data stores, our code, outside services | inspect |
| V3 | One shape for each kind: a cylinder for data, a rectangle for a process, a rounded box for an outside program or service, a diamond for a decision | inspect |
| V4 | Text contrast 4.5 to 1 or more, in both themes, for box text, wire numbers and group titles; text 14 pixels or more | `minContrast`, `minFont` |
| V5 | Group fills are transparent; group borders are thin and muted | inspect |
| V6 | No decoration: no shadow, no gradient, no icon that carries no meaning | inspect |

## 4. Procedure

1. **Search all the rules first.** In a repository, search the whole repository (for example `git grep -i
   "figure\|diagram\|layout\|wire"`), not only the pages its router links. Never say that a rule does not exist
   before that search.
2. **Write the wire table first** (C4). If it has more than 10 rows, split the figure before you draw.
3. **Place the boxes on a grid by the rows rule** (L1 to L3) on paper or in the table: row and column for each box.
4. **Draw in Mermaid** (the owner's ruling, 2026-11-12: "I like Mermaid over Hand-placed SVG"). Use the ELK
   layout: start each flowchart with
   `%%{init: {"flowchart": {"defaultRenderer": "elk"}, "themeVariables": {"clusterBkg": "transparent", "edgeLabelBackground": "#30363d"}}}%%`
   and add `linkStyle default color:#e6edf3`, so wire numbers are light text on a dark chip in both themes. In a
   trial on 2026-11-12, ELK gave 0 crossings and clean arrow ends where the default layout did not. Choose the
   direction (`LR` or `TB`) that keeps the figure inside the page width. Declare boxes in row order. Put an
   outside service in a group of its own, so the wire to it is short. Use `sequenceDiagram` for an order of
   events. When a figure still fails a check, change the order of the boxes, the direction or the split
   before you change the rule. Known limits of ELK, which the owner saw before this ruling: wires can pass
   about 10 pixels from a box, and ELK draws group fills grey. A hand-placed SVG (section 6) is used only on
   the owner's word. Before a figure in a repository relies on ELK, check that the repository's host renders it
   (GitHub bundles its own Mermaid).
5. **Render and check** with the skill's tool (section 5), in the dark and the light theme, at the page's width.
6. **Look at the screenshot** of every figure, at 100% zoom. The tool finds most faults, not all.
7. **Record** the check table in the PR test plan or under the page.
8. **A second reviewer** (the lead) checks the render before the owner sees it. A figure that fails a check is
   never shown to the owner. A test render that is visible to the owner is named as a test.

## 5. The check tool

`claude/skills/figures/render_figures.py <file.md, .mmd or .svg …> <out folder> [--width 1000|1600]` writes
`figures-dark.html` and `figures-light.html`. Each page shows every Mermaid block and every SVG figure (an
`.svg` file named on the command line, or one that a Markdown file links as an image), and prints, under each
figure, the measures of sections 2 and 3 with a pass or fail. It also sets `window.FIGURE_CHECKS` for an agent
that reads the page with a script. Open both pages in a browser and read the tables. The tool reads no network
except the Mermaid library from the CDN. A check that reads fewer wires than the figure declares fails.

## 6. Conventions of a hand-placed SVG (only on the owner's word)

`svg_figure.py <spec.json>` in the skill writes one from a spec of hand-placed boxes and wires.

| Part | Markup | Why |
|---|---|---|
| Size | `viewBox="0 0 <w> <h>"` with `width` and `height`; the width is the page's (1,000 for a document) | the check reads the width |
| Grid | box positions on a 10-pixel grid; boxes of one kind have one size | L13 |
| Box | `<g class="box <kind>" id="<name>">` with one shape and one `<text class="label">`; `<kind>` is `data`, `proc`, `outside` or `decision`; a box that is not built adds `planned` (a dashed border) | the check finds boxes; V2, V3, C7 |
| Wire | `<line>`, `<polyline>` or `<path>` with `class="wire"`, `data-from="<box id>"`, `data-to="<box id>"` and `marker-end`; straight segments only | the check finds wires and their ends |
| Wire number | `<g class="num">` with a `<rect>` and a `<text>` | L12 |
| Group | `<g class="frame">` with a `<rect>` and a `<text class="title">` in its top-left corner | L14, C6 |
| Legend | `<g class="legend">`, one swatch for each fill in use | V2 |
| Theme | colours in the SVG's own `<style>`: light values first, dark values under `@media (prefers-color-scheme: dark)` and again under `.force-dark` (the check page sets it) | V1 |
| Text | `font-family` with system fallbacks; 14 pixels or more | V4 |
