#!/usr/bin/env python3
"""Show every figure of the given files in the dark and the light theme, with the checks of
operating-model/procedures/figures.md printed under each figure.

    render_figures.py <file.md|file.mmd|file.svg> [more files…] <out folder> [--width 1000|1600]

A Markdown file gives its Mermaid blocks and the .svg files it links as images. Writes
<out>/figures-dark.html and <out>/figures-light.html. Open both in a browser and read the tables; a script can
read window.FIGURE_CHECKS. The pages load only the Mermaid library from the CDN.
"""

import argparse
import html
import re
from pathlib import Path

MERMAID = "https://cdn.jsdelivr.net/npm/mermaid@10.9.1/dist/mermaid.min.js"
CHECKS = Path(__file__).with_name("figure_checks.js")


def figures(source: Path) -> list[tuple[str, str, str]]:
    """(name, kind, body) for each figure: kind is "mermaid" or "svg"."""
    text = source.read_text()
    if source.suffix == ".mmd":
        return [(source.stem, "mermaid", text)]
    if source.suffix == ".svg":
        return [(source.name, "svg", text)]
    out, heading = [], source.stem
    pattern = r"(```mermaid\n.*?```|!\[[^\]]*\]\(([^)\s]+\.svg)\))"
    for part in re.split(r"(```mermaid\n.*?```|!\[[^\]]*\]\([^)\s]+\.svg\))", text, flags=re.S):
        if part.startswith("```mermaid"):
            out.append((heading, "mermaid", part[len("```mermaid\n") : -3]))
        elif re.fullmatch(pattern, part, flags=re.S):
            link = re.search(r"\(([^)\s]+\.svg)\)", part).group(1)
            out.append((f"{heading}: {link}", "svg", (source.parent / link).read_text()))
        else:
            heads = re.findall(r"^#+ (.+)$", part, flags=re.M)
            if heads:
                heading = heads[-1]
    return out


def page(items: list[tuple[str, str, str]], theme: str, width: int) -> str:
    bg, fg = ("#0d1117", "#e6edf3") if theme == "dark" else ("#ffffff", "#1f2328")
    blocks = []
    for i, (name, kind, body) in enumerate(items):
        title = html.escape(f"Figure {i + 1} ({name})")
        if kind == "svg":
            blocks.append(f'<h3>{title}</h3><div data-figure="svg" data-name="{title}">{body}</div>')
        else:
            blocks.append(
                f'<h3>{title}</h3><div data-figure="mermaid" data-name="{title}" data-source="{html.escape(body)}">'
                f'<pre class="mermaid">\n{html.escape(body)}</pre></div>'
            )
    force = "force-dark" if theme == "dark" else ""
    return f"""<!doctype html><html><head><meta charset="utf-8"><title>Figure check ({theme})</title>
<style>body{{background:{bg};color:{fg};font:14px/1.5 system-ui,sans-serif;margin:0;padding:16px;width:{width}px}}
h3{{font-size:15px;margin:28px 0 8px}} .figure-check{{font:12px/1.5 ui-monospace,monospace;margin:6px 0 20px;padding:8px;border:1px solid #888}}</style>
</head><body class="{force}">{"".join(blocks)}
<script src="{MERMAID}"></script>
<script>{CHECKS.read_text()}</script>
<script>mermaid.initialize({{startOnLoad:false,theme:"{theme}"}});
(async()=>{{let n=0;
for(const h of document.querySelectorAll('[data-figure=mermaid]')){{
try{{const r=await mermaid.render("fig"+(++n),h.dataset.source);h.innerHTML=r.svg}}catch(e){{console.error(e);h.textContent="render error: "+e}}}}
setTimeout(()=>figureChecks({width}),500)}})();</script></body></html>"""


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("paths", type=Path, nargs="+", help="source files, then the out folder")
    ap.add_argument("--width", type=int, default=1000, choices=(1000, 1600))
    a = ap.parse_args()
    *sources, out = a.paths
    items = [f for s in sources for f in figures(s)]
    out.mkdir(parents=True, exist_ok=True)
    for theme, name in (("dark", "figures-dark.html"), ("default", "figures-light.html")):
        (out / name).write_text(page(items, theme, a.width))
    print(f"{len(items)} figures -> {out / 'figures-dark.html'} and {out / 'figures-light.html'}")


if __name__ == "__main__":
    main()
