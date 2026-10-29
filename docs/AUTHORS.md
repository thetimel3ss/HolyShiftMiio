# HolyShift authors and related versions

Research date: 2026-10-29. Public repository history is evidence of code provenance;
matching nicknames alone is not evidence that two accounts are the same person.

## Provenance

- [ZachM89/HolyShift](https://github.com/ZachM89/HolyShift) is the original GitHub
  repository in this fork network. Its README credits **Maulbatross (Kronos 3)** and
  acknowledges functions borrowed from [Cernie/CatDruidDPS](https://github.com/Cernie/CatDruidDPS).
  The latest master commit is [3f061f9, 2019-08-11](https://github.com/ZachM89/HolyShift/commit/3f061f9669c0a307d17195bae507a7892637df0f).
  That commit explicitly switches Bite to four or more combo points based on the
  author's observed DPS; the README's five-point claim was not updated.
- [qrospars/HolyShiftMiio](https://github.com/qrospars/HolyShiftMiio) descends from
  that exact commit. Eight commits dated 2026-02-14 add Turtle metadata,
  mana handling, rotation/debug changes, immunity handling and Shred gating.
  GitHub attributes these commits to the **QuentinRospars** account. The
  repository owner is **qrospars**, whose public profile links a Quentin Rospars
  portfolio. These account names are not proof of which in-game character they use.
- The [maintainer-credit commit](https://github.com/qrospars/HolyShiftMiio/commit/5574f7b71d91ecb6335cc5d2f6e22a7cdad341f4)
  introduces **Miioon (Turtle WoW)** as maintainer while retaining Maulbatross.
  No independently verified Miioon addon collection or more recent standalone
  HolyShift release was found. Do not associate unrelated people with this nickname.
- UI source: the user's private `thetimel3ss/holyshift-enhanced`,
  `HolyShift_UI.lua`, blob `72b4f33c8373d66079e5375dfa703b0a1b94f5d2` (Timeless).
  The settings dialog layout and debug frame are adapted here, with migration,
  synchronized commands, equipment controls, and a completed debug viewer.

## Alternative branches and forks

- qrospars master: `9cb60822a0cf6391dd34828802b0c0965b752016`.
- [backup/pc-transfer-20260317](https://github.com/qrospars/HolyShiftMiio/tree/backup/pc-transfer-20260317)
  is one commit ahead of master: `8211efaafb86437b7e2c989043a68e4e98c6ad59`.
  It adds own-Rip tracking based on casts/ticks, Shred usability guards and optional
  cast-debug whispers to **Miioon**. This is a backup, not a verified superior
  release. Its own-Rip tracking uses target names and short inferred windows;
  failed casts, same-named enemies, and multi-druid fights need testing.
  This branch is documented for later study, not merged into this base/UI phase.
- [maloch11/HolyShift](https://github.com/maloch11/HolyShift) is one commit ahead of
  ZachM89 master and changes one condition: out-of-melee Faerie Fire checks the
  cooldown and the user's toggle. qrospars master already contains that gate.
- [srazdokunebil/HolyShift](https://github.com/srazdokunebil/HolyShift) has the same
  reported latest push as the 2019 original; no newer improved release was established.
- No tags were returned for qrospars/HolyShiftMiio at the research date.

## Related public projects

- [qrospars/ShaguScanLongRange](https://github.com/qrospars/ShaguScanLongRange):
  fork of ShaguScan, a SuperWoW unit scanner with an additional longer-range filter.
- [qrospars/OctoWoW-Installation-Manager](https://github.com/qrospars/OctoWoW-Installation-Manager):
  fork of a client/settings/DLL/MPQ/addon installation manager; a tool rather than a rotation addon.
- [ZachM89/RaidConsumablesTracker](https://github.com/ZachM89/RaidConsumablesTracker):
  spreadsheet using Advanced Trade Skill Window data to plan raid consumables
  and crafting materials; not another rotation engine.
- [Cernie/CatDruidDPS](https://github.com/Cernie/CatDruidDPS): the acknowledged
  earlier source for several helpers, useful for historical comparisons.

The search found no independently confirmed additional Maulbatross/Miioon addon
repositories. This is a limit of the public search, not proof that none exist.
