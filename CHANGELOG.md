# Changelog

## 1.2.0 - 2026-07-18
- Added item tooltip GearScore comparison against equipped gear.
- Added enchant and gem GearScore breakdowns, including missing bonus values.
- Added an account-wide option to show the detailed item tooltip breakdown; it is disabled by default.
- Added support for two-handed weapon average item level calculation.
- Added a compact GearScore and item level display to character and inspect frames.
- Added sponsor guild highlighting in unit tooltips and friendly nameplates.
- Added configurable sponsor recruitment text.
- Fixed tooltip errors when comparing rings and trinkets.

## 1.1.0 - 2026-03-24
- Added movable GearScore display on the character and inspect panels.
- Type `/gs` to toggle unlock mode, drag the display to reposition, then `/gs` again to lock.
- Also supports `/gs unlock`, `/gs lock`, and `/gs reset` to restore the default position.
- Position is saved per-character and persists across sessions.

## 1.0.1 - 2026-03-02
- Replaced the legacy split formula (`<= ilvl 120` vs `> ilvl 120`) with one linear formula table for all item levels.
- Removed the hard ilvl 120 breakpoint so score progression is simpler and easier to reason about.
- Fixed a score regression for items above item level 120 by making the split GearScore formula continuous at the threshold.
- This resolves cases where high-tier TBC upgrades (for example Magtheridon and Prince Malchezaar weapons/wands) could show lower GS than lower-ilvl dungeon or Karazhan items.
- Kept legacy slot weights and formula slopes intact while removing the ilvl 120 score drop.
