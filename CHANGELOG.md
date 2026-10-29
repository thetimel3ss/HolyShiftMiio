# Changelog

## 1.17.5-dev — in-game validation fixes

- Save settings and debug logs per character, importing the previous global
  preferences once without sharing the old table.
- Give weapon and offhand edit boxes unique names so their InputBoxTemplate
  textures do not collide.
- Bound spellbook lookups, treat unlearned spells as unavailable, and invalidate
  caches after spell training. Guard missing action slots before IsUsableAction.
- Do not query Innervate cooldown unless it is learned.
- Document the equipment fields' purpose and current name-only lookup.

## 1.17.5-dev — base and UI

- Fork qrospars master at 9cb6082; integrate Timeless's settings/log window from
  the private holyshift-enhanced UI.
- Initialize one settings table after SavedVariables load, migrate upstream
  globals and existing HolyShiftDB values, normalize numeric/boolean toggles,
  and preserve upstream's opt-in defaults (all off for a fresh installation).
- Keep legacy slash commands, including weapon/offhand, synchronized with the UI.
- Retain original SavedVariables, including HSDebugLog, for persistence and migration.
- Add equipment editors, log viewer, live visible log updates, clear action,
  and saved/restored positions for both dialogs.
- Mark the upstream no-op clawadds control as legacy and disable its checkbox.
- Register druid combat events using the locale-independent class token.
- Validate with local Lua 5.0 regression checks and record author research locally.
- Preserve the upstream combat, rotation and utility functions; rotation changes
  belong to the next phase.
