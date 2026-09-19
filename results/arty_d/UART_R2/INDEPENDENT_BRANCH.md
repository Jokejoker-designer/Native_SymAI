# UART_R2 independent identity — do not mix with other branches

OUT_ONLY = D:/FPGA/arty_d/UART_R2/build
BIT_NAME = uart_r2_u2_candidate.bit
PROGRAM_TXT = D:/FPGA/arty_d/UART_R2/build/PROGRAM.txt

NEVER_WRITE:
- D:/FPGA/arty_d/m4_mig/**
- D:/FPGA/arty_d/m4_mig_clear/**
- D:/FPGA/arty_d/H_OBS/**
- D:/FPGA/arty_d/H_ILA_A/**
- D:/FPGA/arty_d/hold_r2/**
- freeze DCPs (858d0e99 / f25fdf64 / b48b7c88)
- UART_R2/frozen/**

This branch is NOT identity H (cf62102f).
This branch is NOT historical M4+mig (f6a6091f).
PROGRAM_PASS=NO  BOARD_PASS=NOT_EVIDENCED
