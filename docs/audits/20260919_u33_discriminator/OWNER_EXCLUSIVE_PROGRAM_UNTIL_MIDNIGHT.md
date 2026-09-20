# Owner exclusive PROGRAM window

STATUS: ACTIVE  
GRANTED_BY: Anh (owner)  
HOLDER: AGENT_D only  
FROM_LOCAL: 2026-09-20 17:23 +07  
UNTIL_LOCAL: 2026-09-21 00:00 +07  
UNTIL_UTC: 2026-09-20T17:00:00Z  
RESOURCE: ARTY_A7_100T JTAG `210319BE776EA` UART FTDI `210319BE776EB` COM12 115200

Owner: chuyển goal thành đống ý; cho phép PROGRAM từ giờ tới 12h đêm; chỉ AGENT_D dùng board.

E không nạp. Agent khác không JTAG/UART. `PROGRAM_PASS=NO` trừ khi owner stamp. `PACK_ABI_24_24_PASS=NO`.

Không đè identity H `cf62102f…`, U33 `ff399e0b…`, freeze DCP `858d0e99…` / `b48b7c88…`, historical M4+mig bit `f6a6091f…`. U33TAP cũ `d448544f…` giữ trên disk; nạp TAP mới chỉ từ `build_u33tap_cdc/` nếu SHA khác.

Hết 00:00 +07: PROGRAM=NO trừ YES mới.
