#include <stdint.h>

typedef struct __attribute__((packed)) {
    uint32_t fifo_depth : 16;
    uint32_t ch_num     : 8;
    uint32_t reg_num    : 8;
} signal_gen_param_reg_t;

typedef struct __attribute__((packed)) {
    uint32_t fifo_cnt   : 16;
    uint32_t fifo_empty : 1;
    uint32_t fifo_full  : 1;
    uint32_t ampl_ovf   : 2;
    uint32_t rsrvd      : 12;
} signal_gen_status_reg_t;

typedef struct __attribute__((packed)) {
    uint32_t dds_reset  : 16;
    uint32_t dds_enable : 16;
} signal_gen_control_reg_t;

typedef struct __attribute__((packed)) {
    uint32_t ampl       : 16;
    uint32_t round_type : 1;
    uint32_t rsrvd      : 15;
} signal_gen_ampl_reg_t;

typedef struct __attribute__((packed)) {
    uint32_t select : 8;
    uint32_t rsrvd  : 24;
} signal_gen_select_reg_t;

typedef union {
    signal_gen_control_reg_t control; // 0
    uint32_t                 poff;    // 4
    uint32_t                 pinc;    // 8
    signal_gen_ampl_reg_t    ampl;    // 12
    signal_gen_select_reg_t  select;  // 16
    signal_gen_status_reg_t  status;  // 20
    signal_gen_param_reg_t   param;   // 24
    uint32_t                 data;
} signal_gen_regs_t;
