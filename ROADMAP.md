# Roadmap

## Phase 1 — base and interface

Implemented on feature/base-ui:
- Fork qrospars master and adapt the private UI.
- Settings migration, original commands, equipment configuration and persistent debug.
- Lua 5.0 settings/UI regression checks.

Pending in-game acceptance:
- Open /holyshift, /hs and /hsdps ui; check layout and all active toggles.
- Change settings through both commands and UI, /reload, verify saved values.
- Save weapon/offhand, drag both dialogs, /reload, verify restoration.
- Generate a debug log, reopen it, scroll, clear, /reload, verify persistence.
- Confirm /hsdps dps still executes the upstream rotation on a druid.

## Phase 2 — server-aware cat rotation (not implemented yet)

- Separate bleed/Claw and Shred/no-bleed profiles.
- Read actual talents, costs and own bleeds; support Carnage refresh tracking.
- Prefer positioned Shred on Clearcasting according to the selected profile.
- Evaluate Reshift against mana, energy ticks and buffs lost by shifting.
- Study qrospars's backup own-Rip/Shred changes without importing cast whispers.
- Compare profiles under controlled in-game conditions before automatic selection.
