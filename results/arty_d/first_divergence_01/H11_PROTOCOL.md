# H11 same-case repeat — V-04 JP2_REMOVED

HYPOTHESIS: one known-good PACK is stable after CLEAR ACK; mute needs 24-case diversity.
CONTROL: Identity H `cf62102f`, PA24-V-04.mem, 115200, JP2 OWNER_REPORTED_REMOVED, fresh program, host `uart_h18_stamp.py` (frozen campaign host not edited).
SINGLE_CHANGED_VARIABLE: repetition index i. No RTL.
EXPECTED_IF_TRUE: GOLD every PACK until an external class change.
EXPECTED_IF_FALSE: GOLD/UNS/MAG/NO_BYTE mix on the same .mem.
MEASURED_RESULT (2026-09-17T11:41+07):
  i=0 CLEAR ACK then PACK UNSUP 0200075a t_first=0.063s
  i=1 CLEAR ACK then PACK GOLD 010000a5
  i=2 CLEAR ACK then PACK MAG 0200015a
  i=3 CLEAR ACK then PACK GOLD
  i=4 CLEAR UNSUP 0200075a (no PACK)
  i=5 CLEAR NO_BYTE n=0 dt=3.04s STOP
FIRST_DIVERGENCE: i=0 PACK WRONG_VALID UNSUP after ACK (CLASS A). CLASS B at i=5.
NEXT_ACTION: ILA-A on this 6-step sequence. New debug bitstream needs owner auth. No Identity I product bit.
STOP_CONDITION: sequence logged. Done.

H11_STATUS=SAME_CASE_UNSTABLE_CLASS_A_THEN_CLASS_B
jsonl sha256 see H11_V04/H11_V04.json
