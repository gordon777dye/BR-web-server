# Kit Errors

Please record any context kit errors here that are found in the course of its use.
---

## 2026-10-24 — found while building brweb's web_server 2.11

1. **Multiplying by `INF` raises error 0006 ("Division by zero"). The kit doesn't say so.**
   `br_tree/10-language/.../spec.md` defines `INF` only as the "largest representable number
   (`1.0E+307`)", and `essentials.md` shows it only as a string-slice bound (`X$(INF:0)`). On BR
   5.01 (Debug build, `WBVERSION$` = 5.01), every multiplication involving `INF` stopped with
   error 0006: `INF*1`, `INF*0`, `0*INF` and `300+INF*0`. Addition worked: `300+INF` gave
   `E+307`. The message names division, so it misleads. Found in a real program, where
   `POST$(1:300+INF*SGN(FLAG))` stopped an unattended server. The probe is
   `context/scratch/mini_inf0.brs`, with its output in `mini_inf0.txt`. Suggest an `essentials.md`
   §4 entry: use `INF` only as a bound or in comparisons, never in multiplication.
