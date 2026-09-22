# BOARD_INTERFACE_INVENTORY_CANDIDATE

GOAL_PLAN_PATH: `D:/FPGA/Native_SymAI/docs/audits/20260922_astra_discovery/SINGLE_BOARD_GOAL_PLAN.md`
STATUS: `CUT4_EXPERIENCE_CHANGES_QSTAR_XSIM_SUPPORTED`

Offline candidate for D to review. Not runtime truth. Not a CapabilityDescriptor. Not a Pack page. Generation is NONE. No row was loaded into Pack, T2, or FEM.

## Scope

Rows come from the current pack-visibility XDC, the port list of `arty_a7_pack_gen_vis.sv`, and commented lines in the Arty A7-100 master XDC. Canon sections 5.1 through 5.3, section 12.7, and the primary status list in canon 03 were read as schema and vocabulary. They are not filled records. Query status codes are absent from every row. `capability_class`, `primitive_mask`, and `safety_contract_ref` stay UNKNOWN on every row.

The module declares five ports. `led` is one port, `output logic [3:0] led`, so `led[0]` through `led[3]` are four tokens of that port. `CURRENT_TOP_PORT_COUNT` below counts rows with `current_top_has_port` YES.

## Schema names read, not filled

Class `DESIGN_CANDIDATE`. Values were not copied into the rows. Section 5.2 names `capability_id`, `capability_class`, `instance_id`, `version`, `interface_type`, `primitive_mask`, `input_schema_ref`, `command_schema_ref`, `status_schema_ref`, `fault_schema_ref`, `timing_contract_ref`, `safety_contract_ref`, `executor_index`, `knowledge_pack_dependency_ref`, `flags`, `crc`. Section 5.3 names `MODULE_ID`, `MODULE_VERSION`, `CAPABILITY_CLASS`, `INPUT_SCHEMA`, `OUTPUT_SCHEMA`, `COMMAND_SCHEMA`, `FAULT_SCHEMA`, `TIMING_CONTRACT`, `SAFETY_CONTRACT`, `KNOWLEDGE_PACK_DEPENDENCIES`, `INTEGRITY_ID`. Section 12.7 names a grounding order ending in optional alias attachment. No alias was attached. Section 03 names a query-only status list. Those codes are not interface fields.

## Master lines seen and not rowed

The extraction list is clock, reset, `uart_rx`, `uart_tx`, `led[0]` through `led[3]`, commented `sw`, `btn`, RGB LED, and every commented `ck_io` name. Other commented master `get_ports` lines were read and left without rows. Their runtime presence is not claimed.

Six package pins appear on two commented master lines each. Both names stay in the table below. They are not `CONFLICT` rows: the current XDC does not name those pins, and both lines belong to the same master file. The pairs are `B7` `vaux12_p` line 156 and `ck_a6` line 164, `B6` `vaux12_n` line 157 and `ck_a7` line 165, `E6` `vaux13_p` line 158 and `ck_a8` line 166, `E5` `vaux13_n` line 159 and `ck_a9` line 167, `A4` `vaux14_p` line 160 and `ck_a10` line 168, `A3` `vaux14_n` line 161 and `ck_a11` line 169.

| master_line | token | package_pin |
| --- | --- | --- |
| 47 | `ja[0]` | G13 |
| 48 | `ja[1]` | B11 |
| 49 | `ja[2]` | A11 |
| 50 | `ja[3]` | D12 |
| 51 | `ja[4]` | D13 |
| 52 | `ja[5]` | B18 |
| 53 | `ja[6]` | A18 |
| 54 | `ja[7]` | K16 |
| 57 | `jb[0]` | E15 |
| 58 | `jb[1]` | E16 |
| 59 | `jb[2]` | D15 |
| 60 | `jb[3]` | C15 |
| 61 | `jb[4]` | J17 |
| 62 | `jb[5]` | J18 |
| 63 | `jb[6]` | K15 |
| 64 | `jb[7]` | J15 |
| 67 | `jc[0]` | U12 |
| 68 | `jc[1]` | V12 |
| 69 | `jc[2]` | V10 |
| 70 | `jc[3]` | V11 |
| 71 | `jc[4]` | U14 |
| 72 | `jc[5]` | V14 |
| 73 | `jc[6]` | T13 |
| 74 | `jc[7]` | U13 |
| 77 | `jd[0]` | D4 |
| 78 | `jd[1]` | D3 |
| 79 | `jd[2]` | F4 |
| 80 | `jd[3]` | F3 |
| 81 | `jd[4]` | E2 |
| 82 | `jd[5]` | D2 |
| 83 | `jd[6]` | H2 |
| 84 | `jd[7]` | G2 |
| 131 | `vaux4_n` | C5 |
| 132 | `vaux4_p` | C6 |
| 133 | `vaux5_n` | A5 |
| 134 | `vaux5_p` | A6 |
| 135 | `vaux6_n` | B4 |
| 136 | `vaux6_p` | C4 |
| 137 | `vaux7_n` | A1 |
| 138 | `vaux7_p` | B1 |
| 139 | `vaux15_n` | B2 |
| 140 | `vaux15_p` | B3 |
| 141 | `vaux0_n` | C14 |
| 142 | `vaux0_p` | D14 |
| 145 | `ck_a0` | F5 |
| 146 | `ck_a1` | D8 |
| 147 | `ck_a2` | C7 |
| 148 | `ck_a3` | E7 |
| 149 | `ck_a4` | D7 |
| 150 | `ck_a5` | D5 |
| 156 | `vaux12_p` | B7 |
| 157 | `vaux12_n` | B6 |
| 158 | `vaux13_p` | E6 |
| 159 | `vaux13_n` | E5 |
| 160 | `vaux14_p` | A4 |
| 161 | `vaux14_n` | A3 |
| 164 | `ck_a6` | B7 |
| 165 | `ck_a7` | B6 |
| 166 | `ck_a8` | E6 |
| 167 | `ck_a9` | E5 |
| 168 | `ck_a10` | A4 |
| 169 | `ck_a11` | A3 |
| 172 | `ck_miso` | G1 |
| 173 | `ck_mosi` | H1 |
| 174 | `ck_sck` | F1 |
| 175 | `ck_ss` | C1 |
| 178 | `ck_scl` | L18 |
| 179 | `ck_sda` | M18 |
| 180 | `scl_pup` | A14 |
| 181 | `sda_pup` | A13 |
| 188 | `eth_col` | D17 |
| 189 | `eth_crs` | G14 |
| 190 | `eth_mdc` | F16 |
| 191 | `eth_mdio` | K13 |
| 192 | `eth_ref_clk` | G18 |
| 193 | `eth_rstn` | C16 |
| 194 | `eth_rx_clk` | F15 |
| 195 | `eth_rx_dv` | G16 |
| 196 | `eth_rxd[0]` | D18 |
| 197 | `eth_rxd[1]` | E17 |
| 198 | `eth_rxd[2]` | E18 |
| 199 | `eth_rxd[3]` | G17 |
| 200 | `eth_rxerr` | C17 |
| 201 | `eth_tx_clk` | H16 |
| 202 | `eth_tx_en` | H15 |
| 203 | `eth_txd[0]` | H14 |
| 204 | `eth_txd[1]` | J14 |
| 205 | `eth_txd[2]` | J13 |
| 206 | `eth_txd[3]` | H17 |
| 209 | `qspi_cs` | L13 |
| 210 | `qspi_dq[0]` | K17 |
| 211 | `qspi_dq[1]` | K18 |
| 212 | `qspi_dq[2]` | L14 |
| 213 | `qspi_dq[3]` | M14 |
| 216 | `vsnsvu_n` | B17 |
| 217 | `vsnsvu_p` | B16 |
| 218 | `vsns5v0_n` | B12 |
| 219 | `vsns5v0_p` | C12 |
| 220 | `isns5v0_n` | F14 |
| 221 | `isns5v0_p` | F13 |
| 222 | `isns0v95_n` | A16 |
| 223 | `isns0v95_p` | A15 |

## Rows

| interface_token | package_pin | iostandard | width | direction | current_top_has_port | source_line | epistemic_class | semantic_role | human_alias | expected_effect | readback |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `CLK100MHZ` | E3 | LVCMOS33 | 1 | input | YES | 4 | `IMPLEMENTATION_FACT+BOARD_FACT` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `ck_rst` | C2 | LVCMOS33 | 1 | input | YES | 6 | `IMPLEMENTATION_FACT+BOARD_FACT` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `uart_rx` | A9 | LVCMOS33 | 1 | input | YES | 7 | `CONFLICT` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `uart_txd_in` | A9 | LVCMOS33 | 1 | input | NO | 91 | `CONFLICT` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `uart_tx` | D10 | LVCMOS33 | 1 | output | YES | 8 | `CONFLICT` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `uart_rxd_out` | D10 | LVCMOS33 | 1 | output | NO | 90 | `CONFLICT` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `led[0]` | H5 | LVCMOS33 | 1 | output | YES | 9 | `IMPLEMENTATION_FACT+BOARD_FACT` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `led[1]` | J5 | LVCMOS33 | 1 | output | YES | 10 | `IMPLEMENTATION_FACT+BOARD_FACT` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `led[2]` | T9 | LVCMOS33 | 1 | output | YES | 11 | `IMPLEMENTATION_FACT+BOARD_FACT` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `led[3]` | T10 | LVCMOS33 | 1 | output | YES | 12 | `IMPLEMENTATION_FACT+BOARD_FACT` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `sw[0]` | A8 | LVCMOS33 | 1 | UNKNOWN | NO | 15 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `sw[1]` | C11 | LVCMOS33 | 1 | UNKNOWN | NO | 16 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `sw[2]` | C10 | LVCMOS33 | 1 | UNKNOWN | NO | 17 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `sw[3]` | A10 | LVCMOS33 | 1 | UNKNOWN | NO | 18 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `led0_b` | E1 | LVCMOS33 | 1 | UNKNOWN | NO | 21 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `led0_g` | F6 | LVCMOS33 | 1 | UNKNOWN | NO | 22 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `led0_r` | G6 | LVCMOS33 | 1 | UNKNOWN | NO | 23 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `led1_b` | G4 | LVCMOS33 | 1 | UNKNOWN | NO | 24 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `led1_g` | J4 | LVCMOS33 | 1 | UNKNOWN | NO | 25 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `led1_r` | G3 | LVCMOS33 | 1 | UNKNOWN | NO | 26 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `led2_b` | H4 | LVCMOS33 | 1 | UNKNOWN | NO | 27 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `led2_g` | J2 | LVCMOS33 | 1 | UNKNOWN | NO | 28 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `led2_r` | J3 | LVCMOS33 | 1 | UNKNOWN | NO | 29 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `led3_b` | K2 | LVCMOS33 | 1 | UNKNOWN | NO | 30 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `led3_g` | H6 | LVCMOS33 | 1 | UNKNOWN | NO | 31 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `led3_r` | K1 | LVCMOS33 | 1 | UNKNOWN | NO | 32 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `btn[0]` | D9 | LVCMOS33 | 1 | UNKNOWN | NO | 41 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `btn[1]` | C9 | LVCMOS33 | 1 | UNKNOWN | NO | 42 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `btn[2]` | B9 | LVCMOS33 | 1 | UNKNOWN | NO | 43 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `btn[3]` | B8 | LVCMOS33 | 1 | UNKNOWN | NO | 44 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `ck_io0` | V15 | LVCMOS33 | 1 | UNKNOWN | NO | 94 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `ck_io1` | U16 | LVCMOS33 | 1 | UNKNOWN | NO | 95 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `ck_io2` | P14 | LVCMOS33 | 1 | UNKNOWN | NO | 96 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `ck_io3` | T11 | LVCMOS33 | 1 | UNKNOWN | NO | 97 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `ck_io4` | R12 | LVCMOS33 | 1 | UNKNOWN | NO | 98 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `ck_io5` | T14 | LVCMOS33 | 1 | UNKNOWN | NO | 99 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `ck_io6` | T15 | LVCMOS33 | 1 | UNKNOWN | NO | 100 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `ck_io7` | T16 | LVCMOS33 | 1 | UNKNOWN | NO | 101 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `ck_io8` | N15 | LVCMOS33 | 1 | UNKNOWN | NO | 102 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `ck_io9` | M16 | LVCMOS33 | 1 | UNKNOWN | NO | 103 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `ck_io10` | V17 | LVCMOS33 | 1 | UNKNOWN | NO | 104 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `ck_io11` | U18 | LVCMOS33 | 1 | UNKNOWN | NO | 105 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `ck_io12` | R17 | LVCMOS33 | 1 | UNKNOWN | NO | 106 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `ck_io13` | P17 | LVCMOS33 | 1 | UNKNOWN | NO | 107 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `ck_io26` | U11 | LVCMOS33 | 1 | UNKNOWN | NO | 110 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `ck_io27` | V16 | LVCMOS33 | 1 | UNKNOWN | NO | 111 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `ck_io28` | M13 | LVCMOS33 | 1 | UNKNOWN | NO | 112 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `ck_io29` | R10 | LVCMOS33 | 1 | UNKNOWN | NO | 113 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `ck_io30` | R11 | LVCMOS33 | 1 | UNKNOWN | NO | 114 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `ck_io31` | R13 | LVCMOS33 | 1 | UNKNOWN | NO | 115 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `ck_io32` | R15 | LVCMOS33 | 1 | UNKNOWN | NO | 116 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `ck_io33` | P15 | LVCMOS33 | 1 | UNKNOWN | NO | 117 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `ck_io34` | R16 | LVCMOS33 | 1 | UNKNOWN | NO | 118 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `ck_io35` | N16 | LVCMOS33 | 1 | UNKNOWN | NO | 119 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `ck_io36` | N14 | LVCMOS33 | 1 | UNKNOWN | NO | 120 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `ck_io37` | U17 | LVCMOS33 | 1 | UNKNOWN | NO | 121 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `ck_io38` | T18 | LVCMOS33 | 1 | UNKNOWN | NO | 122 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `ck_io39` | R18 | LVCMOS33 | 1 | UNKNOWN | NO | 123 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `ck_io40` | P18 | LVCMOS33 | 1 | UNKNOWN | NO | 124 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `ck_io41` | N17 | LVCMOS33 | 1 | UNKNOWN | NO | 125 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |
| `ck_ioa` | M17 | LVCMOS33 | 1 | UNKNOWN | NO | 184 | `VENDOR_SPEC` | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |

## Provenance

- `CLK100MHZ` E3 `D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.xdc`:4 `IMPLEMENTATION_FACT+BOARD_FACT`. Port input logic CLK100MHZ at D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv:7. Current XDC line 4 assigns PACKAGE_PIN E3 IOSTANDARD LVCMOS33. Master XDC line 11 comments the same get_ports name and the same package pin. Master comment text: #set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { CLK100MHZ }]; #IO_L12P_T1_MRCC_35 Sch=gclk[100]. That comment is not a human_alias. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the cited file no longer contains that port or pin.
- `ck_rst` C2 `D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.xdc`:6 `IMPLEMENTATION_FACT+BOARD_FACT`. Port input logic ck_rst at D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv:8. Current XDC line 6 assigns PACKAGE_PIN C2 IOSTANDARD LVCMOS33. Master XDC line 185 comments the same get_ports name and the same package pin. Master comment text: #set_property -dict { PACKAGE_PIN C2    IOSTANDARD LVCMOS33 } [get_ports { ck_rst }]; #IO_L16P_T2_35 Sch=ck_rst. That comment is not a human_alias. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the cited file no longer contains that port or pin.
- `uart_rx` A9 `D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.xdc`:7 `CONFLICT`. CONFLICT. Current XDC line 7 names PACKAGE_PIN A9 as uart_rx. Master XDC line 91 names the same package pin as uart_txd_in. Rows are not merged. Port input logic uart_rx at D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv:9. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the cited file no longer contains that port or pin. The paired master row is invalidated if that master XDC line changed or was never uncommented in a current top.
- `uart_txd_in` A9 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:91 `CONFLICT`. CONFLICT. Commented master XDC line 91 names PACKAGE_PIN A9 as uart_txd_in. Current XDC line 7 names the same package pin as uart_rx. Master NOTE line 88 states a direction for this port name. Direction is that stated word only. This name is not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `uart_tx` D10 `D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.xdc`:8 `CONFLICT`. CONFLICT. Current XDC line 8 names PACKAGE_PIN D10 as uart_tx. Master XDC line 90 names the same package pin as uart_rxd_out. Rows are not merged. Port output logic uart_tx at D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv:10. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the cited file no longer contains that port or pin. The paired master row is invalidated if that master XDC line changed or was never uncommented in a current top.
- `uart_rxd_out` D10 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:90 `CONFLICT`. CONFLICT. Commented master XDC line 90 names PACKAGE_PIN D10 as uart_rxd_out. Current XDC line 8 names the same package pin as uart_tx. Master NOTE line 87 states a direction for this port name. Direction is that stated word only. This name is not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `led[0]` H5 `D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.xdc`:9 `IMPLEMENTATION_FACT+BOARD_FACT`. Port output logic [3:0] led at D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv:11. Current XDC line 9 assigns PACKAGE_PIN H5 IOSTANDARD LVCMOS33. Master XDC line 35 comments the same get_ports name and the same package pin. Master comment text: #set_property -dict { PACKAGE_PIN H5    IOSTANDARD LVCMOS33 } [get_ports { led[0] }]; #IO_L24N_T3_35 Sch=led[4]. That comment is not a human_alias. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the cited file no longer contains that port or pin.
- `led[1]` J5 `D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.xdc`:10 `IMPLEMENTATION_FACT+BOARD_FACT`. Port output logic [3:0] led at D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv:11. Current XDC line 10 assigns PACKAGE_PIN J5 IOSTANDARD LVCMOS33. Master XDC line 36 comments the same get_ports name and the same package pin. Master comment text: #set_property -dict { PACKAGE_PIN J5    IOSTANDARD LVCMOS33 } [get_ports { led[1] }]; #IO_25_35 Sch=led[5]. That comment is not a human_alias. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the cited file no longer contains that port or pin.
- `led[2]` T9 `D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.xdc`:11 `IMPLEMENTATION_FACT+BOARD_FACT`. Port output logic [3:0] led at D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv:11. Current XDC line 11 assigns PACKAGE_PIN T9 IOSTANDARD LVCMOS33. Master XDC line 37 comments the same get_ports name and the same package pin. Master comment text: #set_property -dict { PACKAGE_PIN T9    IOSTANDARD LVCMOS33 } [get_ports { led[2] }]; #IO_L24P_T3_A01_D17_14 Sch=led[6]. That comment is not a human_alias. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the cited file no longer contains that port or pin.
- `led[3]` T10 `D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.xdc`:12 `IMPLEMENTATION_FACT+BOARD_FACT`. Port output logic [3:0] led at D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv:11. Current XDC line 12 assigns PACKAGE_PIN T10 IOSTANDARD LVCMOS33. Master XDC line 38 comments the same get_ports name and the same package pin. Master comment text: #set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33 } [get_ports { led[3] }]; #IO_L24N_T3_A00_D16_14 Sch=led[7]. That comment is not a human_alias. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the cited file no longer contains that port or pin.
- `sw[0]` A8 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:15 `VENDOR_SPEC`. Commented master XDC line 15. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `sw[1]` C11 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:16 `VENDOR_SPEC`. Commented master XDC line 16. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `sw[2]` C10 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:17 `VENDOR_SPEC`. Commented master XDC line 17. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `sw[3]` A10 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:18 `VENDOR_SPEC`. Commented master XDC line 18. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `led0_b` E1 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:21 `VENDOR_SPEC`. Commented master XDC line 21. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `led0_g` F6 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:22 `VENDOR_SPEC`. Commented master XDC line 22. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `led0_r` G6 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:23 `VENDOR_SPEC`. Commented master XDC line 23. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `led1_b` G4 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:24 `VENDOR_SPEC`. Commented master XDC line 24. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `led1_g` J4 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:25 `VENDOR_SPEC`. Commented master XDC line 25. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `led1_r` G3 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:26 `VENDOR_SPEC`. Commented master XDC line 26. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `led2_b` H4 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:27 `VENDOR_SPEC`. Commented master XDC line 27. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `led2_g` J2 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:28 `VENDOR_SPEC`. Commented master XDC line 28. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `led2_r` J3 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:29 `VENDOR_SPEC`. Commented master XDC line 29. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `led3_b` K2 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:30 `VENDOR_SPEC`. Commented master XDC line 30. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `led3_g` H6 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:31 `VENDOR_SPEC`. Commented master XDC line 31. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `led3_r` K1 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:32 `VENDOR_SPEC`. Commented master XDC line 32. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `btn[0]` D9 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:41 `VENDOR_SPEC`. Commented master XDC line 41. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `btn[1]` C9 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:42 `VENDOR_SPEC`. Commented master XDC line 42. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `btn[2]` B9 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:43 `VENDOR_SPEC`. Commented master XDC line 43. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `btn[3]` B8 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:44 `VENDOR_SPEC`. Commented master XDC line 44. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `ck_io0` V15 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:94 `VENDOR_SPEC`. Commented master XDC line 94. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `ck_io1` U16 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:95 `VENDOR_SPEC`. Commented master XDC line 95. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `ck_io2` P14 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:96 `VENDOR_SPEC`. Commented master XDC line 96. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `ck_io3` T11 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:97 `VENDOR_SPEC`. Commented master XDC line 97. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `ck_io4` R12 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:98 `VENDOR_SPEC`. Commented master XDC line 98. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `ck_io5` T14 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:99 `VENDOR_SPEC`. Commented master XDC line 99. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `ck_io6` T15 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:100 `VENDOR_SPEC`. Commented master XDC line 100. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `ck_io7` T16 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:101 `VENDOR_SPEC`. Commented master XDC line 101. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `ck_io8` N15 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:102 `VENDOR_SPEC`. Commented master XDC line 102. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `ck_io9` M16 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:103 `VENDOR_SPEC`. Commented master XDC line 103. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `ck_io10` V17 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:104 `VENDOR_SPEC`. Commented master XDC line 104. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `ck_io11` U18 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:105 `VENDOR_SPEC`. Commented master XDC line 105. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `ck_io12` R17 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:106 `VENDOR_SPEC`. Commented master XDC line 106. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `ck_io13` P17 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:107 `VENDOR_SPEC`. Commented master XDC line 107. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `ck_io26` U11 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:110 `VENDOR_SPEC`. Commented master XDC line 110. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `ck_io27` V16 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:111 `VENDOR_SPEC`. Commented master XDC line 111. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `ck_io28` M13 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:112 `VENDOR_SPEC`. Commented master XDC line 112. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `ck_io29` R10 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:113 `VENDOR_SPEC`. Commented master XDC line 113. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `ck_io30` R11 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:114 `VENDOR_SPEC`. Commented master XDC line 114. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `ck_io31` R13 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:115 `VENDOR_SPEC`. Commented master XDC line 115. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `ck_io32` R15 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:116 `VENDOR_SPEC`. Commented master XDC line 116. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `ck_io33` P15 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:117 `VENDOR_SPEC`. Commented master XDC line 117. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `ck_io34` R16 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:118 `VENDOR_SPEC`. Commented master XDC line 118. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `ck_io35` N16 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:119 `VENDOR_SPEC`. Commented master XDC line 119. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `ck_io36` N14 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:120 `VENDOR_SPEC`. Commented master XDC line 120. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `ck_io37` U17 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:121 `VENDOR_SPEC`. Commented master XDC line 121. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `ck_io38` T18 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:122 `VENDOR_SPEC`. Commented master XDC line 122. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `ck_io39` R18 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:123 `VENDOR_SPEC`. Commented master XDC line 123. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `ck_io40` P18 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:124 `VENDOR_SPEC`. Commented master XDC line 124. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `ck_io41` N17 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:125 `VENDOR_SPEC`. Commented master XDC line 125. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.
- `ck_ioa` M17 `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`:184 `VENDOR_SPEC`. Commented master XDC line 184. Not a port of D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv. Width is the single PACKAGE_PIN on that line. Direction is not stated on that line. capability_class=UNKNOWN. primitive_mask=UNKNOWN. safety_contract_ref=UNKNOWN. generation=NONE. Invalidation: the master XDC line changed or was never uncommented in a current top.

Rows with `current_top_has_port` YES cite `arty_a7_pack_gen_vis.xdc`. Rows with NO cite `Arty-A7-100-Master.xdc`. `VENDOR_ONLY_COUNT` counts rows whose class is `VENDOR_SPEC`. The commented UART names are inside `CONFLICT_COUNT` instead. `CONFLICT_COUNT` counts rows: package pins `A9` and `D10` produce four rows.

```text
ROW_COUNT: 61
CURRENT_TOP_PORT_COUNT: 8
VENDOR_ONLY_COUNT: 51
CONFLICT_COUNT: 4
UNKNOWN_ROLE_COUNT: 61
READY_FOR_D_REVIEW: YES
RUNTIME_IMPORT: NO
```
