# EXP A / B — independent silicon reproducers

Owner 2026-09-17: **D holds the Arty exclusively. Board-lease protocol dropped.**
Do not GRANT/RELEASE via AGENT_E. Do not give the board to anyone else.

Not PACK_ABI_24_24_PASS / BOARD_PASS / PROGRAM_PASS.

## Experiment A — Fresh V-02

- Bit: ISO `f6a6091f…` via `arty_d/m4_mig/run_program.bat` (do not overwrite freeze DCPs).
- Reprogram **before every attempt**.
- One case: `PA24-V-02` (ISO MAG `0200015a`). No CLEAR. No 24-case corpus.
- Host: `D:/FPGA/arty_d/exp_a_b/uart_exp_a_fresh.py`
- Capture: host TX bytes/words, UART RX bytes/words.
- FIFO word + opcode/magic at pack_loader: XSim `run_xsim_exp_a.bat` and later ILA.

## Experiment B — Liveness

- Independent of A. Program H `cf62102f…` **once**.
- Repeat: CLEAR → `PA24-V-04` (known-good on H) → CLEAR → same PACK.
- No case-id diversity. Stop at first MUTE.
- Host: `D:/FPGA/arty_d/exp_a_b/uart_exp_b_liveness.py`

## Result 2026-09-17 (UART_BOARD CANDIDATE)

- **A silicon:** V-02 GOLD 3/3 after reprogram. Host TX w1=`3149414e`. Hist ISO MAG `0200015a` **CONTRADICTED_TODAY**.
- **A XSim:** `EXP_A_V02_DUALCLK_XSIM_PASS` PATH_MATCH 52 words MAGIC to loader. dest BRAM. Not BOARD.
- **B silicon:** H once. CLEAR ACK + V-04 GOLD → CLEAR `5a070002`=`0200075a` R_UNSUP → later CLEAR **n=0 MUTE**. No 24-case.
- **B XSim:** 8/8 CLEAR ACK + V-04 GOLD. No mute.
- SRAM left MUTE on H for ILA. Do not 24-case. PROGRAM_PASS=NO.

## ILA (after A/B classify)

mark_debug: `w_data/w_valid/w_ready`, fifo wr, fifo rd `f_data`, `p_data/p_valid/p_ready`, `pack_lock`, `clr_take`.
Arm on B step-2 CLEAR after GOLD, not on V-02 MAG.
