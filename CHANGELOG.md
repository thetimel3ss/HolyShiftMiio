# Changelog

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
- Add Lua 5.0 regression checks and an evidence-linked authors/provenance report.
- Preserve the upstream combat, rotation and utility functions; rotation changes
  belong to the next phase.
