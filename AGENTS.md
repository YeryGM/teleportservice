# AGENTS.md

## Project

Roblox game (horror/survival). Luau runtime — all source files use `.lua` extension, not legacy Lua 5.1. Server/client code split enforced by Rojo folder structure.

## Setup

```sh
wally install   # installs Packages/ — must run after clone; directory is gitignored
```

Dependencies: React 17.2.1, ReactRoblox 17.2.1, Promise 3.5.2, Reflex 4.3.1.

`.luaurc.json` sets `languageMode` to `nonstrict` — Luau LSP won't flag missing type annotations.

## Commands

```sh
rojo serve apollo1.project.json                          # dev sync to Roblox Studio
rojo sourcemap apollo1.project.json > sourcemap.json     # generate for Luau LSP
selene src                                                # lint (std = roblox)
```

No test framework. No CI pipeline. No codegen.

## Source Layout

All game code lives under `src/apollo1/`. Rojo maps three directories into the DataModel:

| Rojo Service | Filesystem Path | Purpose |
|---|---|---|
| `ReplicatedStorage` | `src/apollo1/ReplicatedStorage/modules/` | Shared data, enums, utilities |
| `ServerScriptService` | `src/apollo1/ServerScriptService/modules/` | Server-only logic |
| `StarterPlayerScripts` | `src/apollo1/StarterPlayer/StarterPlayerScripts/modules/` | Client-only logic + React UI |

`src/apollo1/NotInGameYet/` contains unused/in-progress code, not mapped by Rojo. `Packages2/` contains an untracked `FastCast2.rbxmx` model (not mapped by Rojo, not gitignored).

## Conventions

- **Client modules** use `*C.lua` suffix: `PlayerC`, `StoryManagerC`, `ZoneDetectorC`, etc.
- **Server scripts**: only entrypoints use `*.server.lua` (`Main.server.lua`). All other server modules use plain `.lua`.
- **Reflex store slices** follow strict 4-file pattern: `{Name}State.lua`, `{Name}Producer.lua`, `{Name}Actions.lua`, `{Name}Selectors.lua`. 12 slices total (ui, shop, crafting, death, objectives, stamina, subtitles, qte, hud, cutscene, minigame, lobby).
- **UI services** (`ui/services/UIS*.lua`) bridge React UI to server Remotes — they invoke `RemoteFunction:InvokeServer()` then dispatch to the Reflex store via Actions.
- **Custom hooks** use `use` prefix: `useHud`, `useShop`, `useStoreSelector`, etc.
- **Data enums** use `E` prefix (e.g. `EDialogues`). Most enums are consolidated in the central `Enums.lua`. **Info files** use `IF` prefix (`IFBombs`, `IFTolls`).
- **All modules** must implement `:load()`. Zone modules additionally handle `loadZone(previousZone, newZone)`.

## Entrypoints

Both entrypoints bootstrap via a `Signals` module then a Schemer module:

- **Server**: `Main.server.lua` → creates `Signals`, then `Schemer:load()`
- **Client**: `Main.client.lua` → creates `SignalsC`, then `SchemerC:load()`

Bootstrap sequence (both sides): Schemer → ZoneDetector → ModuleLoader. ModuleLoader reads a `Modules.lua` registry that lists all services for the current zone.

## Architecture

**Server**: classical OOP via metatables (`setmetatable({}, {__index = Player})`). PlayerManager orchestrates per-player handler objects. DataStore modules (`*DS.lua`) handle persistence.

**Client UI**: React-Luau 17 functional components + Reflex state management. 4 root ScreenGuis layered by DisplayOrder: GameplayRoot (1), OverlayRoot (10), MinigameRoot (20), ModalRoot (30).

**Zone-based loading**: game content is loaded/unloaded per map zone. `ZoneDetector` tracks player position via CollectionService tags and part touch events.

**Bomb/effect system**: strategy pattern — each bomb type (Health, Freeze, Death, etc.) has a paired effect module.
