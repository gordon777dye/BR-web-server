# Data model notes — read with `data-model.md`

`data-model.md` is generated from the app's `filelay/` folder and must not be hand-edited. This file
records what the generated model can't show.

## Measured facts (read-only BR probes, 2026-10-23)

| File | RLN | Records | `VERSION()` | Key |
|---|---|---|---|---|
| `data\customer` | 280 | 120 live (LREC 121) | 2 | `customer.key` = bytes 1-19 (`CUSTOMER`+`RCD_TYPE`+`DESTINATION`) |
| `data\comments.ind` | 306 | 18 | — | none |
| `data\logfile.ind` | — | file does not exist | — | — |

- `customer`: bytes 260-280 of the record are not described by any field.
- All 120 `customer` records read through the layout's FORMs with no conversion errors, and every
  date field (`BH 3`) is 0 or a day number between 1980 and 2030.

## `customer` layout history

On 2026-10-23 `filelay/customer` was corrected:
- The header version went from `0` to `2`, matching the data file.
- The positions column was updated for `UNUSED$ C 5` (186-190), which had been added without
  positions.
- `filelay/version/customer.2` was added so a future bump to 3 can migrate.

The FORMs were not changed; they already matched the data. The original layout is in
`onboarding/backup/customer.filelay.20261023`. `data-model.md` was regenerated afterwards and
now shows the right positions.
