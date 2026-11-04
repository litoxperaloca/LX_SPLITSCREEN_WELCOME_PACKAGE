# Changelog

All notable changes to **LX Split-Screen Welcome Package**.

## v2.2.0

Update to an already published mod. Earlier versions are on the Workshop page.

### Changed in this version

- The package no longer waits a fixed 2000 ms after the character is created. It waits for what it actually needs - the character's inventory - behind a short 400 ms floor, with a 6000 ms ceiling so it can never wait forever.
- That fixed wait was why the backpack was always the last thing to appear on spawn, and far worse on the first load of a session: the check lives in OnPlayerUpdate, which only runs when a frame runs, and during the first load the frame rate is on the floor while chunks stream in.
- Nothing else changed: the same contents, the same once-per-character flag, the same options.
- Package contents are now configurable in Options -> MODS (backpack, weapons, tools, survival).
- All text moved to translation files (EN/ES/RU).
- Turning the backpack off delivers the gear straight to the main inventory.

### Included

- One pack per local character
- What is in it
- Pick what you get
- Careful about your stuff
- Does not duplicate
