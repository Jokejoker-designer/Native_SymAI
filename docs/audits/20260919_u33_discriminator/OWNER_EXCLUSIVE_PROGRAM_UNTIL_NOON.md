# Owner exclusive PROGRAM window — noon 2026-09-21

STATUS: ACTIVE  
GRANTED_BY: Anh (owner)  
HOLDER: AGENT_D only  
FROM_LOCAL: 2026-09-21 07:16 +07  
UNTIL_LOCAL: 2026-09-21 12:00 +07  
UNTIL_UTC: 2026-09-21T05:00:00Z  
RESOURCE: ARTY_A7_100T JTAG `210319BE776EA` UART FTDI `210319BE776EB` COM12 115200

Owner: từ giờ tới 12h trưa được dùng board.

Midnight window `OWNER_EXCLUSIVE_PROGRAM_UNTIL_MIDNIGHT.md` **EXPIRED** 2026-09-21 00:00 +07. This grant supersedes it.

E không nạp. Agent khác không JTAG/UART. `PROGRAM_PASS=NO` trừ khi owner stamp. `PACK_ABI_24_24_PASS=NO`.

Không đè identity H `cf62102f…`, U33 `ff399e0b…`, freeze DCP `858d0e99…` / `b48b7c88…`, historical M4+mig bit `f6a6091f…`, TAPCDC `eb99ac69…`, old OBS `71b9198f…`, rg_off `251eafa9…`, steer `bd541f95…`.

Nạp unique rearm `08c647ee…` only unless a **new unique SHA** (query-observe) is BIT_OK in a new dir.

Hết 12:00 +07: PROGRAM=NO trừ YES mới.

`generation_flipped=true` iff
`commit_event==1 AND generation_after!=generation_before AND same_capture_epoch AND capture_valid==1`
on THIS pack. Do not invent reject flip=0.
