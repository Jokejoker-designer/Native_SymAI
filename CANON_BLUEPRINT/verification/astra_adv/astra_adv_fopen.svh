function integer aa_fopen_mem;
  input integer rec;
  begin
    case (rec)
      0: aa_fopen_mem = $fopen("out/AA-ILLEGAL-00.mem", "r");
      1: aa_fopen_mem = $fopen("out/AA-NS-ST22.mem", "r");
      2: aa_fopen_mem = $fopen("out/AA-NS-ST55.mem", "r");
      3: aa_fopen_mem = $fopen("out/AA-TIE-01.mem", "r");
      4: aa_fopen_mem = $fopen("out/AA-DESC-01.mem", "r");
      5: aa_fopen_mem = $fopen("out/AA-ANS-PROOF0.mem", "r");
      6: aa_fopen_mem = $fopen("out/AA-INC-BUDGET.mem", "r");
      7: aa_fopen_mem = $fopen("out/AA-UNK-ABSENT.mem", "r");
      8: aa_fopen_mem = $fopen("out/AA-CONFLICT-01.mem", "r");
      9: aa_fopen_mem = $fopen("out/AA-ANS-DIAMOND.mem", "r");
      10: aa_fopen_mem = $fopen("out/AA-CAND-01.mem", "r");
      11: aa_fopen_mem = $fopen("out/AA-NS-ST80.mem", "r");
      12: aa_fopen_mem = $fopen("out/AA-TXN-ECHO.mem", "r");
      13: aa_fopen_mem = $fopen("out/AA-QTRUNC-01.mem", "r");
      14: aa_fopen_mem = $fopen("out/AA-QCRC-01.mem", "r");
      15: aa_fopen_mem = $fopen("out/AA-STALE-GEN.mem", "r");
      16: aa_fopen_mem = $fopen("out/AA-PROTO-01.mem", "r");
      17: aa_fopen_mem = $fopen("out/AA-REW-DUP.mem", "r");
      18: aa_fopen_mem = $fopen("out/AA-REW-ID.mem", "r");
      19: aa_fopen_mem = $fopen("out/AA-KINV-01.mem", "r");
      20: aa_fopen_mem = $fopen("out/AA-FEM-CRC.mem", "r");
      default: aa_fopen_mem = 0;
    endcase
  end
endfunction
