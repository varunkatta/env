#!/usr/bin/env python3
"""Write a hand-placed SVG figure from a JSON spec, in the conventions of
operating-model/procedures/figures.md § 6. The author places every box and every wire bend; this script only
draws them in one style.

    svg_figure.py <spec.json> [<out.svg>]

Spec:
{
  "width": 1000, "height": 300,
  "frames": [{"x": 20, "y": 120, "w": 960, "h": 120, "title": "the owner's Mac"}],
  "boxes":  [{"id": "ingest", "kind": "proc", "x": 230, "y": 160, "w": 140, "h": 56,
              "label": ["ingestion"], "planned": false}],
  "wires":  [{"from": "sess", "to": "ingest", "points": [[180, 188], [228, 188]],
              "num": "①", "at": [204, 188], "dashed": false}],
  "legend": {"x": 40, "y": 262, "kinds": ["data", "proc", "outside"], "planned": true}
}
kind: data (a cylinder), proc (a rectangle), outside (a rounded box), decision (a diamond).
"""

import json
import sys
from html import escape
from pathlib import Path

STYLE = """
    .wire { stroke: #57606a; stroke-width: 1.6; fill: none; }
    .wire.dashed { stroke-dasharray: 6 4; }
    .arrowhead { fill: #57606a; }
    .frame rect { fill: none; stroke: #8b949e; stroke-width: 1; }
    .title, .legend text { fill: #57606a; font-size: 14px; }
    @media (prefers-color-scheme: dark) {
      .wire { stroke: #c9d1d9; } .arrowhead { fill: #c9d1d9; } .title, .legend text { fill: #c9d1d9; }
    }
    .force-dark .wire { stroke: #c9d1d9; } .force-dark .arrowhead { fill: #c9d1d9; }
    .force-dark .title, .force-dark .legend text { fill: #c9d1d9; }
    .data .shape { fill: #0c2d48; stroke: #38bdf8; stroke-width: 1.2; }
    .proc .shape { fill: #161b22; stroke: #8b949e; stroke-width: 1.2; }
    .outside .shape { fill: #3b2f1a; stroke: #d29922; stroke-width: 1.2; }
    .decision .shape { fill: #161b22; stroke: #8b949e; stroke-width: 1.2; }
    .planned .shape { stroke-dasharray: 5 4; }
    .box text { fill: #e6edf3; font-size: 15px; text-anchor: middle; dominant-baseline: central; }
    .num rect { fill: #30363d; } .num text { fill: #e6edf3; font-size: 14px; text-anchor: middle; dominant-baseline: central; }
"""
LEGEND_TEXT = {"data": "data", "proc": "our code", "outside": "outside service", "decision": "decision"}


def shape(b: dict) -> str:
    x, y, w, h = b["x"], b["y"], b["w"], b["h"]
    if b["kind"] == "data":
        ry = 10
        return (f'<path class="shape" d="M{x},{y + ry} a{w / 2},{ry} 0 0,0 {w},0 v{h - 2 * ry} '
                f'a{w / 2},{ry} 0 0,1 {-w},0 z M{x},{y + ry} a{w / 2},{ry} 0 0,1 {w},0"/>')
    if b["kind"] == "outside":
        return f'<rect class="shape" x="{x}" y="{y}" width="{w}" height="{h}" rx="14"/>'
    if b["kind"] == "decision":
        cx, cy = x + w / 2, y + h / 2
        return f'<polygon class="shape" points="{cx},{y} {x + w},{cy} {cx},{y + h} {x},{cy}"/>'
    return f'<rect class="shape" x="{x}" y="{y}" width="{w}" height="{h}" rx="2"/>'


def label(b: dict) -> str:
    lines = b["label"]
    cx = b["x"] + b["w"] / 2
    cy = b["y"] + b["h"] / 2 + (4 if b["kind"] == "data" else 0)
    first = cy - (len(lines) - 1) * 9
    return "".join(f'<text x="{cx}" y="{first + i * 18}">{escape(t)}</text>' for i, t in enumerate(lines))


def svg(spec: dict) -> str:
    W, H = spec["width"], spec["height"]
    out = [
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}" '
        f'font-family="-apple-system, \'Segoe UI\', Helvetica, Arial, sans-serif" role="img" '
        f'aria-label="{escape(spec.get("title", "figure"))}">',
        f"  <style>{STYLE}  </style>",
        '  <defs><marker id="arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="8" markerHeight="8" '
        'orient="auto-start-reverse"><path class="arrowhead" d="M0,0 L10,5 L0,10 z"/></marker></defs>',
    ]
    for f in spec.get("frames", []):
        out.append(f'  <g class="frame"><rect x="{f["x"]}" y="{f["y"]}" width="{f["w"]}" height="{f["h"]}" rx="6"/>'
                   f'<text class="title" x="{f["x"] + 12}" y="{f["y"] + 20}">{escape(f["title"])}</text></g>')
    for b in spec["boxes"]:
        cls = "box " + b["kind"] + (" planned" if b.get("planned") else "")
        out.append(f'  <g class="{cls}" id="{b["id"]}">{shape(b)}{label(b)}</g>')
    for w in spec["wires"]:
        pts = " ".join(f"{x},{y}" for x, y in w["points"])
        dash = " dashed" if w.get("dashed") else ""
        start = ' marker-start="url(#arrow)"' if w.get("both") else ""
        out.append(f'  <polyline class="wire{dash}" data-from="{w["from"]}" data-to="{w["to"]}" points="{pts}" '
                   f'marker-end="url(#arrow)"{start}/>')
    for w in spec["wires"]:
        if not w.get("num"):
            continue
        x, y = w["at"]
        text = w["num"]
        width = max(22, 9 * len(text) + 10)
        out.append(f'  <g class="num"><rect x="{x - width / 2}" y="{y - 10}" width="{width}" height="20" rx="4"/>'
                   f'<text x="{x}" y="{y}">{escape(text)}</text></g>')
    lg = spec.get("legend")
    if lg:
        x, y, parts = lg["x"], lg["y"], []
        kinds = list(lg["kinds"]) + (["planned"] if lg.get("planned") else [])
        for k in kinds:
            if k == "planned":
                parts.append(f'<g class="proc planned"><rect class="shape" x="{x}" y="{y}" width="18" height="14" rx="2"/></g>'
                             f'<text x="{x + 26}" y="{y + 12}">dashed: not built yet</text>')
                x += 190
                continue
            rx = 6 if k == "outside" else 2
            parts.append(f'<g class="{k}"><rect class="shape" x="{x}" y="{y}" width="18" height="14" rx="{rx}"/></g>'
                         f'<text x="{x + 26}" y="{y + 12}">{LEGEND_TEXT[k]}</text>')
            x += 26 + 9 * len(LEGEND_TEXT[k]) + 30
        out.append('  <g class="legend">' + "".join(parts) + "</g>")
    out.append("</svg>")
    return "\n".join(out) + "\n"


def main() -> None:
    spec_path = Path(sys.argv[1])
    out = Path(sys.argv[2]) if len(sys.argv) > 2 else spec_path.with_suffix(".svg")
    out.write_text(svg(json.loads(spec_path.read_text())))
    print(out)


if __name__ == "__main__":
    main()
