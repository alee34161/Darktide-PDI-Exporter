# Darktide PDI Exporter

A two-part tool for automatically recording and uploading Warhammer 40,000: Darktide session statistics to Google Sheets after each mission using /pdi_export.

---

## Overview

**PDI_Exporter** is a Darktide mod that hooks into [Power_DI](https://www.nexusmods.com/warhammer40kdarktide/mods/281) session data at the end of each mission and writes a JSON file containing per-player stats and equipment. **app.py** is a desktop application that reads that JSON, resolves display names via a lookup table, and uploads the data to a Google Sheets spreadsheet.

---

## Components

### `PDI_Exporter` — Darktide Mod

Hooks `GameModeManager.rpc_game_mode_end_conditions_met` and exports a JSON file 5 seconds after mission end via [DMF](https://www.nexusmods.com/warhammer40kdarktide/mods/8).

**Per-player data exported:**
- Melee and ranged elite, special, and trash kills
- Boss, elite, horde, and specialist damage
- Revives given and received
- Ammo used, blitz uses, combat ability uses, damage taken
- Class (archetype), melee weapon, ranged weapon
- Full talent selection list (for blitz/aura/combat ability/keystone resolution)

Output is written to:
```
<Darktide install>\binaries\dump\pdi_YYYY-MM-DD_HH-MM-SS.json
```

A manual export command is also available in-game:
```
/pdi_export
```

---

### `app.py` — Uploader Application

A tkinter desktop app that loads a PDI export file, resolves internal game keys to human-readable names via `lookup.json`, previews the extracted data, and uploads it to Google Sheets.

<!-- screenshot of the app UI here -->

**Features:**
- Auto-detects the Darktide install directory
- Browses for export files
- Maps up to 4 in-game player names to real names / Sheet tabs
- Resolves class, weapon, blitz, aura, combat ability, and keystone names via `lookup.json`
- Uploads stats row and equipment row per player to their respective Sheet tab

---

### `lookup.json` — Display Name Mapping

A hand-editable JSON file that maps internal game keys to human-readable display names. The section a talent key lives in determines its category — no code changes needed to add new entries.

```json
{
    "archetypes": {
        "veteran": "Veteran"
    },
    "weapons": {
        "bolter_p1_m1": "Boltgun Mk I"
    },
    "blitz": {
        "veteran_krak_grenade": "Krak Grenade"
    },
    "aura": {
        "veteran_aura_gain_ammo_on_elite_kill": "Scavenger"
    },
    "combat_ability": {
        "veteran_combat_ability_stance": "Volley Fire"
    },
    "keystones": {
        "veteran_improved_tag": "Focus Target!"
    }
}
```

Any key not present in `lookup.json` falls back to the raw internal key string, so new weapons or talents will always show something rather than failing silently.

---

## Requirements

### Mod
- [Darktide Mod Framework (DMF)](https://www.nexusmods.com/warhammer40kdarktide/mods/8)
- [Power_DI](https://www.nexusmods.com/warhammer40kdarktide/mods/281)

### App
- Python 3.10+
- `google-api-python-client`
- `google-auth`
- `python-dotenv` (optional, for `.env` support)

```
pip install google-api-python-client google-auth python-dotenv
```

---

## Setup

### 1. Install the mod

Copy the `PDI_Exporter` folder into your Darktide mods directory:
```
<Darktide install>\mods\PDI_Exporter\
```
Enable it in the mod menu in-game.

### 2. Configure Google Sheets access

Create a Google Cloud service account with the Sheets API enabled, and share your spreadsheet with the service account email. Add credentials to a `.env` file next to `app.py`:

```env
GOOGLE_SERVICE_ACCOUNT_EMAIL=your-account@your-project.iam.gserviceaccount.com
GOOGLE_PRIVATE_KEY="-----BEGIN RSA PRIVATE KEY-----\n...\n-----END RSA PRIVATE KEY-----"
GOOGLE_SHEET_ID=your_spreadsheet_id_here
```

### 3. Configure player tab names

In `app.py`, edit `PLAYER_TABS` to match your spreadsheet tab names:

```python
PLAYER_TABS = {
    "John":  "John Data",
    "Jane":  "Jane Data",
}
```

### 4. Fill in `lookup.json`

Run a mission and open the exported JSON. Any talent key you want resolved to a display name goes into the appropriate section in `lookup.json`. Keys left with an empty string value fall back to the raw key.

---

## Usage

1. Complete a Darktide mission — the mod exports automatically on mission end. Or select a report in Power DI and manually /export_pdi
2. Run `app.py`
3. Enter or browse to the exported JSON file
4. Click **Load Export File** to preview the data
5. Fill in the in-game → real name mapping for each player
6. Click **Upload to Google Sheets** to append rows

<img width="687" height="917" alt="image" src="https://github.com/user-attachments/assets/c7af33ff-0a35-4c8c-a5e5-5b7e784a566e" />

---

## Sheets Format

Each player gets two rows per session in their tab:

| Row | Contents |
|-----|----------|
| Stats | Date, Time, Melee Elite Kills, Ranged Elite Kills, Melee Special Kills, Ranged Special Kills, Ranged Trash Kills, Horde Trash Kills, Boss Damage, Elite Damage, Horde Damage, Specialist Damage, Revives Done, Needed Revives, Ammo Used, Blitz Uses, Combat Ability Uses, Damage Taken |
| Equipment | Class, Melee Weapon, Ranged Weapon, Blitz, Aura, Combat Ability, Keystone(s) |

<img width="2030" height="711" alt="image" src="https://github.com/user-attachments/assets/dd913755-4c3d-4774-bd08-a7be34633116" />

---

## Known Limitations

- Requires Power_DI to be running and have session data loaded — export on the end-mission screen before returning to the mourning star
- Talent display names for blitz, aura, combat ability, and keystones require manual mapping in `lookup.json` the first time a new key is encountered
- The mod identifies weapons by their internal template string (e.g. `bolter_p1_m1`) — add the display name to `lookup.json` to resolve these

---

## Acknowledgements

- [Power_DI](https://www.nexusmods.com/warhammer40kdarktide/mods/281) by the Power_DI team — session data provider
- [Darktide Mod Framework](https://www.nexusmods.com/warhammer40kdarktide/mods/8) — mod infrastructure and file export
