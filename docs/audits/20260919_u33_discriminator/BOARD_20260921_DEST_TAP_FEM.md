# dest TAP ead830ae + FEM persist (pointer)

Unique dirs (do not overlay):

- `docs/audits/20260921_rkb_dest_tap_ead830ae/` dest TAP UART dest-causal CANDIDATE
- `docs/audits/20260921_fem_persist_xsim_restore/` FEM persist XSim + ead830ae restore
- `docs/audits/20260921_fem_persist_bit_1db38691/` unique persist BIT_OK PROGRAMMED + no-FREP smoke
- `docs/audits/20260921_fem_persist_legal_compact_1db38691/` legal compact UART CANDIDATE
- `docs/audits/20260921_fem_persist_closure_1db38691/` closure freeze CONTRADICTION_FOUND=NO
- `docs/audits/20260921_fem_qstar_causal_design/` Q* A/B/A/B DESIGN_LOCKED (historical SHA NOT_ASSIGNED)
- `docs/audits/20260921_fem_qstar_abab_xsim/` Q* A/B/A/B PASS_XSIM greedy 0,1,0,1
- `docs/audits/20260921_fem_qstar_causal_bit_3ccd03f8/` unique Q* causal BIT_OK `3ccd03f8…`
- `docs/audits/20260922_fem_qstar_causal_uart_3ccd03f8/` PROGRAMMED EOS HIGH + UART QOBS CANDIDATE
- `docs/audits/20260922_fem_qstar_abab_closure_3ccd03f8/` Q* A/B/A/B closure freeze SUPPORTED
- `docs/audits/20260922_fem_spear_semantic_52b923a6/` SPEAR rank UART CANDIDATE `52b923a6…`
- `docs/audits/20260922_fem_spear_qstar_8b632b4a/` SPEAR→Q* UART CANDIDATE `8b632b4a…`
- `docs/audits/20260922_astra_discovery/` ASTRA query-status vs action-precheck split
- `docs/audits/20260922_astra_action_precheck_cf246499/` ASTRA precheck UART CANDIDATE `cf246499…`
- `docs/audits/20260922_integrated_causal_xsim/` integrated chain PASS_XSIM `e112783e…`
- `docs/audits/20260922_integrated_causal_bit_435bdc88/` integrated BIT_OK `435bdc88…` PROGRAM=NO
- `docs/audits/20260922_action_product_44546b43/` action product UART CANDIDATE `44546b43…`
- `docs/audits/20260922_pack_gen_vis_90220cb5/` pack-gen-vis UART CANDIDATE `90220cb5…`
- `docs/audits/20260922_single_board_goal_xsim/` goal XSim CUT16 plant `f66a75fb…` BOARD_BUILT=NO

- `docs/audits/20260923_ja_loopback_e2d97151/` JA UART candidate `e2d97151…` open `00000101` adjacent `01010001`
- `docs/audits/20260923_sr48_and_proof_audit/` 48-byte header XSim, ANSWER not emitted

- `docs/audits/20260923_proof_r1_45cd7213/` proof R1 UART open `45cd7213…` words `00020100 d1000001 00000041`

SRAM last programmed `45cd7213…` (2026-09-23; live hash NOT_READ). Prior JA file `e2d97151…` still on disk. Prior `90220cb5…` (14:34+07). Action bit `44546b43…` earlier the same day. Integrated bit `435bdc88…` BIT_OK **not programmed**. Persist **file** keep `1db38691…`. dest TAP bit file on disk **UNTOUCHED**. **8/8 NOT_RUN.** **PROGRAM_PASS=NO.** **PACK_ABI_24_24_PASS=NO.** **FEM_PERSIST_PASS=NO.** **BOARD_PASS=NO.** **ASTRA_PASS=NO.** **MIG_PASS=NO.** No `.bit` in git.
