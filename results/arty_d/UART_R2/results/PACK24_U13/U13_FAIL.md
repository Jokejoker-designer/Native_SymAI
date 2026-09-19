# UART_R2_U13 board FAIL (do not delete)

IDENTITY = UART_R2_U13
BIT_SHA256 = 1722e9efef0769ded00ddcfbda5845f24b05ac0015f012f9ca72bb51c511c8e8
DCP_SHA256 = d0306a18c272d7b465140925627ed43c0ddf6b9ad001d58079c3e7eb5d7828cb
TX_SHA256 = f311a0e8f330a0161046e9e1e9c25436833bbb5ff26c53c8ce23aa09434e2fd5
PROGRAM = FACT (U13_PROGRAMMED)
PROGRAM_PASS = NO
BOARD_PASS = NOT_EVIDENCED

## FIRST_FAILING_PHASE
4 (basic liveness after fresh program)

## FIRST_FAILING_CASE
CLEAR1 after 15s COM settle, dtr/rts False, 0.3s drain

## LAST_GOOD_EVENT
JTAG End of startup HIGH; bit SHA unique vs ban list including U12 0f774e87…

## FIRST_BAD_EVENT
CLEAR1 n=0 empty UART 3.0s

## EXPECTED
CLEAR ACK 32'hC1EA50A5

## OBSERVED
n=0 raw empty

## ROOT_CAUSE_STATUS
PROVEN_IN_XSIM after board fail (not the inferred-FSM hypothesis).

U13 XSim of prior U12 TB still PASS because T3 did not check w_ready and
never connected product mux `ack_ready = tx_ready && !uart_flush`.

Decisive handshake TB (`tb_u14_handshake.sv`) vs frozen U13 TX:

- FAIL T3 idle flush w_ready=1
- FAIL T4 IDLE+flush w_ready=1
- FAIL T10 product mux ACK nbyte=0 tw=0 ack_valid=0

Mechanism:

flush_hold refuses new TX word
AND w_ready stays 1
AND top `clr_ack_ready = mux_ready && !uart_flush`
AND first cycle uart_flush falls, flush_hold still 1
→ VALID && READY without capture
→ CLEAR advances S_ACK → S_DROP
→ UART emits no token
→ host n=0

PACKAGE TX has no flush_hold leftover, so U8/U11 could emit ACK.

U12/U13 inferred-FSM extract was NOT the board n=0 root cause.

## SMALLEST_NEXT_TEST
U14: w_ready=0 while flush || flush_hold; same handshake TB must PASS T10;
do not patch U13 in place.

## COUNTERS
MAG not applicable (no token)
N0 = 1 (CLEAR1)
TIMEOUT = host 3s empty
PHASE_SHIFT = 0
