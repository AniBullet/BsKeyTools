# BsRetargetTools List Format

This document records the mapping `.list` formats accepted by `BsRetargetTools.ms`.
The loader must stay backward-compatible with existing user presets.

## Compatibility Rules

BsRetargetTools accepts these list shapes:

- Legacy list without a `v2` marker.
- Legacy list with only 69 bone mapping rows.
- Legacy list with 70 rows, where row 70 is Root.
- Existing legacy presets with 74 or 76 rows, where extra rows store partial axis settings.
- v2 list with 77 rows:
  - row 1: `v2`
  - rows 2-70: 69 bone mapping values
  - row 71: Root
  - rows 72-77: axis selections

`~undefined~` is a valid placeholder in any row.

## Root Handling

Root can be omitted or set to `~undefined~` in bundled presets. This keeps presets portable across imported skeletons whose top-level parent names differ.

Runtime Root resolution uses this priority:

1. If the list Root exists in the scene, use it.
2. If mapped slot 1 exists and has a parent, use that parent.
3. If a known scene Root name exists, use it.
4. If no valid Root exists, block unsafe operations and tell the user to pick Root manually.

Root must not be mapped to slot 1 (Hips/COM) itself or to one of its descendants.

Known Root candidate names currently include:

- `Root`
- `root`
- `ROOT`
- `Armature`
- `Skeleton`
- `Character`

## Authoring Presets

For new bundled presets:

- Prefer v2 format.
- Keep all 69 bone rows present.
- Use `~undefined~` for bones that are intentionally unmapped.
- Leave Root as `~undefined~` when the skeleton family does not have a stable shared Root name.
- Fill Root only when the Root node name is stable across exports.
- Never set Root to the same node as slot 1.
- Do not remove optional finger rows; missing rows break line-based compatibility.

## Safety Checks

Run this before committing preset changes:

```powershell
powershell -ExecutionPolicy Bypass -File tools/check-bs-retarget-lists.ps1
```

Warnings for undefined Root are acceptable. Errors for short files or malformed v2 presets must be fixed.
