# Changelog

## 1.0.1 - 2026-03-02
- Replaced the legacy split formula (`<= ilvl 120` vs `> ilvl 120`) with one linear formula table for all item levels.
- Removed the hard ilvl 120 breakpoint so score progression is simpler and easier to reason about.
- Fixed a score regression for items above item level 120 by making the split GearScore formula continuous at the threshold.
- This resolves cases where high-tier TBC upgrades (for example Magtheridon and Prince Malchezaar weapons/wands) could show lower GS than lower-ilvl dungeon or Karazhan items.
- Kept legacy slot weights and formula slopes intact while removing the ilvl 120 score drop.
