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
4. **Draw.** In Mermaid, use `%%{init: {"flowchart": {"curve": "step"}}}%%`, declare boxes in row order, and add
   invisible links (`~~~`) to hold a column. When Mermaid's automatic layout cannot meet section 2, do not
   keep changing its options: change the method. Use a hand-placed SVG on a page or an artifact; in a repository
   whose rules require Mermaid, split the figure or bring the owner the options.
5. **Render and check** with the skill's tool (section 5), in the dark and the light theme, at the page's width.
6. **Look at the screenshot** of every figure, at 100% zoom. The tool finds most faults, not all.
7. **Record** the check table in the PR test plan or under the page.
8. **A second reviewer** (the lead) checks the render before the owner sees it. A figure that fails a check is
   never shown to the owner. A test render that is visible to the owner is named as a test.

## 5. The check tool

`claude/skills/figures/render_figures.py <file.md or file.mmd> <out folder> [--width 1000|1600]` writes
`figures-dark.html` and `figures-light.html`. Each page renders every Mermaid block and prints, under each
figure, the measures of section 2 and 3 with a pass or fail. It also sets `window.FIGURE_CHECKS` for an agent
that reads the page with a script. Open both pages in a browser and read the tables. The tool reads no network
except the Mermaid library from the CDN.
