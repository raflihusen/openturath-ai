// Sanad layouts shared by the build and the browser. Input is the app's chains.
const esc = (s) => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/"/g, '&quot;');
export const bare = (s) => String(s || '').replace(/[ً-ْٰ]/g, '');

export function trie(chains) {
  const root = { kids: new Map(), chains: [], depth: -1 };
  chains.forEach((chain, c) => {
    let at = root;
    chain.links.forEach((link, i) => {
      if (!at.kids.has(link.id)) {
        at.kids.set(link.id, { id: link.id, name: link.name, phrase: i ? chain.links[i - 1].phrase : '', kids: new Map(), chains: [], depth: i });
      }
      at = at.kids.get(link.id);
      at.chains.push(c);
    });
  });
  return root;
}

function place(node, order) {
  const kids = [...node.kids.values()];
  if (!kids.length) { node.row = order.next++; return; }
  kids.forEach((kid) => place(kid, order));
  node.row = (kids[0].row + kids[kids.length - 1].row) / 2;
}

function flat(node, out = []) {
  for (const kid of node.kids.values()) { out.push([node, kid]); flat(kid, out); }
  return out;
}

/** Companion on the right, compilers on the left, read as Arabic is read. */
export function treeSvg(chains) {
  const root = trie(chains), order = { next: 0 };
  place(root, order);
  const pairs = flat(root), deepest = Math.max(...pairs.map(([, n]) => n.depth));
  const colW = 176, rowH = 38, nodeW = 140, nodeH = 28;
  const width = (deepest + 1) * colW, height = order.next * rowH + 12;
  const x = (n) => width - colW / 2 - n.depth * colW, y = (n) => n.row * rowH + 25;
  let lines = '', nodes = '';
  for (const [from, to] of pairs) {
    if (from.depth >= 0) {
      const x1 = x(from) - nodeW / 2, x2 = x(to) + nodeW / 2, mid = (x1 + x2) / 2;
      lines += `<g class="e" data-c="${to.chains}"><path d="M${x1} ${y(from)}C${mid} ${y(from)} ${mid} ${y(to)} ${x2} ${y(to)}"/></g>`;
    }
    nodes += `<g class="n" tabindex="0" role="button" data-id="${esc(to.id)}" data-c="${to.chains}" transform="translate(${x(to)} ${y(to)})"><rect x="${-nodeW / 2}" y="${-nodeH / 2}" width="${nodeW}" height="${nodeH}" rx="14"/><text>${esc(to.name.length > 22 ? to.name.slice(0, 21) + '…' : to.name)}</text><title>${esc(to.name)}</title></g>`;
  }
  return `<svg viewBox="0 0 ${width} ${height}" width="${width}" height="${height}" aria-hidden="true">${lines}${nodes}</svg>`;
}

/** Every chain merged: one node per narrator, ordered by the longest path to it. */
export function graphSvg(chains) {
  const level = new Map(), names = new Map(), sets = new Map(), edges = new Map();
  for (let pass = 0; pass < 6; pass++) {
    chains.forEach((chain) => chain.links.forEach((link, i) => {
      const prev = i ? level.get(chain.links[i - 1].id) ?? 0 : -1;
      level.set(link.id, Math.max(level.get(link.id) ?? 0, prev + 1));
    }));
  }
  chains.forEach((chain, c) => chain.links.forEach((link, i) => {
    names.set(link.id, link.name);
    sets.set(link.id, [...(sets.get(link.id) || []), c]);
    if (i) {
      const key = `${chain.links[i - 1].id}>${link.id}`;
      edges.set(key, [...(edges.get(key) || []), c]);
    }
  }));
  const layers = [];
  for (const [id, l] of level) (layers[l] ||= []).push(id);
  const pos = new Map();
  const parents = new Map();
  for (const key of edges.keys()) {
    const [a, b] = key.split('>');
    parents.set(b, [...(parents.get(b) || []), a]);
  }
  // Each narrator sits near those it heard from, which removes most crossings.
  const rank = new Map();
  layers.forEach((layer, l) => {
    if (l) {
      const score = (id) => {
        const up = (parents.get(id) || []).map((a) => rank.get(a) ?? 0);
        return up.length ? up.reduce((x, y) => x + y, 0) / up.length : 0;
      };
      layer.sort((a, b) => score(a) - score(b));
    }
    layer.forEach((id, i) => rank.set(id, (i + 0.5) / layer.length));
  });
  const colW = 176, rowH = 46, nodeW = 140, tall = Math.max(...layers.map((l) => l.length));
  const width = layers.length * colW, height = tall * rowH + 16;
  layers.forEach((layer, l) => layer.forEach((id, i) => pos.set(id, [
    width - colW / 2 - l * colW, (height - layer.length * rowH) / 2 + i * rowH + rowH / 2,
  ])));
  let lines = '', nodes = '';
  for (const [key, set] of edges) {
    const [a, b] = key.split('>'), [ax, ay] = pos.get(a), [bx, by] = pos.get(b);
    const x1 = ax - nodeW / 2, x2 = bx + nodeW / 2, mid = (x1 + x2) / 2;
    lines += `<g class="e" data-c="${set}"><path d="M${x1} ${ay}C${mid} ${ay} ${mid} ${by} ${x2} ${by}"/></g>`;
  }
  for (const [id, [nx, ny]] of pos) {
    const name = names.get(id);
    nodes += `<g class="n" tabindex="0" role="button" data-id="${esc(id)}" data-c="${sets.get(id)}" transform="translate(${nx} ${ny})"><rect x="${-nodeW / 2}" y="-14" width="${nodeW}" height="28" rx="14"/><text>${esc(name.length > 22 ? name.slice(0, 21) + '…' : name)}</text><title>${esc(name)}</title></g>`;
  }
  return `<svg viewBox="0 0 ${width} ${height}" width="${width}" height="${height}" aria-hidden="true">${lines}${nodes}</svg>`;
}
