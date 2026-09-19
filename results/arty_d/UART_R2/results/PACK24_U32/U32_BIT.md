# U32 bitstream — CDC rebuild

PACK_ABI_24_24_PASS = NO.
PROGRAM_PASS = NO.
TIMING_PASS = NO. Report: “All user specified timing constraints are met.” Observation only.

Candidate `build_u32/uart_r2_u32_candidate.bit` sha256 `0df4de2ec075bfdbe567bb661702da088a1be5322cc9112ad2ebf959d116f6ff`.
DCP `post_route.dcp` sha256 `7f48a5e7307ddc72355476491ff829a4780fc19fc5f1fccde8c457c6cebe7d1f`.
Not H. Not U31 `08cbb854…`. Not the WNS-fail copy `bd01a209…` (`uart_r2_u32_wns_n0p418.bit`).

Route LUT 10567 FF 8903 RAMB36=3 RAMB18=2 DSP 8. Nets 17690/17690. WNS **+0.750** WHS +0.027 TNS=0.

Prior combo `clr_tx_busy_rst` → `busy_u0` was WNS −0.418. This bit samples `tx_busy_100_r` then 2FF; U32-only `set_max_delay` 8 ns. XSim leftover / two_v04 / sreq_nack PASS_XSIM on BRAM after that FF.

Dest_accept / dest_ui_rdy not overlaid.
