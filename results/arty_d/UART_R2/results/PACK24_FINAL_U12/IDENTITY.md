# UART_R2_U12_PACK24_FINAL — identity freeze

TASK: CLOSE_M1_PACK24_AND_PREPARE_M2
OWNER: AGENT_D
RUN_ID: 20260918T054400Z
CLASS: UART_R2_U12_PACK24_FINAL CANDIDATE
PROGRAM_PASS: NO
BOARD_PASS: NOT_EVIDENCED
PACK_ABI_24_24_PASS: NO
TIMING_PASS: NO
MIG_PASS: NO

## Git freeze (do not reset)

Native_SymAI:
- toplevel: `D:/FPGA/Native_SymAI`
- HEAD: `69f9dddb0b7d5747ea0949a4737c27e9299ee37f`
- branch: `main`
- D:/FPGA is not a git repo
- Local U8/U10/U11 kept. GitHub main not used as reset target.

## U12 composition (no second rewrite)

| Piece | Source | SHA256 |
|---|---|---|
| RX | `UART_R2/u11/uart_rx_word.sv` | `6a9ac5272bc3f1c1a4c7b93b03b68f01fbb8dcb6830ff5a143b3782474924ae9` |
| TX | `UART_R2/u10/uart_tx_word.sv` | `5e11b03202935c88e20ce7d27ef405fdfefdaef69e403a644ef1a1e236ab1a36` |
| CLEAR | `UART_R2/u8/pack_debug_clear.sv` | `e9ec37513ce9581b92ec1954b338a110680051d7f24afb19d4ef91d5153c327e` |
| CDC | PACKAGE `word_cdc32.sv` | `8e356cf46b97100c5437c247da044c8964924bcfc4d814ccbf32e40892c310a3` |
| FIFO | PACKAGE `word_fifo32.sv` | `5d35ad1eac6bf259168a7e8e8137f4404abb9064aafddef02c3e858e221e7363` |
| pack_loader | PACKAGE | `58302aec460323059facf5856ee2cbdedc0c489506ac911e20b299c9a8c1a35a` |
| pack_mig_bind | PACKAGE | `581777cfcbcd1cdf71d3c5f383ec8b93fa2e41281d9c3ef554738a916d1f060f` |
| mig_ui_mux | PACKAGE | `28ef597ed36d20ee76785b94bc235aaef28f342262101a7a48ac7e8157a096d2` |
| product top | `arty_a7_r2_top_m4_mig_candidate.sv` | `382ac125eec20578101a62b88ffe4be4baab408ce188a2b6550742ae0362cf40` |
| XDC mig | `arty_a7_mig.xdc` | `6ef498133d3aafad56bb40e6c28dcf980397c297fa83188ed42e61f5ee19801b` |
| XDC cdc | `arty_a7_mig_cdc.xdc` | `0f3bd8c417b2319ceacadee25c1029ee01f419619a3b25aea1411f6977033d87` |
| XDC clear | `arty_a7_mig_clear_cdc.xdc` | `81381148600f96d08f9832d6c5b576ad318ec2060c085ed46b7c3035bda261a4` |
| Pack24 gold py | `pack_abi24_gold.py` | `2986c354acac0f09af5ec678adbeeeb905b8b557d94158fa594a80d85c8d67f3` |
| Prior U11 bit | `uart_r2_u11_candidate.bit` | `713ea856baa9f36bdfecad0eaa356c4f3be872191d2820845bcd4f8f90e55b0e` |
| Prior U8 bit | `uart_r2_u8_candidate.bit` | `2bc835fd28174051dc2015f7bacd8ad5c919a5a2ce9c60695fe0530b405d6098` |

Diff vs U11 programmed bit: **TX only**. U11 synth read PACKAGE `uart_tx_word.sv` SHA256 `805344670271169ea3312c175d123eacbc7b9be8d2436b0171baf82d7b076e33` (flush aborts to IDLE). U12 reads U10 non-aborting flush. RX U11 / CLEAR U8 / CDC PACKAGE unchanged.

## Ban list (do not program)

- H `cf62102f21bd146976779e45dec77f912790da1000327fbc505941cdef4e7fc9`
- M4+mig `f6a6091fccab5bdb331932195d34c984f3101cdf52d3959c172706b33ba368d7`
- U8 `2bc835fd…`
- U9 `66fe2bd739b31f4a62883e8d21d247ebe12d04c3b0b961af523733323ef1da88`
- U9b `4ab8e14203c7c1bafd32862da055592ba12fbb361b7b74f307b7cbd284a227a1`
- U11 `713ea856…`

## Closed vs open at freeze

- MAG / 0200015a: CLOSED (cdc_rst not through S_DROP)
- COM-open partial RX: U11 mitigation exists
- Repeated pack after CLEAR n=0: OPEN — U12 tests G3 TX flush abort
