![Maintained](https://img.shields.io/badge/Maintained%3F-yes-green.svg)
![WoW Classic](https://img.shields.io/badge/WoW%20Classic-TBC%20%7C%20SoD-9cf.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![CurseForge Downloads](https://img.shields.io/curseforge/dt/958792)

### Download from the official [CurseForge website](https://www.curseforge.com/wow/addons/gearscoreclassic)

---

## Fork Notice & Credits

This addon is a **community-maintained fork** of **GearScoreClassic**, originally created by **gk646** and released under the **MIT License**.

The original project appears to be no longer actively maintained.
This fork exists to keep the addon functional and updated, adding **The Burning Crusade Classic (TBC)** support and maintenance fixes, while preserving the original behavior and philosophy of the addon.

The original README content has been adapted where necessary for clarity and accuracy.

---

## GearScoreTBCClassic+

**GearScoreTBCClassic+ is an addon for World of Warcraft Classic (TBC / Season of Discovery).**  
It calculates and displays a Gear Score (GS) for your character and for other characters you inspect or hover over.

![CharacterFrame](pictures/GearScoreTBCClassic+.png)

---

## Purpose

GearScoreTBCClassic+ provides a general metric representing the overall quality of a player's gear.

The Gear Score (GS) is calculated based on multiple attributes of each equipped item, including item level, enchantments, and slot-based modifiers.  
It is intended as a **quick comparative metric**, not as a replacement for detailed gear analysis.

---

## Calculation

The Gear Score is calculated using the following methodology:

1. **Item Level and Slot Modifier**  
   Each item's base score is derived from its item level and adjusted by a predefined modifier depending on the equipment slot (e.g. head, chest, weapon).  
   Different slots have different weights to reflect their relative importance.

2. **Enchantments**  
   Enchantable items that have enchantments contribute additional points to the final gear score, acknowledging the added value of enchanted gear.

---

## Features

- **Gear Score (GS)** displayed for your character and inspected characters
- **Average Item Level (iLvl)** calculation and display
- **Character Frame & Inspect Frame integration**
- **Colored Gear Score**, based on percentile relative to the current phase (similar to Warcraft Logs)
- Lightweight and automatic — no configuration required

---

## Usage

Simply install the addon and log into the game.

Gear Score and average item level will automatically appear in:
- The character frame
- The inspect frame
- Tooltip hover information (where applicable)

There are currently no slash commands or configuration options.

---

## License

This project is licensed under the **MIT License**.

Original work © 2024 **gk646**  
Fork maintenance and updates © 2026 **Community contributors**
