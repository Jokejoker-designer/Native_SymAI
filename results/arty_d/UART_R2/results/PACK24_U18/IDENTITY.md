# UART_R2_U18 identity — CLOSE_M1_PACK24_AND_PREPARE_M2

OWNER: AGENT_D
IDENTITY: UART_R2_U18_PACK24_CANDIDATE
LiteX/NSL: NOT ADOPTED (SoC/LiteDRAM/Ethernet/VHDL HAL would reopen UART/MIG path; Ethernet forbidden).

## Git freeze (do not reset)

- Native_SymAI toplevel: D:/FPGA/Native_SymAI
- HEAD: 69f9dddb0b7d5747ea0949a4737c27e9299ee37f
- branch: main
- D:/FPGA is not a git repo. Local UART_R2 U8/U10/U11/U17 kept.

## U18 delta (only)

pack_debug_clear uart_flush = S_CDC | S_QUIET | S_DROP | S_DROP_B
cdc_rst unchanged U8: S_CDC | S_QUIET | S_ACK
No S_REQ flush (U16 FAIL). No S_ACK flush (ACK in flight).
Product top overlay reused from U17 (TX CDC B ~clr_ui_req).

## SHA256 before U18 bit

| artifact | sha256 |
|---|---|
| uart_rx_word U11 | 6a9ac5272bc3f1c1a4c7b93b03b68f01fbb8dcb6830ff5a143b3782474924ae9 |
| uart_tx_word U14 | 03d05d6e4d844710106f51c66b2cc32041dcb1dbaf0ff95f05495f6aa6552d79 |
| pack_debug_clear U17 (frozen) | 61accbf204e4ff0debc17aab63664ff4eebd8ac670d0de55d5a833f3ab1ca124 |
| pack_debug_clear U18 | 0847962fe199653ca9410606b8421dfde27f0847fa0c2f428df7d7ba71efd18c |
| product top U17 overlay | e360df045fa8aaad670a777f8f79596e9833d072f51379fefc8d6957106aadfa |
| pack_loader | 58302aec460323059facf5856ee2cbdedc0c489506ac911e20b299c9a8c1a35a |
| pack_mig_bind | 581777cfcbcd1cdf71d3c5f383ec8b93fa2e41281d9c3ef554738a916d1f060f |
| mig_ui_mux | 28ef597ed36d20ee76785b94bc235aaef28f342262101a7a48ac7e8157a096d2 |
| word_cdc32 | 8e356cf46b97100c5437c247da044c8964924bcfc4d814ccbf32e40892c310a3 |
| word_fifo32 | 5d35ad1eac6bf259168a7e8e8137f4404abb9064aafddef02c3e858e221e7363 |
| pack_abi24_gold.py | 2986c354acac0f09af5ec678adbeeeb905b8b557d94158fa594a80d85c8d67f3 |
| U17 bit (frozen FAIL_BOARD) | 7be4e9df3666e7cac78d12f311b6fc73057fcca19cd0e945ea4665d43098f3a4 |

H identity, FE256 freeze, Agent C hashes: not modified.
PROGRAM_PASS=NO BOARD_PASS=NOT_EVIDENCED PACK_ABI_24_24_PASS=NO TIMING_PASS=NO
