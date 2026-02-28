#!/usr/bin/env node
const { spawnSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// svgpath is used to reverse path directions when necessary.  It's an
// optional dependency (added to package.json) so we wrap the require in a
// try/catch to avoid hard failure in environments where npm install hasn't
// been run yet.
let svgpath;
try { svgpath = require('svgpath'); } catch (_) { svgpath = null; }

// crude orientation calculation: treat the d string as a polygon by
// extracting its numeric pairs (ignoring command letters and curves) and
// computing the signed area.  positive => clockwise-ish, negative =>
// counterclockwise.  This is sufficient to detect reversed direction.
function orientationOfPath(d) {
  // Use svgpath to get actual path vertices (exclude control points)
  if (svgpath) {
    try {
      let sp = svgpath(d).abs();
      if (typeof sp.unshort === 'function') sp = sp.unshort();
      if (typeof sp.unarc === 'function') sp = sp.unarc();
      const segs = sp.segments || [];
      const pts = [];
      let curr = { x: 0, y: 0 };
      for (const seg of segs) {
        const cmd = seg[0];
        if (cmd === 'M') {
          curr = { x: seg[1], y: seg[2] };
          pts.push(curr);
        } else if (cmd === 'L') {
          curr = { x: seg[1], y: seg[2] };
          pts.push(curr);
        } else if (cmd === 'H') {
          curr = { x: seg[1], y: curr.y };
          pts.push(curr);
        } else if (cmd === 'V') {
          curr = { x: curr.x, y: seg[1] };
          pts.push(curr);
        } else if (cmd === 'Q') {
          // Only use endpoint, not control point
          curr = { x: seg[3], y: seg[4] };
          pts.push(curr);
        } else if (cmd === 'C') {
          // Only use endpoint, not control points
          curr = { x: seg[5], y: seg[6] };
          pts.push(curr);
        } else if (cmd === 'Z' || cmd === 'z') {
          // Close path, don't add duplicate point
        }
      }
      if (pts.length < 3) return 0;
      let area = 0;
      for (let i = 0; i < pts.length; i++) {
        const p1 = pts[i];
        const p2 = pts[(i + 1) % pts.length];
        area += p1.x * p2.y - p2.x * p1.y;
      }
      return area / 2;
    } catch (_) {
      // Fall through to simple method
    }
  }
  // Fallback: simple numeric extraction (works for L commands only)
  const nums = (d.match(/-?[\d\.]+/g) || []).map(Number);
  if (nums.length < 6) return 0;
  let area = 0;
  for (let i = 0; i < nums.length; i += 2) {
    const x1 = nums[i];
    const y1 = nums[i + 1];
    const x2 = nums[(i + 2) % nums.length];
    const y2 = nums[(i + 3) % nums.length];
    area += x1 * y2 - x2 * y1;
  }
  return area / 2;
}

function reversePathD(d) {
  if (!svgpath) return d;
  try {
    let sp = svgpath(d).abs();
    if (typeof sp.unshort === 'function') sp = sp.unshort();
    if (typeof sp.unarc === 'function') sp = sp.unarc();
    const segs = sp.segments || [];

    const subpaths = [];
    let edges = [];
    let start = null;
    let curr = { x: 0, y: 0 };
    let closed = false;

    const flush = () => {
      if (start) subpaths.push({ edges, closed });
      edges = [];
      start = null;
      closed = false;
    };

    const addLine = (to) => {
      edges.push({ type: 'L', from: { ...curr }, to: { ...to } });
      curr = { ...to };
    };

    for (const seg of segs) {
      const cmd = seg[0];
      if (cmd === 'M') {
        if (start) flush();
        curr = { x: seg[1], y: seg[2] };
        start = { ...curr };
      } else if (cmd === 'L') {
        addLine({ x: seg[1], y: seg[2] });
      } else if (cmd === 'H') {
        addLine({ x: seg[1], y: curr.y });
      } else if (cmd === 'V') {
        addLine({ x: curr.x, y: seg[1] });
      } else if (cmd === 'Q') {
        const edge = {
          type: 'Q',
          from: { ...curr },
          c: { x: seg[1], y: seg[2] },
          to: { x: seg[3], y: seg[4] },
        };
        edges.push(edge);
        curr = { ...edge.to };
      } else if (cmd === 'C') {
        const edge = {
          type: 'C',
          from: { ...curr },
          c1: { x: seg[1], y: seg[2] },
          c2: { x: seg[3], y: seg[4] },
          to: { x: seg[5], y: seg[6] },
        };
        edges.push(edge);
        curr = { ...edge.to };
      } else if (cmd === 'Z' || cmd === 'z') {
        if (start && (curr.x !== start.x || curr.y !== start.y)) {
          addLine(start);
        }
        closed = true;
        flush();
      } else {
        return d;
      }
    }
    if (start) flush();

    const parts = [];
    for (const s of subpaths) {
      if (!s.edges.length) continue;
      const first = s.edges[s.edges.length - 1].to;
      let out = `M${first.x} ${first.y}`;
      for (let i = s.edges.length - 1; i >= 0; i--) {
        const e = s.edges[i];
        if (e.type === 'L') {
          out += `L${e.from.x} ${e.from.y}`;
        } else if (e.type === 'Q') {
          out += `Q${e.c.x} ${e.c.y} ${e.from.x} ${e.from.y}`;
        } else if (e.type === 'C') {
          out += `C${e.c2.x} ${e.c2.y} ${e.c1.x} ${e.c1.y} ${e.from.x} ${e.from.y}`;
        }
      }
      if (s.closed) out += 'Z';
      parts.push(out);
    }
    return parts.length ? parts.join(' ') : d;
  } catch (_) {
    return d;
  }
}

function pathBBox(d) {
  // Use svgpath to properly extract only endpoint coordinates (not arc radii/flags)
  if (svgpath) {
    try {
      let sp = svgpath(d).abs();
      if (typeof sp.unshort === 'function') sp = sp.unshort();
      if (typeof sp.unarc === 'function') sp = sp.unarc();
      const segs = sp.segments || [];
      const pts = [];
      let curr = { x: 0, y: 0 };
      for (const seg of segs) {
        const cmd = seg[0];
        if (cmd === 'M') {
          curr = { x: seg[1], y: seg[2] };
          pts.push(curr);
        } else if (cmd === 'L') {
          curr = { x: seg[1], y: seg[2] };
          pts.push(curr);
        } else if (cmd === 'H') {
          curr = { x: seg[1], y: curr.y };
          pts.push(curr);
        } else if (cmd === 'V') {
          curr = { x: curr.x, y: seg[1] };
          pts.push(curr);
        } else if (cmd === 'Q') {
          curr = { x: seg[3], y: seg[4] };
          pts.push(curr);
        } else if (cmd === 'C') {
          curr = { x: seg[5], y: seg[6] };
          pts.push(curr);
        }
      }
      if (pts.length === 0) return null;
      let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
      for (const pt of pts) {
        if (pt.x < minX) minX = pt.x;
        if (pt.y < minY) minY = pt.y;
        if (pt.x > maxX) maxX = pt.x;
        if (pt.y > maxY) maxY = pt.y;
      }
      return { minX, minY, maxX, maxY, area: Math.max(0, maxX - minX) * Math.max(0, maxY - minY) };
    } catch (_) {
      // Fall through
    }
  }
  // Fallback: simple numeric extraction (only works correctly for L commands)
  const nums = (d.match(/-?[\d\.]+/g) || []).map(Number);
  if (nums.length < 2) return null;
  let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
  for (let i = 0; i + 1 < nums.length; i += 2) {
    const x = nums[i];
    const y = nums[i + 1];
    if (x < minX) minX = x;
    if (y < minY) minY = y;
    if (x > maxX) maxX = x;
    if (y > maxY) maxY = y;
  }
  return { minX, minY, maxX, maxY, area: Math.max(0, maxX - minX) * Math.max(0, maxY - minY) };
}

function normalizeEvenOddToNonZero(d) {
  const absD = svgpath ? svgpath(d).abs().toString() : d;
  const parts = absD.split(/(?=M)/).filter(Boolean);
  if (parts.length < 2) return d;

  const meta = parts.map((part, i) => ({
    i,
    d: part,
    sign: Math.sign(orientationOfPath(part)),
    box: pathBBox(part),
    depth: 0,
  }));

  for (let i = 0; i < meta.length; i++) {
    const a = meta[i];
    if (!a.box) continue;
    for (let j = 0; j < meta.length; j++) {
      if (i === j) continue;
      const b = meta[j];
      if (!b.box) continue;
      if (
        a.box.minX > b.box.minX &&
        a.box.maxX < b.box.maxX &&
        a.box.minY > b.box.minY &&
        a.box.maxY < b.box.maxY
      ) {
        a.depth++;
      }
    }
  }

  const outer = meta
    .filter(m => m.sign !== 0)
    .sort((x, y) => (y.box ? y.box.area : 0) - (x.box ? x.box.area : 0))[0];
  const outerSign = outer ? outer.sign : 1;

  const out = meta.map(m => {
    if (!m.sign) return m.d;
    const desired = m.depth % 2 === 0 ? outerSign : -outerSign;
    if (m.sign !== desired) {
      return reversePathD(m.d);
    }
    return m.d;
  });

  return out.join(' ');
}

function usage() {
  console.log(`Usage: node scripts/generate_icons.js [--icons ICONS_DIR] [--out OUT_DIR] [--font FONT_NAME] [--dart DART_FILE] [--class CLASS_NAME] [--prefix CSS_PREFIX]

Defaults:
  --icons assets/images/icons
  --out assets/fonts
  --font AppIcons
  --dart lib/src/app_icons.dart
  --class AppIcons
  --prefix icon-
`);
}

const argv = require('minimist')(process.argv.slice(2));
const iconsDir = argv.icons || 'assets/images/icons';
const outDir = argv.out || 'assets/fonts';
const fontName = argv.font || 'AppIcons';
const dartFile = argv.dart || 'lib/src/app_icons.dart';
const className = argv.class || 'AppIcons';
// fantasticon default prefix is 'icon'
const cssPrefix = argv.prefix || 'icon-';
const keepSanitized = argv['keep-sanitized'] || process.env.KEEP_SANITIZED;

async function runFantasticon() {
  console.log('Running fantasticon to generate font and CSS...');
  // ensure output directory exists, fantasticon requires it to be present
  if (!fs.existsSync(outDir)) {
    fs.mkdirSync(outDir, { recursive: true });
  }

  // patch glob to always convert backslashes to forward slashes, fixing
  // the "No SVGs found" bug on Windows when fantasticon builds its
  // glob pattern via path.join (which uses backslashes).
  try {
    const glob = require('glob');
    const orig = glob.glob;
    glob.glob = function (pattern, options, cb) {
      if (typeof pattern === 'string') pattern = pattern.replace(/\\/g, '/');
      return orig.call(this, pattern, options, cb);
    };
    if (glob.globSync) {
      const origSync = glob.globSync;
      glob.globSync = function (pattern, options) {
        if (typeof pattern === 'string') pattern = pattern.replace(/\\/g, '/');
        return origSync.call(this, pattern, options);
      };
    }
  } catch (_) {
    // if glob isn't available for some reason, ignore patch
  }

  // Prefer using the JS API if available (avoids spawning npx and is faster)
  try {
    const fantasticon = require('fantasticon');
    // the package exports the function as default or named
    const generateFonts = fantasticon.default || fantasticon;

    // Create a temporary sanitized copy of the SVGs to remove any background
    // rectangles/masks that can produce square glyphs in the generated font.
    const sanitizedDir = path.join(outDir, '_sanitized_icons');
    if (fs.existsSync(sanitizedDir)) {
      fs.rmSync(sanitizedDir, { recursive: true, force: true });
    }
    fs.mkdirSync(sanitizedDir, { recursive: true });

    const svgFiles = fs.readdirSync(iconsDir).filter(f => f.toLowerCase().endsWith('.svg'));
    for (const f of svgFiles) {
      const src = path.join(iconsDir, f);
      const dst = path.join(sanitizedDir, f);
      try {
        const txt = fs.readFileSync(src, 'utf8');
        const clean = sanitizeSvg(txt);
        fs.writeFileSync(dst, clean, 'utf8');
      } catch (e) {
        console.error('Failed to sanitize', src, e && e.message);
        // fallback: copy original
        fs.copyFileSync(src, dst);
      }
    }

    const normalizedInput = sanitizedDir.replace(/\\/g, '/');
    await generateFonts({
      inputDir: normalizedInput,
      outputDir: outDir,
      name: fontName,
      fontTypes: ['ttf'],
      assetTypes: ['css'],
      prefix: cssPrefix.replace(/^-+/, ''),
      // keep default options for everything else
    });

    // cleanup sanitizedDir unless user asked to keep it for debugging
    if (!keepSanitized) {
      try { fs.rmSync(sanitizedDir, { recursive: true, force: true }); } catch (_) { }
    } else {
      console.log('Keeping sanitized SVGs in', sanitizedDir);
    }

    return;
  } catch (e) {
    // if require failed or API call threw, fall back to CLI
    // silently ignore require errors, we'll try CLI below
  }

  // fallback to CLI invocation
  const args = [
    'fantasticon',
    iconsDir,
    '--output', outDir,
    '--name', fontName,
    '--font-types', 'ttf',
    '--asset-types', 'css',
    '--prefix', cssPrefix.replace(/^-+/, '') // fantasticon will add default prefix if empty
  ];

  const cmd = process.platform === 'win32' ? 'npx.cmd' : 'npx';
  // capture output so we can display it in case of failure
  const res = spawnSync(cmd, args, { encoding: 'utf8', shell: true });
  if (res.error || res.status !== 0) {
    console.error(res.stdout || '');
    console.error(res.stderr || '');
    throw new Error('fantasticon failed. Please ensure Node.js and fantasticon (or npx) are available.');
  }
}

function findFileWithExt(dir, ext) {
  if (!fs.existsSync(dir)) return null;
  const files = fs.readdirSync(dir);
  for (const f of files) {
    if (f.toLowerCase().endsWith(ext.toLowerCase())) return path.join(dir, f);
  }
  return null;
}

function parseCssForMapping(cssText, prefix) {
  const map = {};
  // Matches selectors like ".icon-name:before{content:"\\e900"}"
  const re = /\.([a-zA-Z0-9_\-]+):before\s*\{[^}]*content\s*:\s*['"]\\([0-9a-fA-F]+)['"]/g;
  let m;
  while ((m = re.exec(cssText)) !== null) {
    let name = m[1];
    const codeHex = m[2];
    // strip the configured prefix and any extra leading hyphens that
    // fantasticon may have inserted (e.g. class 'icon--apple' with prefix 'icon-').
    if (prefix && name.startsWith(prefix)) name = name.slice(prefix.length);
    // remove any leading hyphens left after prefix removal
    name = name.replace(/^-+/, '');
    map[name] = parseInt(codeHex, 16);
  }
  return map;
}

function toDartIdentifier(name) {
  // Replace invalid chars with underscore
  let id = name.replace(/[^a-zA-Z0-9_]/g, '_');
  // drop any leading underscores that would make the identifier private
  id = id.replace(/^_+/, '');
  // convert to camelCase: split on underscores, hyphens, spaces
  const parts = id.split(/[_\-\s]+/);
  if (parts.length > 1) {
    id = parts[0].toLowerCase() + parts.slice(1).map(p => p.charAt(0).toUpperCase() + p.slice(1).toLowerCase()).join('');
  } else {
    id = id.toLowerCase();
  }
  // if the result is empty or starts with a digit, prefix a word
  if (!id || /^[0-9]/.test(id)) {
    id = 'icon' + id;
  }
  return id;
}

function sanitizeSvg(svgText) {
  // Remove XML comments
  svgText = svgText.replace(/<!--([\s\S]*?)-->/g, '');
  // keep a copy of the original for heuristics later
  const _origSvg = svgText;

  // First, collect masks and extract their <path> elements so we can
  // preserve attributes like fill-rule or clip-rule when we later reinsert them.
  const maskRegex = /<mask\b[^>]*id=["']?([^"'\s>]+)["']?[^>]*>([\s\S]*?)<\/mask>/gi;

  // Multiple-mask handling simplified: previously we attempted to compute a
  // polygon union of all mask shapes (via polygon-clipping) which proved
  // brittle and produced malformed geometry for some icons.  That complexity
  // has been removed.  We now emit one <path> element per original mask
  // shape and rely on the subsequent pair-merge pass to collapse intentional
  // colored+white cutouts into a single even-odd path when appropriate.
  const maskMap = {};
  let m;
  while ((m = maskRegex.exec(svgText)) !== null) {
    const id = m[1];
    const content = m[2];
    // capture shapes inside the mask: <path>, <circle>, <ellipse>, <rect>
    const pathInfo = [];
    // paths
    for (const pm of content.matchAll(/(<path\b[^>]*>\s*<\/path>|<path\b[^>]*\/\>)/gi)) {
      const elem = pm[1];
      const dMatch = elem.match(/\bd=["']([^"']+)["']/i);
      const fillMatch = elem.match(/\bfill=["']([^"']+)["']/i);
      const fillRuleMatch = elem.match(/\bfill-rule=["']([^"']+)["']/i);
      const clipRuleMatch = elem.match(/\bclip-rule=["']([^"']+)["']/i);
      if (dMatch) {
        pathInfo.push({
          d: dMatch[1].trim(),
          fill: fillMatch ? fillMatch[1].trim().toLowerCase() : null,
          fillRule: fillRuleMatch ? fillRuleMatch[1].trim() : null,
          clipRule: clipRuleMatch ? clipRuleMatch[1].trim() : null,
        });
      }
    }
    // circles
    for (const cm of content.matchAll(/<circle\b[^>]*>/gi)) {
      const elem = cm[0];
      const cx = parseFloat((elem.match(/cx=["']?([^"'\s>]+)["']?/) || [])[1] || '0');
      const cy = parseFloat((elem.match(/cy=["']?([^"'\s>]+)["']?/) || [])[1] || '0');
      const r = parseFloat((elem.match(/r=["']?([^"'\s>]+)["']?/) || [])[1] || '0');
      const fillMatch = elem.match(/\bfill=["']([^"']+)["']/i);
      if (!isNaN(cx) && !isNaN(cy) && !isNaN(r) && r > 0) {
        // convert circle to path via two arcs
        const d = `M ${cx + r} ${cy} A ${r} ${r} 0 1 0 ${cx - r} ${cy} A ${r} ${r} 0 1 0 ${cx + r} ${cy} Z`;
        pathInfo.push({ d, fill: fillMatch ? fillMatch[1].trim().toLowerCase() : null });
      }
    }
    // ellipses
    for (const em of content.matchAll(/<ellipse\b[^>]*>/gi)) {
      const elem = em[0];
      const cx = parseFloat((elem.match(/cx=["']?([^"'\s>]+)["']?/) || [])[1] || '0');
      const cy = parseFloat((elem.match(/cy=["']?([^"'\s>]+)["']?/) || [])[1] || '0');
      const rx = parseFloat((elem.match(/rx=["']?([^"'\s>]+)["']?/) || [])[1] || '0');
      const ry = parseFloat((elem.match(/ry=["']?([^"'\s>]+)["']?/) || [])[1] || '0');
      const fillMatch = elem.match(/\bfill=["']([^"']+)["']/i);
      if (!isNaN(cx) && !isNaN(cy) && !isNaN(rx) && !isNaN(ry) && rx > 0 && ry > 0) {
        const d = `M ${cx + rx} ${cy} A ${rx} ${ry} 0 1 0 ${cx - rx} ${cy} A ${rx} ${ry} 0 1 0 ${cx + rx} ${cy} Z`;
        pathInfo.push({ d, fill: fillMatch ? fillMatch[1].trim().toLowerCase() : null });
      }
    }
    // rects inside mask
    for (const rm of content.matchAll(/<rect\b[^>]*>/gi)) {
      const elem = rm[0];
      const width = parseFloat((elem.match(/width=["']?([^"'\s>]+)["']?/) || [])[1] || '0');
      const height = parseFloat((elem.match(/height=["']?([^"'\s>]+)["']?/) || [])[1] || '0');
      const x = parseFloat((elem.match(/x=["']?([^"'\s>]+)["']?/) || [])[1] || '0');
      const y = parseFloat((elem.match(/y=["']?([^"'\s>]+)["']?/) || [])[1] || '0');
      const fillMatch = elem.match(/\bfill=["']([^"']+)["']/i);
      const d = `M${x} ${y}h${width}v${height}h-${width}Z`;
      pathInfo.push({ d, fill: fillMatch ? fillMatch[1].trim().toLowerCase() : null });
    }
    if (pathInfo.length) {
      maskMap[id] = pathInfo;
    }
  }
  // remove masks from source; we'll swap in the stored path content below
  svgText = svgText.replace(maskRegex, '');

  // Replace groups that reference masks with a single path using the mask's d and the group's rect fill.
  // We match the entire <g>...</g> block to avoid issues with nested <g> tags.
  svgText = svgText.replace(/<g\b[^>]*mask=["']?url\(#([^"')]+)\)["']?[^>]*>[\s\S]*?<\/g>/gi, (full, maskRef) => {
    const pathInfo = maskMap[maskRef];
    if (!pathInfo) return full;
    // determine fill from any rect inside the group
    const rectMatch = full.match(/<rect\b[^>]*fill=["']?([^"'\s>]+)["']?[^>]*\/?>(?:<\/rect>)?/i);
    const rectFill = rectMatch ? rectMatch[1] : null;
    // if pathInfo is an array of objects, combine their d values into one even-odd path
    if (Array.isArray(pathInfo) && pathInfo.length > 1) {
      // prefer the group's rect fill (rectFill) as the outer color; fall back to a non-white path fill
      const outerFill = rectFill || (pathInfo.find(p => p.fill && p.fill !== 'white' && p.fill !== '#fff' && p.fill !== '#ffffff') || {}).fill || '#000';
      // If we detect white (or #fff) cutouts alongside colored shapes, emit a
      // single <path> which concatenates all subpaths and use
      // `fill-rule="evenodd"` so those white parts become holes in glyphs.
      const isWhite = v => !v ? false : /^(?:white|#fff(?:fff)?)$/i.test(v.trim());
      const parts = pathInfo.map(p => ({ d: p.d, fill: p.fill }));
      const whites = parts.filter(p => isWhite(p.fill));
      const colored = parts.filter(p => !isWhite(p.fill));
      if (!whites.length && colored.length) {
        // For pure colored multi-part shapes, keep exact curves and normalize
        // winding direction so overlapping parts do not subtract each other
        // when converted to font contours.
        let targetSign = 0;
        const normalized = new Set(); // track which indices were normalized
        return pathInfo.map((p, i) => {
          let d = p.d;
          const hasEvenOdd = /evenodd/i.test(p.fillRule || '') || /evenodd/i.test(p.clipRule || '');
          if (hasEvenOdd && /M[^M]*M/.test(d)) {
            d = normalizeEvenOddToNonZero(d);
            normalized.add(i); // mark as normalized, skip winding alignment
          }
          // Only apply winding alignment if NOT already normalized
          if (!normalized.has(i)) {
            const sign = Math.sign(orientationOfPath(d));
            if (!targetSign && sign) targetSign = sign;
            if (targetSign && sign && sign !== targetSign) {
              const reversed = reversePathD(d);
              const reversedSign = Math.sign(orientationOfPath(reversed));
              if (reversedSign === targetSign) d = reversed;
            }
          }
          if (hasEvenOdd) {
            return `<path d="${d.replace(/"/g, '&quot;')}" fill="${outerFill}" />`;
          }
          const fr = p.fillRule ? ` fill-rule="${p.fillRule}"` : '';
          const cr = p.clipRule ? ` clip-rule="${p.clipRule}"` : '';
          return `<path d="${d.replace(/"/g, '&quot;')}" fill="${outerFill}"${fr}${cr} />`;
        }).join('');
      }
      if (whites.length && colored.length) {
        // order: colored outer parts first, then white cutouts
        const all = [...colored.map(p => p.d), ...whites.map(p => p.d)];
        const dFull = all.join(' ').replace(/"/g, '&quot;');
        return `<path d="${dFull}" fill="${outerFill}" fill-rule="evenodd" />`;
      }
      // otherwise emit each mask shape separately
      return pathInfo.map(p => `<path d="${p.d.replace(/"/g, '&quot;')}" fill="${outerFill}" />`).join('');
    }
    // single path case: reconstruct path using preserved attributes if available
    const single = Array.isArray(pathInfo) ? pathInfo[0] : null;
    if (single) {
      const f = single.fill || rectMatch && rectMatch[1] || '#000';
      const fr = single.fillRule ? ` fill-rule="${single.fillRule}"` : '';
      const cr = single.clipRule ? ` clip-rule="${single.clipRule}"` : '';
      const hasEvenOdd = /evenodd/i.test(single.fillRule || '') || /evenodd/i.test(single.clipRule || '');
      if (hasEvenOdd && /M[^M]*M/.test(single.d)) {
        const normalized = normalizeEvenOddToNonZero(single.d).replace(/"/g, '&quot;');
        return `<path d="${normalized}" fill="${f}" />`;
      }
      const dFull = single.d.replace(/"/g, '&quot;');
      return `<path d="${dFull}" fill="${f}"${fr}${cr} />`;
    }
    return full;
  });

  // Remove any leftover mask attributes like mask="url(#id)"
  svgText = svgText.replace(/\s+mask=["']?url\([^\)]*\)["']?/gi, '');

  // Remove clip-path attributes since they don't impact the glyphs and often
  // refer to definitions that we later strip.
  svgText = svgText.replace(/\s+clip-path=["']?url\([^)]+\)["']?/gi, '');

  // Convert rects to paths, but drop ones that are clearly just full-backgrounds.
  svgText = svgText.replace(/<rect\b([^>]*)\/\>/gi, function (m, attrs) {
    // parse numeric values (ignore percentages for simplicity)
    const width = parseFloat((attrs.match(/width=["']?([^"'\s>]+)["']?/) || [])[1] || '0');
    const height = parseFloat((attrs.match(/height=["']?([^"'\s>]+)["']?/) || [])[1] || '0');
    const x = parseFloat((attrs.match(/x=["']?([^"'\s>]+)["']?/) || [])[1] || '0');
    const y = parseFloat((attrs.match(/y=["']?([^"'\s>]+)["']?/) || [])[1] || '0');
    const fill = (attrs.match(/fill=["']?([^"'\s>]+)["']?/) || ['', '#000'])[1];
    // if it nearly spans the full viewbox (24x24) treat as background and drop it;
    // allow a small tolerance for floats produced by tools (e.g. 24.0009).
    const tol = 0.1;
    if (((Math.abs(width - 24) <= tol) && (Math.abs(height - 24) <= tol) && x <= tol && y <= tol) || (width === 0 && height === 0)) {
      return '';
    }
    // otherwise convert to an equivalent path
    return `<path d="M${x} ${y}h${width}v${height}h-${width}Z" fill="${fill}" />`;
  });

  // After converting rects we can safely remove any stray <defs> sections.
  // But first, if defs contain useful paths we want to preserve them.
  const defsPaths = [];
  svgText = svgText.replace(/<defs[\s\S]*?<\/defs>/gi, function (defSection) {
    let pm;
    const iter = defSection.matchAll(/<path\b[^>]*d=["']([^"']+)["'][^>]*>/gi);
    for (pm of iter) defsPaths.push(pm[1]);
    return '';
  });
  if (defsPaths.length) {
    // insert collected paths just before closing </svg>
    svgText = svgText.replace(/<\/svg>/i, defsPaths.map(d => `<path d="${d.replace(/"/g, '&quot;')}" fill="#000" />`).join('') + '</svg>');
  }

  // Merge adjacent colored path + white path pairs into a single even-odd path
  // (common pattern: masked outer shape then an inner white cutout path).
  // Repeat until no matches remain.
  let pairRe = /(<path\b[^>]*d=["']([^"']+)["'][^>]*fill=["']?(?!white|#fff|#ffffff)([^"'\s>]+)["']?[^>]*\/?>)\s*(<path\b[^>]*d=["']([^"']+)["'][^>]*fill=["']?(white|#fff|#ffffff)["']?[^>]*\/?>)/i;
  while (pairRe.test(svgText)) {
    svgText = svgText.replace(pairRe, function (_, outerFull, outerD, outerFill, innerFull, innerD) {
      // prefer a rect fill from the original source (masked rect backgrounds)
      const origRectFill = (_origSvg.match(/<rect\b[^>]*fill=["']?([^"'\s>]+)["']?[^>]*>/i) || [])[1];
      const chosenFill = origRectFill && !/^\s*(white|#fff|#ffffff)\s*$/i.test(origRectFill) ? origRectFill : outerFill;
      const combined = `${outerD} ${innerD}`.replace(/"/g, '&quot;');
      return `<path d="${combined}" fill="${chosenFill}" fill-rule="evenodd"/>`;
    });
  }

  // Normalize any remaining compound paths with fill-rule="evenodd" to nonzero winding
  // (these are typically from the colored+white merge above)
  svgText = svgText.replace(/<path\b([^>]*)>/gi, function (match, attrs) {
    if (/fill-rule\s*=\s*["']evenodd["']/i.test(attrs)) {
      const dMatch = attrs.match(/d\s*=\s*["']([^"']+)["']/);
      if (dMatch) {
        const d = dMatch[1];
        // Only normalize if it's a compound path (multiple M commands)
        if (/M[^M]*M/.test(d)) {
          const normalized = normalizeEvenOddToNonZero(d);
          // Remove fill-rule and clip-rule attributes after normalization
          let newAttrs = attrs.replace(/d\s*=\s*["'][^"']*["']/, `d="${normalized.replace(/"/g, '&quot;')}"`);
          newAttrs = newAttrs.replace(/\s*fill-rule\s*=\s*["'][^"']*["']/gi, '');
          newAttrs = newAttrs.replace(/\s*clip-rule\s*=\s*["'][^"']*["']/gi, '');
          return `<path${newAttrs}>`;
        }
      }
    }
    return match;
  });

  // Drop any <defs> sections entirely; they are not needed for simple path
  // shapes and can otherwise leave behind empty clipPaths etc.
  svgText = svgText.replace(/<defs[\s\S]*?<\/defs>/gi, '');

  // Ensure path elements have a fill (fonts expect filled shapes). Add fill="#000" if missing.
  svgText = svgText.replace(/<path(?![^>]*\bfill=)/gi, '<path fill="#000"');
  // Also ensure basic shapes like circle/ellipse/polygon have fill if missing
  svgText = svgText.replace(/<(circle|ellipse|polygon|polyline)(?![^>]*\bfill=)/gi, '<$1 fill="#000"');

  return svgText;
}

function generateDart(map, ttfRelativePath) {
  const entries = Object.keys(map).sort();
  const fontFamily = fontName;
  const lines = [];
  lines.push("import 'package:flutter/widgets.dart';");
  lines.push('');
  lines.push(`class ${className} {`);
  lines.push('  ${className}._();'.replace('${className}', className));
  lines.push(`  static const String _kFontFam = '${fontFamily}';`);
  lines.push('');
  for (const name of entries) {
    const code = map[name];
    const ident = toDartIdentifier(name);
    lines.push(`  static const IconData ${ident} = IconData(0x${code.toString(16)}, fontFamily: _kFontFam);`);
  }
  lines.push('}');
  return lines.join('\n');
}

// create a simple preview HTML containing every icon from the map
function generatePreview(map) {
  const entries = Object.keys(map).sort();
  const lines = [];
  lines.push('<!doctype html>');
  lines.push('<html>');
  lines.push('<head>');
  lines.push('    <meta charset="utf-8">');
  lines.push('    <title>Icon font preview</title>');
  lines.push('    <link rel="stylesheet" href="./AppIcons.css">');
  lines.push('    <style>');
  lines.push('        body { font-family: Arial, sans-serif; padding: 24px; }');
  lines.push('        .icon { font-size: 48px; margin: 12px; }');
  lines.push('    </style>');
  lines.push('</head>');
  lines.push('<body>');
  lines.push('    <h2>Icon font preview</h2>');
  lines.push('    <p>If glyphs are visible here, the font was generated correctly. Use this page to confirm troublesome icons render properly.</p>');
  for (const name of entries) {
    // put the generated class first so attribute-start selectors match
    lines.push(`    <i class="icon--${name} icon"></i>`);
  }
  lines.push('    <div style="margin-top:20px">');
  lines.push('        Raw codepoint example (add): <span style="font-family:AppIcons;font-size:48px">&#xF12B;</span>');
  lines.push('    </div>');
  lines.push('</body>');
  lines.push('</html>');
  return lines.join('\n');
}

async function main() {
  if (!fs.existsSync(iconsDir)) {
    console.error('Icons directory not found:', iconsDir);
    usage();
    process.exit(2);
  }

  // pre-check for .svg files so we can give a friendlier message
  const entries = fs.readdirSync(iconsDir).filter(f => f.toLowerCase().endsWith('.svg'));
  if (entries.length === 0) {
    console.error(`No .svg files found in ${iconsDir}.`);
    console.error('Please add your SVG icon files to that directory before running the script.');
    process.exit(1);
  }

  try {
    await runFantasticon();
  } catch (err) {
    console.error(err.message);
    console.error('If fantasticon invocation fails, try running this command manually:');
    console.error(`npx fantasticon ${iconsDir} --output ${outDir} --name ${fontName} --font-types ttf --asset-types css --prefix ${cssPrefix}`);
    process.exit(1);
  }

  const cssFile = findFileWithExt(outDir, '.css');
  const ttfFile = findFileWithExt(outDir, '.ttf');
  if (!cssFile) {
    console.error('Could not find generated CSS in', outDir);
    process.exit(1);
  }
  if (!ttfFile) {
    console.error('Could not find generated TTF in', outDir);
    process.exit(1);
  }

  const cssText = fs.readFileSync(cssFile, 'utf8');
  const map = parseCssForMapping(cssText, cssPrefix);
  if (Object.keys(map).length === 0) {
    console.error('No icons parsed from CSS. Check CSS prefix or CSS structure.');
    process.exit(1);
  }

  // also write an HTML preview file listing every generated icon
  try {
    const previewHtml = generatePreview(map);
    fs.writeFileSync(path.join(outDir, 'icon_preview.html'), previewHtml, 'utf8');
  } catch (e) {
    console.warn('Failed to write preview HTML:', e && e.message);
  }

  // Ensure dart output directory exists
  const dartDir = path.dirname(dartFile);
  fs.mkdirSync(dartDir, { recursive: true });

  const ttfRelative = path.relative(path.dirname(dartFile), ttfFile).replace(/\\/g, '/');
  const dartCode = generateDart(map, ttfRelative);
  fs.writeFileSync(dartFile, dartCode, 'utf8');
  console.log('Wrote Dart icons to', dartFile);
  console.log('Generated font file at', ttfFile);
  console.log('Next steps: add the font to your pubspec.yaml under `fonts:` and use the icons like: Icon(${className}.icon_name)');
}

// make sanitizeSvg available for testing
module.exports = { sanitizeSvg };

if (require.main === module) {
  main().catch(err => {
    console.error(err);
    process.exit(1);
  });
}
