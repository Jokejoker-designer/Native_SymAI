function integer pa24_fopen_mem;
  input integer rec;
  begin
    case (rec)
      0: pa24_fopen_mem = $fopen("out/PA24-V-01.mem", "r");
      1: pa24_fopen_mem = $fopen("out/PA24-V-02.mem", "r");
      2: pa24_fopen_mem = $fopen("out/PA24-V-03.mem", "r");
      3: pa24_fopen_mem = $fopen("out/PA24-V-04.mem", "r");
      4: pa24_fopen_mem = $fopen("out/PA24-S-01.mem", "r");
      5: pa24_fopen_mem = $fopen("out/PA24-S-02.mem", "r");
      6: pa24_fopen_mem = $fopen("out/PA24-S-03.mem", "r");
      7: pa24_fopen_mem = $fopen("out/PA24-S-04.mem", "r");
      8: pa24_fopen_mem = $fopen("out/PA24-A-01.mem", "r");
      9: pa24_fopen_mem = $fopen("out/PA24-A-02.mem", "r");
      10: pa24_fopen_mem = $fopen("out/PA24-A-03.mem", "r");
      11: pa24_fopen_mem = $fopen("out/PA24-A-04.mem", "r");
      12: pa24_fopen_mem = $fopen("out/PA24-C-01.mem", "r");
      13: pa24_fopen_mem = $fopen("out/PA24-C-02.mem", "r");
      14: pa24_fopen_mem = $fopen("out/PA24-C-03.mem", "r");
      15: pa24_fopen_mem = $fopen("out/PA24-C-04.mem", "r");
      16: pa24_fopen_mem = $fopen("out/PA24-R-01.mem", "r");
      17: pa24_fopen_mem = $fopen("out/PA24-R-02.mem", "r");
      18: pa24_fopen_mem = $fopen("out/PA24-R-03.mem", "r");
      19: pa24_fopen_mem = $fopen("out/PA24-R-04.mem", "r");
      20: pa24_fopen_mem = $fopen("out/PA24-G-01.mem", "r");
      21: pa24_fopen_mem = $fopen("out/PA24-G-02.mem", "r");
      22: pa24_fopen_mem = $fopen("out/PA24-G-03.mem", "r");
      23: pa24_fopen_mem = $fopen("out/PA24-G-04.mem", "r");
      default: pa24_fopen_mem = 0;
    endcase
  end
endfunction
