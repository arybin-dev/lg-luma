import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import path from 'node:path';
import { spawnSync } from 'node:child_process';

const root = path.resolve(import.meta.dirname, '..');
const out = path.join(root, '.build/custom-grid');
await fs.mkdir(out, { recursive: true });
const ids = [
  'netflix',
  'youtube.leanback.v4',
  'com.apple.appletv',
  'com.disney.disneyplus-prod',
  'amazon',
  'plex',
  'spotify-beehive',
  'org.jellyfin.webos',
  'org.xbmc.kodi',
  'com.limelight.webos',
  'org.webosbrew.hbchannel',
  'com.webos.app.browser',
  'com.arte.tv',
  'de.zdf.app.zdfm3',
  'ard.mediathek',
  'com.webos.app.livetv',
];
const preferences = path.join(out, 'preferences.json');
async function scenario(name, count, script) {
  await fs.writeFile(
    preferences,
    JSON.stringify({
      favorites: ids.slice(0, count),
      show_weather: false,
      show_home_names: true,
      language: 'ru',
      hour_24: true,
      reduced_motion: true,
    }),
  );
  const dump = path.join(out, `${name}.json`);
  const diagnostics = path.join(out, `${name}-render.json`);
  const result = spawnSync(
    path.join(root, 'target/debug/luma'),
    [
      '--preferences',
      preferences,
      '--script',
      script,
      '--frames',
      '90',
      '--time',
      '2026-11-01T23:00:00+03:00',
      '--dump-state',
      dump,
      '--diagnostics',
      diagnostics,
      '--screenshot',
      path.join(out, `${name}.png`),
    ],
    { cwd: root, encoding: 'utf8', timeout: 120000 },
  );
  assert.equal(result.status, 0, result.stderr);
  const state = JSON.parse(await fs.readFile(dump, 'utf8'));
  const render = JSON.parse(await fs.readFile(diagnostics, 'utf8'));
  assert.equal(state.error, null);
  assert.equal(render.capture.missing_images, 0);
  assert.equal(render.capture.missing_glyphs, 0);
  assert.equal(render.capture.glyph_failures, 0);
  assert.equal(state.preferences.show_weather, false);
  return state;
}
for (const count of [1, 5, 6, 10, 11, 15, 16]) {
  const rows = Math.ceil(count / 5);
  const state = await scenario(
    `rows-${count}`,
    count,
    ['down', ...Array(rows - 1).fill('down')].join(','),
  );
  assert.deepEqual(state.focus, { App: ids[(rows - 1) * 5] });
}
const partial = await scenario(
  'partial-last-row',
  16,
  'down,right,right,right,right,down,down,down',
);
assert.deepEqual(partial.focus, { App: ids[15] });
const pointer = await scenario('pointer', 15, 'click:1610:340');
assert.deepEqual(pointer.focus, { App: ids[4] });
await scenario('overview', 15, 'down');
console.log(
  'Custom grid: seven item counts, partial last row, pointer and Russian rendering passed.',
);
