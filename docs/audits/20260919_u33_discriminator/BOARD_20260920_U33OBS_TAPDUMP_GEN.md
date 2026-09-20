# U33OBS TAP dump GOLD four-AND — PASS_XSIM only (2026-09-20)

Not silicon. Not overlay U33/H/U33TAP. Not PACK_ABI_24_24_PASS. READY_TO_PROGRAM=NO.
Does not legalize dump-SOF route WNS −1.516. Re-synth gen+XDC was IN_PROGRESS at publish.

`tb_u33obs_tapdump` `$finish` **6690235 ns**. Display log sha256 `61e2e3e176959a1351b056c3bb8df318c2d480adb13b3ecfe1c79463c6d027eb`. Full xsim log sha256 `e21ade30016791363cbce5676198f970ba3daeae7b2665cfcf988f713526eeb6`.

| Cell | TAP1 | gen / notes |
|---|---|---|
| leftover MAG CLASS_A | `31504154` | p0=p1=BEGIN; `before=00000000 after=00000000` (no fake flip) |
| DUMP-without-NAK | `31504154` | `44554D50`; `nak=0` `fr=3`; dedicated CDC |
| GOLD DUMP gen | `31504154` | `stat=470f0002` `before=ffffffff after=0000ffff` four-AND Pack-owner COMMIT |

`pack_obs_gen.sv` sha256 `c4c79eb8088d08bf802c498c358f04be9c419b5a059d67da83236e91e4427b61` (was `5a43f604…` on GitHub). Snapshots are S_COMMIT then next UI cycle, not two idle dumps across CLEAR/epoch.

Expanded `u33obs_tap_cdc.xdc` sha256 `e0dd3327d7099de87babc2d305237a1a1b50eb51417468235eaaeabc64bcdc81` names obs_ctrl/nak/cal/freeze 2FF. **Not applied to dump-SOF DCP `d3e26d3d…`.** Next synth/impl only.

Do not program dump-SOF. Do not stamp TIMING_PASS from this XSim.
