# V-03 R_SENTINEL: sentinel read region base, not written word — not PACK_ABI (2026-09-20)

This watch did **not** program and did **not** run Pack24. Parent `D_U33OBS_V03_SENTINEL_RDADDR.json` sha256 `632dc91e…`. **PACK_ABI_24_24_PASS=NO**. **PROGRAM_PASS=NO**. **BOARD_PASS=NOT_EVIDENCED**. Overlay **NO**. C RTL untouched. B gold unmodified. OBS bit `71b9198f…` **not overwritten**. `new_bit=NOT_BUILT`.

Isolated V-03-first still NAK `0200085a`. Isolated V-01 GOLD same boot. Dirty-BRAM XSim: write `@0x20` first=`99b0ba25`; old read `@0x10` `cafebabe` R_SENTINEL; after `rg_off` read `@0x20` LOAD_OK. `xsim_v03.log` sha256 `4e7d2442…` `V03_DIRTY_DEST_LOAD_OK`. `pack_loader.sv` sha256 `bb59f068…`.

Empty-BRAM 24-case XSim can false-pass unread region-base. Silicon still old loader until a **new unique** OBS bit. A-03 MUTE, flip 0-vs-absent, R-04/G-04 query still block Pack 24/24.
