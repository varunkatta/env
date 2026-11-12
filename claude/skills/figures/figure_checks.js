// Figure checks (operating-model/procedures/figures.md, sections 2, 3 and 6).
// figureChecks(width) reads every figure on the page: a Mermaid render (dagre or ELK) or a hand-placed SVG
// that follows section 6. It draws a table under each figure and sets window.FIGURE_CHECKS.
// Pure DOM geometry: no network, no model.
(function () {
  const CLEARANCE = 12;     // L6: pixels between a wire and a box it does not connect
  const TITLE_CLEAR = 6;    // L6: pixels between a wire and a group title
  const SIDE_TOL = 8;       // L7: how far an arrow end may sit from the box side
  const MAX_BOXES = 9, MAX_WIRES = 10, MAX_DEGREE = 4;

  // ---- geometry ----
  function rgb(c) { const m = (c || "").match(/[\d.]+/g); return m && m.length >= 3 ? m.slice(0, 3).map(Number) : null; }
  function transparent(c) { return !c || c === "none" || /rgba\([^)]*,\s*0\)/.test(c) || c === "transparent"; }
  function ch(v) { v /= 255; return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4); }
  function lum(c) { return 0.2126 * ch(c[0]) + 0.7152 * ch(c[1]) + 0.0722 * ch(c[2]); }
  function contrast(a, b) { const x = lum(a), y = lum(b); return (Math.max(x, y) + 0.05) / (Math.min(x, y) + 0.05); }
  function pageBg() { let e = document.body; while (e) { const c = getComputedStyle(e).backgroundColor; if (!transparent(c)) return rgb(c); e = e.parentElement; } return [255, 255, 255]; }
  function screen(svg, el, x, y) { const p = svg.createSVGPoint(); p.x = x; p.y = y; const q = p.matrixTransform(el.getScreenCTM()); return [q.x, q.y]; }
  function pathPoints(svg, el) {
    const tag = el.tagName.toLowerCase();
    let raw = [];
    if (tag === "line") raw = [[+el.getAttribute("x1"), +el.getAttribute("y1")], [+el.getAttribute("x2"), +el.getAttribute("y2")]];
    else if (tag === "polyline" || tag === "polygon") { const n = (el.getAttribute("points") || "").match(/-?\d+\.?\d*/g).map(Number); for (let i = 0; i + 1 < n.length; i += 2) raw.push([n[i], n[i + 1]]); }
    else { const n = ((el.getAttribute("d") || "").match(/-?\d+\.?\d*(e-?\d+)?/gi) || []).map(Number); for (let i = 0; i + 1 < n.length; i += 2) raw.push([n[i], n[i + 1]]); }
    const out = raw.map(([x, y]) => screen(svg, el, x, y));
    return out.filter((p, i) => i === 0 || Math.hypot(p[0] - out[i - 1][0], p[1] - out[i - 1][1]) > 0.5);
  }
  function inside(p, r, inset) { return p[0] > r.left + inset && p[0] < r.right - inset && p[1] > r.top + inset && p[1] < r.bottom - inset; }
  function segHitsRect(a, b, r) { const L = Math.hypot(b[0] - a[0], b[1] - a[1]) || 1; for (let t = 0; t <= L; t += 2) { const p = [a[0] + (b[0] - a[0]) * t / L, a[1] + (b[1] - a[1]) * t / L]; if (inside(p, r, 0)) return true; } return false; }
  function ptSeg(p, a, b) { const dx = b[0] - a[0], dy = b[1] - a[1], L2 = dx * dx + dy * dy || 1; let t = ((p[0] - a[0]) * dx + (p[1] - a[1]) * dy) / L2; t = Math.max(0, Math.min(1, t)); return Math.hypot(p[0] - (a[0] + t * dx), p[1] - (a[1] + t * dy)); }
  function orient(p, q, r) { return (q[0] - p[0]) * (r[1] - p[1]) - (q[1] - p[1]) * (r[0] - p[0]); }
  function properCross(a, b, c, d) { const d1 = orient(c, d, a), d2 = orient(c, d, b), d3 = orient(a, b, c), d4 = orient(a, b, d); return ((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) && ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0)); }
  function segSeg(a, b, c, d) { if (properCross(a, b, c, d)) return 0; return Math.min(ptSeg(a, c, d), ptSeg(b, c, d), ptSeg(c, a, b), ptSeg(d, a, b)); }
  function segDistRect(a, b, r) { if (segHitsRect(a, b, r)) return 0; const c = [[r.left, r.top], [r.right, r.top], [r.right, r.bottom], [r.left, r.bottom]]; let m = Infinity; for (let i = 0; i < 4; i++) m = Math.min(m, segSeg(a, b, c[i], c[(i + 1) % 4])); return m; }
  function rectDist(p, r) { const dx = Math.max(r.left - p[0], 0, p[0] - r.right), dy = Math.max(r.top - p[1], 0, p[1] - r.bottom); return Math.hypot(dx, dy); }
  function nearestNode(p, nodes) { let best = null, bd = Infinity; nodes.forEach((n, i) => { const d = rectDist(p, n.r); if (d < bd) { bd = d; best = i; } }); return best; }
  function overlap(a, b) { return a.left < b.right && b.left < a.right && a.top < b.bottom && b.top < a.bottom; }
  function contains(a, b) { return a.left <= b.left && a.right >= b.right && a.top <= b.top && a.bottom >= b.bottom; }
  function endOk(end, prev, r) {
    const s = [
      { d: Math.abs(end[1] - r.top), along: (end[0] - r.left) / r.width, vertical: true },
      { d: Math.abs(end[1] - r.bottom), along: (end[0] - r.left) / r.width, vertical: true },
      { d: Math.abs(end[0] - r.left), along: (end[1] - r.top) / r.height, vertical: false },
      { d: Math.abs(end[0] - r.right), along: (end[1] - r.top) / r.height, vertical: false },
    ].sort((x, y) => x.d - y.d)[0];
    if (s.d > SIDE_TOL || s.along < 1 / 3 - 0.02 || s.along > 2 / 3 + 0.02) return false;
    const dx = Math.abs(end[0] - prev[0]), dy = Math.abs(end[1] - prev[1]);
    return s.vertical ? dx <= 2 : dy <= 2;
  }

  // ---- models: what a figure is made of ----
  function mermaidModel(svg, src) {
    const groupIds = new Set((src.match(/subgraph\s+([\w-]+)/g) || []).map(s => s.split(/\s+/)[1]));
    const nodes = [...svg.querySelectorAll("g.node")]
      .filter(g => !groupIds.has((g.id || "").replace(/^flowchart-/, "").replace(/-\d+$/, "")))
      .filter(g => !g.classList.contains("cluster") && !g.classList.contains("subgraph"))
      .map(g => ({ id: (g.id || "").replace(/^flowchart-/, "").replace(/-\d+$/, ""), r: g.getBoundingClientRect(), g, shape: g.querySelector("rect, path, polygon, circle, ellipse"), text: g.querySelector(".nodeLabel, text") }))
      .filter(n => n.r.width > 1);
    const byId = id => nodes.findIndex(n => n.id === id);
    const edges = [...new Set([...svg.querySelectorAll(".edgePaths path, path.flowchart-link")])].filter(p => !p.closest("marker")).map(p => {
      const pts = pathPoints(svg, p), cls = p.getAttribute("class") || "";
      const ls = (cls.match(/LS-(\S+)/) || [])[1], le = (cls.match(/LE-(\S+)/) || [])[1];
      return { pts, curved: /[CQSA]/i.test(p.getAttribute("d") || ""), src: ls && byId(ls) >= 0 ? byId(ls) : nearestNode(pts[0], nodes), dst: le && byId(le) >= 0 ? byId(le) : nearestNode(pts[pts.length - 1], nodes) };
    }).filter(e => e.pts.length >= 2);
    const labels = [...svg.querySelectorAll("g.edgeLabel")].filter(g => g.getBoundingClientRect().width > 1).map(g => ({ r: g.getBoundingClientRect(), text: g.querySelector("span, text"), bg: g.querySelector("span, rect") }));
    const frames = [...svg.querySelectorAll("g.cluster, g.subgraph")].map(g => ({ r: (g.querySelector(":scope > rect") || g).getBoundingClientRect(), title: g.querySelector(".cluster-label, :scope > g.label"), titleText: g.querySelector(".nodeLabel, .cluster-label span, text") }));
    const declared = (src.match(/-->|-\.->|==>|<-->/g) || []).length;
    return { nodes, edges, labels, frames, declared };
  }
  function handModel(svg) {
    const nodes = [...svg.querySelectorAll("g.box")].map(g => ({ id: g.id, r: (g.querySelector("rect, path, polygon, circle, ellipse") || g).getBoundingClientRect(), g, shape: g.querySelector("rect, path, polygon, circle, ellipse"), text: g.querySelector("text") }));
    const byId = id => nodes.findIndex(n => n.id === id);
    const wires = [...svg.querySelectorAll(".wire")];
    const edges = wires.map(w => { const pts = pathPoints(svg, w); return { pts, curved: /[CQSA]/i.test(w.getAttribute("d") || ""), src: byId(w.dataset.from), dst: byId(w.dataset.to), named: !!(w.dataset.from && w.dataset.to) }; });
    const labels = [...svg.querySelectorAll("g.num")].map(g => ({ r: g.getBoundingClientRect(), text: g.querySelector("text"), bg: g.querySelector("rect") }));
    const frames = [...svg.querySelectorAll("g.frame")].map(g => ({ r: g.querySelector("rect").getBoundingClientRect(), title: g.querySelector("text.title"), titleText: g.querySelector("text.title") }));
    return { nodes, edges, labels, frames, declared: wires.length, hand: true };
  }

  // ---- the checks ----
  function analyse(svg, m, target, name) {
    const { nodes, edges, labels, frames } = m;
    const res = { figure: name, kind: m.hand ? "svg" : "mermaid", boxes: nodes.length, wires: edges.length, curved: 0, diagonal: 0, crossings: 0, throughBox: 0, grazing: 0, badEnds: 0, sharedTrack: 0, maxDegree: 0, labelOverlap: 0, groupOverlap: 0, width: 0, minFont: 99, minContrast: 99, faults: [] };
    const f = s => res.faults.push(s);
    if (edges.length === 0 && m.declared === 0) f("the tool found no wire: check the figure's markup (section 6)");
    if (m.declared && m.declared !== edges.length) f(`the tool read ${edges.length} wires, the figure declares ${m.declared}`);
    if (m.hand) edges.forEach((e, i) => { if (!e.named || e.src < 0 || e.dst < 0) f(`wire ${i + 1} has no data-from or data-to that names a box`); });
    const nm = i => `wire ${i + 1} (${nodes[edges[i].src]?.id}→${nodes[edges[i].dst]?.id})`;
    const deg = nodes.map(() => 0); edges.forEach(e => { if (e.src >= 0) deg[e.src]++; if (e.dst >= 0) deg[e.dst]++; }); res.maxDegree = Math.max(0, ...deg);
    edges.forEach((e, i) => {
      if (e.curved) { res.curved++; f(nm(i) + " is curved"); }
      for (let a = 0; a + 1 < e.pts.length; a++) { const [p, q] = [e.pts[a], e.pts[a + 1]]; if (Math.abs(p[0] - q[0]) > 2 && Math.abs(p[1] - q[1]) > 2) { res.diagonal++; f(nm(i) + " has a diagonal leg"); break; } }
      nodes.forEach((n, k) => {
        if (k === e.src || k === e.dst) return;
        let min = Infinity; for (let a = 0; a + 1 < e.pts.length; a++) min = Math.min(min, segDistRect(e.pts[a], e.pts[a + 1], n.r));
        if (min === 0) { res.throughBox++; f(nm(i) + " crosses box " + n.id); }
        else if (min < CLEARANCE) { res.grazing++; f(nm(i) + " passes " + Math.round(min) + " px from box " + n.id); }
      });
      const end = e.pts[e.pts.length - 1], prev = e.pts[e.pts.length - 2], start = e.pts[0], next = e.pts[1];
      if (nodes[e.dst] && !endOk(end, prev, nodes[e.dst].r)) { res.badEnds++; f(nm(i) + " does not enter the middle of a side of " + nodes[e.dst].id); }
      if (nodes[e.src] && !endOk(start, next, nodes[e.src].r)) { res.badEnds++; f(nm(i) + " does not leave the middle of a side of " + nodes[e.src].id); }
      frames.forEach(fr => { if (!fr.title) return; const t = fr.title.getBoundingClientRect(); if (t.width < 1) return; let min = Infinity; for (let a = 0; a + 1 < e.pts.length; a++) min = Math.min(min, segDistRect(e.pts[a], e.pts[a + 1], t)); if (min < TITLE_CLEAR) { res.grazing++; f(nm(i) + " touches a group title"); } });
    });
    for (let i = 0; i < edges.length; i++) for (let j = i + 1; j < edges.length; j++) {
      let cross = false, shared = false;
      const sh = [edges[i].src, edges[i].dst].filter(x => x >= 0 && (x === edges[j].src || x === edges[j].dst));
      const nearShared = p => sh.some(k => rectDist(p, nodes[k].r) < 15);
      for (let a = 0; a + 1 < edges[i].pts.length; a++) for (let b = 0; b + 1 < edges[j].pts.length; b++) {
        const A = edges[i].pts[a], B = edges[i].pts[a + 1], C = edges[j].pts[b], D = edges[j].pts[b + 1];
        if (properCross(A, B, C, D)) cross = true;
        const hor = Math.abs(A[1] - B[1]) < 1 && Math.abs(C[1] - D[1]) < 1 && Math.abs(A[1] - C[1]) < 3;
        const ver = Math.abs(A[0] - B[0]) < 1 && Math.abs(C[0] - D[0]) < 1 && Math.abs(A[0] - C[0]) < 3;
        if (hor || ver) { const k = hor ? 0 : 1; const lo = Math.max(Math.min(A[k], B[k]), Math.min(C[k], D[k])), hi = Math.min(Math.max(A[k], B[k]), Math.max(C[k], D[k])); if (hi - lo > 8) { const mid = hor ? [(lo + hi) / 2, A[1]] : [A[0], (lo + hi) / 2]; if (!nearShared(mid)) shared = true; } }
      }
      if (cross) { res.crossings++; f(nm(i) + " crosses " + nm(j)); }
      if (shared) { res.sharedTrack++; f(nm(i) + " shares a track with " + nm(j)); }
    }
    const titles = frames.map(fr => fr.title && fr.title.getBoundingClientRect()).filter(r => r && r.width > 1);
    labels.forEach((l, i) => {
      nodes.forEach(n => { if (overlap(l.r, n.r)) { res.labelOverlap++; f("a wire number touches box " + n.id); } });
      labels.forEach((o, j) => { if (j > i && overlap(l.r, o.r)) { res.labelOverlap++; f("two wire numbers touch"); } });
      titles.forEach(t => { if (overlap(l.r, t)) { res.labelOverlap++; f("a wire number touches a group title"); } });
      if (m.hand) frames.forEach(fr => { const r = fr.r; const onEdge = [r.top, r.bottom].some(y => y > l.r.top && y < l.r.bottom) && l.r.right > r.left && l.r.left < r.right || [r.left, r.right].some(x => x > l.r.left && x < l.r.right) && l.r.bottom > r.top && l.r.top < r.bottom; if (onEdge) { res.labelOverlap++; f("a wire number sits on a group border"); } });
    });
    for (let i = 0; i < frames.length; i++) for (let j = i + 1; j < frames.length; j++) { const a = frames[i].r, b = frames[j].r; if (overlap(a, b) && !contains(a, b) && !contains(b, a)) { res.groupOverlap++; f("two groups overlap"); } }
    const vb = svg.viewBox && svg.viewBox.baseVal; res.width = Math.round(vb && vb.width ? vb.width : svg.getBoundingClientRect().width);
    if (res.width > target) f("natural width " + res.width + " px is over " + target + " px");
    const bg = pageBg();
    const col = el => rgb(getComputedStyle(el).color) && !m.hand ? rgb(getComputedStyle(el).color) : rgb(getComputedStyle(el).fill) || rgb(getComputedStyle(el).color);
    nodes.forEach(n => {
      if (!n.text) return;
      res.minFont = Math.min(res.minFont, parseFloat(getComputedStyle(n.text).fontSize));
      const fg = col(n.text), fill = n.shape && rgb(getComputedStyle(n.shape).fill);
      if (fg && fill) { const c = contrast(fg, fill); res.minContrast = Math.min(res.minContrast, c); if (c < 4.5) f("box " + n.id + " text contrast " + c.toFixed(1)); }
    });
    frames.forEach(fr => { const t = fr.titleText; if (!t) return; const fg = col(t); if (!fg) return; res.minFont = Math.min(res.minFont, parseFloat(getComputedStyle(t).fontSize)); const c = contrast(fg, bg); res.minContrast = Math.min(res.minContrast, c); if (c < 4.5) f("a group title has contrast " + c.toFixed(1)); });
    labels.forEach(l => { if (!l.text || !l.bg) return; const fg = col(l.text); const b = m.hand ? rgb(getComputedStyle(l.bg).fill) : (transparent(getComputedStyle(l.bg).backgroundColor) ? null : rgb(getComputedStyle(l.bg).backgroundColor)); if (fg && b) { const c = contrast(fg, b); res.minContrast = Math.min(res.minContrast, c); if (c < 4.5) f("a wire number has contrast " + c.toFixed(1)); } });
    if (res.minFont < 14) f("font " + res.minFont + " px is under 14 px");
    if (res.boxes > MAX_BOXES) f(res.boxes + " boxes: more than " + MAX_BOXES);
    if (res.wires > MAX_WIRES) f(res.wires + " wires: more than " + MAX_WIRES);
    if (res.maxDegree > MAX_DEGREE) f("a box has " + res.maxDegree + " wires: more than " + MAX_DEGREE);
    res.minContrast = Math.round(res.minContrast * 10) / 10;
    res.pass = res.faults.length === 0;
    return res;
  }

  function table(r) {
    const head = r.kind === "sequence" ? `sequence diagram · width ${r.width}` :
      `boxes ${r.boxes} · wires ${r.wires} · max wires on a box ${r.maxDegree} · curved ${r.curved} · diagonal ${r.diagonal} · crossings ${r.crossings} · through a box ${r.throughBox} · grazing ${r.grazing} · bad ends ${r.badEnds} · shared track ${r.sharedTrack} · label overlap ${r.labelOverlap} · group overlap ${r.groupOverlap} · width ${r.width} · min font ${r.minFont} · min contrast ${r.minContrast}`;
    const box = document.createElement("div"); box.className = "figure-check";
    box.innerHTML = `<b>${r.figure}: ${r.pass ? "PASS" : "FAIL"}</b> · ${head}` + (r.faults.length ? "<ul>" + r.faults.map(x => "<li>" + x + "</li>").join("") + "</ul>" : "");
    return box;
  }

  window.figureChecks = function (target) {
    target = target || 1000;
    document.querySelectorAll(".figure-check").forEach(e => e.remove());
    const out = [];
    document.querySelectorAll("[data-figure]").forEach((holder, i) => {
      const svg = holder.querySelector("svg"); if (!svg) return;
      const name = holder.dataset.name || ("Figure " + (i + 1)), src = holder.dataset.source || "";
      let r;
      if (holder.dataset.figure === "svg") r = analyse(svg, handModel(svg), target, name);
      else if (/^\s*(%%.*\n\s*)*sequenceDiagram/.test(src)) {
        const vb = svg.viewBox && svg.viewBox.baseVal, w = Math.round(vb && vb.width ? vb.width : svg.getBoundingClientRect().width);
        r = { figure: name, kind: "sequence", width: w, faults: w > target ? ["natural width " + w + " px is over " + target + " px"] : [] }; r.pass = r.faults.length === 0;
      } else r = analyse(svg, mermaidModel(svg, src), target, name);
      out.push(r); holder.after(table(r));
    });
    window.FIGURE_CHECKS = out;
    return out;
  };
})();
