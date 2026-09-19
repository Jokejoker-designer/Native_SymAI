# Audit feed from chat `31dc87bc-7c69-45e9-8f38-a233417caeb3`

Side chat watches the parent Cursor session and publishes **completed** findings here. Not a PASS stamp.

Last published: 2026-09-19T08:49+07 from parent turns through ~08:34+07.

## Parent is doing

OBS01-MIG0: same CLEAR→V-04→CLEAR→V-04 on generated `mig0`, checkpoints P0–P15, no UART overlay.

## New since GitHub `e97895b`

### 2026-09-19 08:31+07 — RAW_MIG_READY_USED_AS_QUIESCENCE

Parent reviewed Anh’s hypothesis **before overlay**.

| Layer | Verdict |
|---|---|
| `MISSING_APP_RDY_GATE` | **WEAK** — idle `mig_ui32` does not need `app_rdy`; mux `G_NONE` zeros `p_rdy` on purpose |
| U31/U32 `pack_quiescent` ANDs raw `mig0.app_rdy`/`app_wdf_rdy` | **FACT** (`pack_mig_bind.sv` + top wiring) |
| PACKAGE live qsc | **FACT** — loader+ui+outstanding only; no `dest_ui_*` |
| BRAM `app_rdy = rst_n && !stall` | **FACT** — OBS01 BRAM CLEAN cannot refute dest-ready dips |
| Board CLEAR1 BUSY / BEGIN hold caused by that AND | **HYPOTHESIS** until OBS01-MIG0 snapshot |
| Root cause | **UNKNOWN** |

Do not UART-overlay. Do not strip `dest_ui_*` from qsc until CLEAR2 log shows:

`ui IDLE, out=0, loader out=0, dest_rdy=?, dest_wdf_rdy=?, qsc_ui=?`

Sources:

- `CANON_BLUEPRINT/_COORDINATION/reasoning/NATIVE_AI_REASONING_EXPERIENCE_V1_AGENT_D_20260919T013100Z.md`
- `results/arty_d/D_DEST_LIFECYCLE_OBS_01/tb_dest_lifecycle_obs_01_mig0.sv` sha256 `d84cf4ac97e1f359e76aba858fc5c80cbdf28dc047f6f228b0c561b089d7d0d9` (CLEAR2 now prints `OBS01_QSC_VS_RDY`)

### 2026-09-19 08:34–08:36+07 — OBS01-MIG0 compile

Parent resumed xelab; interrupted. **No MIG0 XSim result.** `MIG0_BOARD_CAUSAL_CLASS=STILL_OPEN`.

```
PACK_ABI_24_24_PASS = NO
```
