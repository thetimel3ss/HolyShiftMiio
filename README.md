# HolyShift

HolyShift is a Turtle WoW feral druid addon focused on one-button cat DPS with optional raid automation and debug tooling.

This fork: **Timeless** — [thetimel3ss/HolyShiftMiio](https://github.com/thetimel3ss/HolyShiftMiio)

Upstream maintainer credit: **Miioon**
Original author: **Maulbatross (Kronos 3)**

## Configuration interface

The configuration and log windows are adapted from Timeless's private
`holyshift-enhanced` UI. Open settings with `/holyshift`, `/hs`, `/hsdps ui`,
or `/hsdps config`. The combat macro remains `/hsdps dps`.

Checkboxes and the original commands share per-character settings in
`HolyShiftCharacterDB`. Existing account-wide `HolyShiftDB` preferences are copied
once on each character's first login after upgrading; later changes are independent.
The old table remains an import source, not the active configuration. Debug logs
are also saved per character. Fresh installations keep upstream defaults: all
optional toggles off.

Weapon/offhand fields accept the item name as shown in your client, or `None`;
press Enter or Save equipment. Numeric item IDs are not supported by the current
lookup. Weapon is the replacement after MCP runs out of charges; Offhand is the
companion offhand and the return item after Ancient Cornerstone Grimoire use.
Items must be available in your bags. These fields do not select rotation weapons
or equip a set every time the combat macro is pressed.
Use View log or `/hsdps debug ui` for the debug window. Both windows remember
their positions. `clawadds` is preserved for compatibility but its checkbox is
disabled: it has no effect in the upstream rotation.

This phase preserves qrospars master's rotation. Future rotation work and in-game
acceptance steps are in [ROADMAP.md](ROADMAP.md). Author research and regression
tests are maintained locally and are not included in this repository.

## What It Does

- Runs cat DPS from one macro: `/hsdps dps`
- Uses a bleed-engine style priority:
  - Keep **Rake** up
  - Use **5 CP Rip opener** when Rip is missing
  - Use **5 CP Ferocious Bite** after Rip is up
  - Use **Shred** when behind + high energy
  - Use **Claw** otherwise
- Supports automatic powershifting on low energy
- Supports Turtle WoW **Reshift** (if learned), with Cat Form fallback
- Handles raid utility/automation options (MCP, consumables, cower, FF, etc.)

## Requirements

- Vanilla client API compatible with Turtle WoW
- Class: **Druid**
- Recommended level: **60**
- Action bar requirements for rotation logic checks:
  - Auto Attack
  - Claw
  - Shred (optional but recommended)
  - Rake
  - Ferocious Bite

## Quick Start

1. Install addon in `Interface/AddOns/HolyShift`
2. Create a macro with:
   - `/hsdps dps`
3. Bind it to the same key in caster and cat bars
4. In game, type:
   - `/hsdps`

## Commands

Main:
- `/hsdps dps`

Toggles:
- `/hsdps innervate on|off`
- `/hsdps mcp on|off`
- `/hsdps manapot on|off`
- `/hsdps demonicrune on|off`
- `/hsdps flurry on|off`
- `/hsdps clawadds on|off` (legacy toggle; current rotation no longer uses this in builder selection)
- `/hsdps tiger on|off`
- `/hsdps shift on|off`
- `/hsdps cower on|off`
- `/hsdps deathrate on|off`
- `/hsdps ff on|off`

Config:
- `/hsdps weapon <name|none>`
- `/hsdps offhand <name|none>`

Debug:
- `/hsdps debug on|off`
- `/hsdps debug status`
- `/hsdps debug show <N>`
- `/hsdps debug clear`

## Rotation Notes

- Tiger's Fury is used as a maintenance priority (configurable)
- Rake is refreshed only when missing
- Rip is only cast at 5 combo points and only if missing
- Ferocious Bite is used as the default 5 CP finisher once Rip is active
- Shred/Claw builder logic is automatic:
  - Shred when behind and energy is high enough
  - Claw otherwise
- "Must be behind" errors trigger a short lockout before trying behind-only behavior again

## Powershifting and Reshift

- Low-energy branches attempt shift acceleration when enabled (`/hsdps shift on`)
- If `Reshift` exists in spellbook, HolyShift will attempt to use it first
- If `Reshift` is unavailable or not ready, HolyShift falls back to Cat Form shifting
- If DruidManaLib is missing, HolyShift uses fallback shift mode (attempt-based)

## Raid/Combat Automation (Optional)

Depending on toggles and context, HolyShift can automate:
- Cower logic
- Faerie Fire upkeep
- Tiger's Fury usage
- MCP use/swap behavior
- Demonic Rune / Mana Potion / Innervate usage
- Juju Flurry usage
- Threat/defensive boss behavior branches

## Utility Functions (`/run`)

Available helper functions include:
- `AutoBuff()`
- `PatchHeal()`
- `BLTaunt()`
- `StealthOne()`
- `StealthTwo()`
- `QuickCast(spell,target)`
- `QuickStone()`
- `QuickHT()`

Examples:
- `/run QuickStone()`
- `/run QuickHT()`
- `/run QuickCast('Healing Touch(Rank 5)',1)`

## Debug persistence and validation

Enable `/hsdps debug on`, perform a test, then `/reload` or log out to save.
`HSDebugLog` remains a SavedVariable. The in-game viewer is accessible with
`/hsdps debug ui`; `/hsdps debug show 50` prints the last 50 entries to chat.
No export or auto-sync scripts are bundled with this repository.

Local regression checks were run using Lua 5.0.3 with mocked frame/unit APIs.
They cover loading, migration, synchronized controls and commands, equipment
saving, positions and persistent debug. Research and test files remain local.
Rendering, server spell behavior and DPS require in-game validation.

## Upstream

https://github.com/qrospars/HolyShiftMiio
