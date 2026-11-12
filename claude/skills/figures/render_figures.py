#!/usr/bin/env python3
"""Render every Mermaid figure of a Markdown file (or one .mmd file) in the dark and the light theme, with
the checks of operating-model/procedures/figures.md printed under each figure.

    render_figures.py <file.md|file.mmd> <out folder> [--width 1000|1600]

Writes <out>/figures-dark.html and <out>/figures-light.html. Open both in a browser and read the tables; a
script can read window.FIGURE_CHECKS. The pages load only the Mermaid library from the CDN.
"""

import argparse
import html
import re
from pathlib import Path

MERMAID = "https://cdn.jsdelivr.net/npm/mermaid@10.9.1/dist/mermaid.min.js"
CHECKS = Path(__file__).with_name("figure_checks.js")


def figures(source: Path) -> list[tuple[str, str]]:
    text = source.read_text()
    if source.suffix == ".mmd":
        return [(source.stem, text)]
    out, heading = [], source.stem
    for line_block in re.split(r"(```mermaid\n.*?```)", text, flags=re.S):
        if line_block.startswith("```mermaid"):
            out.append((heading, line_block[len("```mermaid\n") : -3]))
        else:
            heads = re.findall(r"^#+ (.+)$", line_block, flags=re.M)
            if heads:
                heading = heads[-1]
    return [(f"Figure {i + 1} ({h})", body) for i, (h, body) in enumerate(out)]


def page(items: list[tuple[str, str]], theme: str, width: int) -> str:
    bg, fg = ("#0d1117", "#e6edf3") if theme == "dark" else ("#ffffff", "#1f2328")
    blocks = "\n".join(
        f'<h3>{html.escape(name)}</h3><div data-name="{html.escape(name)}" data-source="{html.escape(body)}">'
        f'<pre class="mermaid">\n{html.escape(body)}</pre></div>'
        for name, body in items
    )
    return f"""<!doctype html><html><head><meta charset="utf-8"><title>Figure check ({theme})</title>
<style>body{{background:{bg};color:{fg};font:14px/1.5 system-ui,sans-serif;margin:0;padding:16px;width:{width}px}}
h3{{font-size:15px;margin:28px 0 8px}} .figure-check{{font:12px/1.5 ui-monospace,monospace;margin:6px 0 20px;padding:8px;border:1px solid #888}}</style>
</head><body>{blocks}
<script src="{MERMAID}"></script>
<script>{CHECKS.read_text()}</script>
<script>mermaid.initialize({{startOnLoad:false,theme:"{theme}"}});
mermaid.run().then(()=>setTimeout(()=>figureChecks({width}),300));</script></body></html>"""


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("source", type=Path)
    ap.add_argument("out", type=Path)
    ap.add_argument("--width", type=int, default=1000, choices=(1000, 1600))
    a = ap.parse_args()
    items = figures(a.source)
    a.out.mkdir(parents=True, exist_ok=True)
    for theme, name in (("dark", "figures-dark.html"), ("default", "figures-light.html")):
        (a.out / name).write_text(page(items, theme, a.width))
    print(f"{len(items)} figures -> {a.out / 'figures-dark.html'} and {a.out / 'figures-light.html'}")


if __name__ == "__main__":
    main()
