// Figure checks for rendered Mermaid flowcharts (operating-model/procedures/figures.md, sections 2 and 3).
// Run in a page after Mermaid rendered. figureChecks() returns one result per figure and draws a table
// under each figure. Pure DOM geometry: no network, no model.
(function () {
  const CLEARANCE = 12;     // L6: pixels between a wire and a box it does not connect
  const TITLE_CLEAR = 6;    // L6: pixels between a wire and a group title
  const SIDE_TOL = 8;       // L7: how far an arrow end may sit from the box side
  const MAX_BOXES = 9, MAX_WIRES = 10, MAX_DEGREE = 4;

  function rgb(c) { const m = (c || "").match(/[\d.]+/g); return m && m.length >= 3 ? m.slice(0, 3).map(Number) : null; }
  function lum(c) { return 0.2126 * ch(c[0]) + 0.7152 * ch(c[1]) + 0.0722 * ch(c[2]); }
  function ch(v) { v /= 255; return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4); }
  function contrast(a, b) { const x = lum(a), y = lum(b); return (Math.max(x, y) + 0.05) / (Math.min(x, y) + 0.05); }
  function pageBg() { let e = document.body; while (e) { const c = rgb(getComputedStyle(e).backgroundColor); const a = getComputedStyle(e).backgroundColor; if (c && !/rgba\(.*,\s*0\)/.test(a)) return c; e = e.parentElement; } return [255, 255, 255]; }

  function points(svg, path) {
    const d = path.getAttribute("d") || "";
    const nums = (d.match(/-?\d+\.?\d*(e-?\d+)?/gi) || []).map(Number);
    const m = path.getScreenCTM();
    const out = [];
    for (let i = 0; i + 1 < nums.length; i += 2) {
      const p = svg.createSVGPoint(); p.x = nums[i]; p.y = nums[i + 1];
      const q = p.matrixTransform(m); out.push([q.x, q.y]);
    }
    // drop repeated points
    return out.filter((p, i) => i === 0 || Math.hypot(p[0] - out[i - 1][0], p[1] - out[i - 1][1]) > 0.5);
  }
  function segDistRect(a, b, r) {
    // smallest distance between segment ab and rectangle r (0 if they touch)
    if (segHitsRect(a, b, r)) return 0;
    const corners = [[r.left, r.top], [r.right, r.top], [r.right, r.bottom], [r.left, r.bottom]];
    let best = Infinity;
    for (let i = 0; i < 4; i++) best = Math.min(best, segSeg(a, b, corners[i], corners[(i + 1) % 4]));
    return best;
  }
  function inside(p, r, inset) { return p[0] > r.left + inset && p[0] < r.right - inset && p[1] > r.top + inset && p[1] < r.bottom - inset; }
  function segHitsRect(a, b, r) {
    const L = Math.hypot(b[0] - a[0], b[1] - a[1]) || 1;
    for (let t = 0; t <= L; t += 2) { const p = [a[0] + (b[0] - a[0]) * t / L, a[1] + (b[1] - a[1]) * t / L]; if (inside(p, r, 0)) return true; }
    return false;
  }
  function ptSeg(p, a, b) {
    const dx = b[0] - a[0], dy = b[1] - a[1], L2 = dx * dx + dy * dy || 1;
    let t = ((p[0] - a[0]) * dx + (p[1] - a[1]) * dy) / L2; t = Math.max(0, Math.min(1, t));
    return Math.hypot(p[0] - (a[0] + t * dx), p[1] - (a[1] + t * dy));
  }
  function orient(p, q, r) { return (q[0] - p[0]) * (r[1] - p[1]) - (q[1] - p[1]) * (r[0] - p[0]); }
  function properCross(a, b, c, d) {
    const d1 = orient(c, d, a), d2 = orient(c, d, b), d3 = orient(a, b, c), d4 = orient(a, b, d);
    return ((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) && ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0));
  }
  function segSeg(a, b, c, d) {
    if (properCross(a, b, c, d)) return 0;
    return Math.min(ptSeg(a, c, d), ptSeg(b, c, d), ptSeg(c, a, b), ptSeg(d, a, b));
  }
  function rectDist(p, r) { const dx = Math.max(r.left - p[0], 0, p[0] - r.right), dy = Math.max(r.top - p[1], 0, p[1] - r.bottom); return Math.hypot(dx, dy); }
  function nearestNode(p, nodes) { let best = null, bd = Infinity; nodes.forEach((n, i) => { const d = rectDist(p, n.r); if (d < bd) { bd = d; best = i; } }); return best; }
  function endOk(end, prev, r) {
    // the end sits on a side, in its middle third, and the last leg is at a right angle to that side
    const sides = [
      { d: Math.abs(end[1] - r.top), along: (end[0] - r.left) / r.width, vertical: true },
      { d: Math.abs(end[1] - r.bottom), along: (end[0] - r.left) / r.width, vertical: true },
      { d: Math.abs(end[0] - r.left), along: (end[1] - r.top) / r.height, vertical: false },
      { d: Math.abs(end[0] - r.right), along: (end[1] - r.top) / r.height, vertical: false },
    ].sort((x, y) => x.d - y.d);
    const s = sides[0];
    if (s.d > SIDE_TOL) return false;
    if (s.along < 1 / 3 - 0.02 || s.along > 2 / 3 + 0.02) return false;
    const dx = Math.abs(end[0] - prev[0]), dy = Math.abs(end[1] - prev[1]);
    return s.vertical ? dx <= 2 : dy <= 2;
  }
  function overlap(a, b) { return a.left < b.right && b.left < a.right && a.top < b.bottom && b.top < a.bottom; }
  function contains(a, b) { return a.left <= b.left && a.right >= b.right && a.top <= b.top && a.bottom >= b.bottom; }

  function checkOne(svg, target) {
    // Both Mermaid renderers: the default (dagre) and ELK name their parts differently. ELK draws a group
    // frame as a node too, so the groups that the source declares are not boxes.
    const groupIds = new Set(((svg.closest("[data-source]")?.dataset.source || "").match(/subgraph\s+([\w-]+)/g) || []).map(s => s.split(/\s+/)[1]));
    const nodes = [...svg.querySelectorAll("g.node")]
      .filter(g => !groupIds.has((g.id || "").replace(/^flowchart-/, "").replace(/-\d+$/, "")))
      .filter(g => !g.closest("g.subgraph") || g.querySelector("rect, path, polygon, circle, ellipse"))
      .filter(g => !g.classList.contains("cluster") && !g.classList.contains("subgraph"))
      .map(g => ({ id: (g.id || "").replace(/^flowchart-/, "").replace(/-\d+$/, ""), r: g.getBoundingClientRect(), g }))
      .filter(n => n.r.width > 1);
    const paths = [...new Set([...svg.querySelectorAll(".edgePaths path, path.flowchart-link")])].filter(p => !p.closest("marker"));
    const edges = paths.map(p => ({ p, pts: points(svg, p), curved: /[CQSA]/i.test(p.getAttribute("d") || "") })).filter(e => e.pts.length >= 2);
    const byId = id => nodes.findIndex(n => n.id === id);
    edges.forEach(e => {
      const cls = e.p.getAttribute("class") || "";
      const ls = (cls.match(/LS-(\S+)/) || [])[1], le = (cls.match(/LE-(\S+)/) || [])[1];
      e.src = ls && byId(ls) >= 0 ? byId(ls) : nearestNode(e.pts[0], nodes);
      e.dst = le && byId(le) >= 0 ? byId(le) : nearestNode(e.pts[e.pts.length - 1], nodes);
    });
    const res = { boxes: nodes.length, wires: edges.length, curved: 0, diagonal: 0, crossings: 0, throughBox: 0, grazing: 0, badEnds: 0, sharedTrack: 0, maxDegree: 0, labelOverlap: 0, groupOverlap: 0, width: 0, minFont: 99, minContrast: 99, faults: [] };
    const name = i => `wire ${i + 1} (${nodes[edges[i].src]?.id}→${nodes[edges[i].dst]?.id})`;
    // degree
    const deg = nodes.map(() => 0); edges.forEach(e => { deg[e.src]++; deg[e.dst]++; }); res.maxDegree = Math.max(0, ...deg);
    edges.forEach((e, i) => {
      if (e.curved) { res.curved++; res.faults.push(name(i) + " is curved"); }
      for (let a = 0; a + 1 < e.pts.length; a++) { const [p, q] = [e.pts[a], e.pts[a + 1]]; if (Math.abs(p[0] - q[0]) > 2 && Math.abs(p[1] - q[1]) > 2) { res.diagonal++; res.faults.push(name(i) + " has a diagonal leg"); break; } }
      // boxes it does not connect
      nodes.forEach((n, k) => {
        if (k === e.src || k === e.dst) return;
        let min = Infinity; for (let a = 0; a + 1 < e.pts.length; a++) min = Math.min(min, segDistRect(e.pts[a], e.pts[a + 1], n.r));
        if (min === 0) { res.throughBox++; res.faults.push(name(i) + " crosses box " + n.id); }
        else if (min < CLEARANCE) { res.grazing++; res.faults.push(name(i) + " passes " + Math.round(min) + " px from box " + n.id); }
      });
      // its own boxes: the wire may not run inside them except at the end
      const end = e.pts[e.pts.length - 1], prev = e.pts[e.pts.length - 2] || e.pts[0];
      const start = e.pts[0], next = e.pts[1] || end;
      if (nodes[e.dst] && !endOk(end, prev, nodes[e.dst].r)) { res.badEnds++; res.faults.push(name(i) + " does not enter the middle of a side of " + nodes[e.dst].id); }
      if (nodes[e.src] && !endOk(start, next, nodes[e.src].r)) { res.badEnds++; res.faults.push(name(i) + " does not leave the middle of a side of " + nodes[e.src].id); }
    });
    for (let i = 0; i < edges.length; i++) for (let j = i + 1; j < edges.length; j++) {
      let cross = false, shared = false;
      const sharedNodes = [edges[i].src, edges[i].dst].filter(x => x === edges[j].src || x === edges[j].dst);
      const nearShared = p => sharedNodes.some(k => rectDist(p, nodes[k].r) < 15);
      for (let a = 0; a + 1 < edges[i].pts.length; a++) for (let b = 0; b + 1 < edges[j].pts.length; b++) {
        const A = edges[i].pts[a], B = edges[i].pts[a + 1], C = edges[j].pts[b], D = edges[j].pts[b + 1];
        if (properCross(A, B, C, D)) cross = true;
        const hor = Math.abs(A[1] - B[1]) < 1 && Math.abs(C[1] - D[1]) < 1 && Math.abs(A[1] - C[1]) < 3;
        const ver = Math.abs(A[0] - B[0]) < 1 && Math.abs(C[0] - D[0]) < 1 && Math.abs(A[0] - C[0]) < 3;
        if (hor || ver) {
          const k = hor ? 0 : 1;
          const lo = Math.max(Math.min(A[k], B[k]), Math.min(C[k], D[k])), hi = Math.min(Math.max(A[k], B[k]), Math.max(C[k], D[k]));
          if (hi - lo > 8) { const mid = hor ? [(lo + hi) / 2, A[1]] : [A[0], (lo + hi) / 2]; if (!nearShared(mid)) shared = true; }
        }
      }
      if (cross) { res.crossings++; res.faults.push(name(i) + " crosses " + name(j)); }
      if (shared) { res.sharedTrack++; res.faults.push(name(i) + " shares a track with " + name(j)); }
    }
    // labels
    const labels = [...svg.querySelectorAll("g.edgeLabel")].map(g => g.getBoundingClientRect()).filter(r => r.width > 1 && r.height > 1);
    const titles = [...svg.querySelectorAll("g.cluster .cluster-label, g.cluster-label, g.subgraph > g.label")].map(g => g.getBoundingClientRect()).filter(r => r.width > 1);
    labels.forEach((l, i) => {
      nodes.forEach(n => { if (overlap(l, n.r)) { res.labelOverlap++; res.faults.push("a wire number touches box " + n.id); } });
      labels.forEach((m, j) => { if (j > i && overlap(l, m)) { res.labelOverlap++; res.faults.push("two wire numbers touch"); } });
      titles.forEach(t => { if (overlap(l, t)) { res.labelOverlap++; res.faults.push("a wire number touches a group title"); } });
    });
    edges.forEach((e, i) => titles.forEach(t => { let min = Infinity; for (let a = 0; a + 1 < e.pts.length; a++) min = Math.min(min, segDistRect(e.pts[a], e.pts[a + 1], t)); if (min < TITLE_CLEAR) { res.grazing++; res.faults.push(name(i) + " touches a group title"); } }));
    // groups
    const groups = [...svg.querySelectorAll("g.cluster > rect, g.subgraph > rect")].map(r => r.getBoundingClientRect());
    const declared = (svg.closest("[data-source]")?.dataset.source || "").match(/-->|-\.->|==>/g);
    if (edges.length === 0 || (declared && declared.length !== edges.length)) {
      res.faults.push(`the tool read ${edges.length} wires, the source declares ${declared ? declared.length : "?"}: the render is not read correctly`);
    }
    for (let i = 0; i < groups.length; i++) for (let j = i + 1; j < groups.length; j++) {
      const a = groups[i], b = groups[j];
      if (overlap(a, b) && !contains(a, b) && !contains(b, a)) { res.groupOverlap++; res.faults.push("two groups overlap"); }
    }
    // size, font, contrast
    const vb = svg.viewBox && svg.viewBox.baseVal; res.width = Math.round(vb && vb.width ? vb.width : svg.getBoundingClientRect().width);
    if (res.width > target) res.faults.push("natural width " + res.width + " px is over " + target + " px");
    const bg = pageBg();
    nodes.forEach(n => {
      const shape = n.g.querySelector("rect, path, polygon, circle, ellipse");
      const text = n.g.querySelector(".nodeLabel, text");
      if (!text) return;
      res.minFont = Math.min(res.minFont, parseFloat(getComputedStyle(text).fontSize));
      const fg = rgb(getComputedStyle(text).color) || rgb(getComputedStyle(text).fill);
      const fill = shape && rgb(getComputedStyle(shape).fill);
      if (fg && fill) { const c = contrast(fg, fill); res.minContrast = Math.min(res.minContrast, c); if (c < 4.5) res.faults.push("box " + n.id + " text contrast " + c.toFixed(1)); }
    });
    svg.querySelectorAll("g.cluster, g.subgraph").forEach(g => {
      const t = g.querySelector(".nodeLabel, .cluster-label span, text"); if (!t) return;
      const fg = rgb(getComputedStyle(t).color) || rgb(getComputedStyle(t).fill); if (!fg) return;
      const c = contrast(fg, bg); res.minContrast = Math.min(res.minContrast, c); if (c < 4.5) res.faults.push("a group title has contrast " + c.toFixed(1));
    });
    svg.querySelectorAll("g.edgeLabel").forEach(g => {
      const t = g.querySelector("span, text"); if (!t) return; const fg = rgb(getComputedStyle(t).color) || rgb(getComputedStyle(t).fill);
      const box = g.querySelector("span, rect"); const b = box && rgb(getComputedStyle(box).backgroundColor || getComputedStyle(box).fill);
      if (fg && b && !/rgba\(.*,\s*0\)/.test(getComputedStyle(box).backgroundColor || "")) { const c = contrast(fg, b); res.minContrast = Math.min(res.minContrast, c); if (c < 4.5) res.faults.push("a wire number has contrast " + c.toFixed(1)); }
    });
    if (res.minFont < 14) res.faults.push("font " + res.minFont + " px is under 14 px");
    if (res.boxes > MAX_BOXES) res.faults.push(res.boxes + " boxes: more than " + MAX_BOXES);
    if (res.wires > MAX_WIRES) res.faults.push(res.wires + " wires: more than " + MAX_WIRES);
    if (res.maxDegree > MAX_DEGREE) res.faults.push("a box has " + res.maxDegree + " wires: more than " + MAX_DEGREE);
    res.minContrast = Math.round(res.minContrast * 10) / 10;
    res.pass = res.faults.length === 0;
    return res;
  }

  window.figureChecks = function (target) {
    target = target || 1000;
    const out = [];
    document.querySelectorAll("pre.mermaid, div.mermaid").forEach((pre, i) => {
      const svg = pre.querySelector("svg"); if (!svg) return;
      const r = checkOne(svg, target); r.figure = pre.closest("[data-name]")?.dataset.name || ("Figure " + (i + 1)); out.push(r);
      const box = document.createElement("div"); box.className = "figure-check";
      box.innerHTML = `<b>${r.figure}: ${r.pass ? "PASS" : "FAIL"}</b> · boxes ${r.boxes} · wires ${r.wires} · max wires on a box ${r.maxDegree} · curved ${r.curved} · diagonal ${r.diagonal} · crossings ${r.crossings} · through a box ${r.throughBox} · grazing ${r.grazing} · bad ends ${r.badEnds} · shared track ${r.sharedTrack} · label overlap ${r.labelOverlap} · group overlap ${r.groupOverlap} · width ${r.width} · min font ${r.minFont} · min contrast ${r.minContrast}` + (r.faults.length ? "<ul>" + r.faults.map(f => "<li>" + f + "</li>").join("") + "</ul>" : "");
      pre.after(box);
    });
    window.FIGURE_CHECKS = out;
    return out;
  };
})();
