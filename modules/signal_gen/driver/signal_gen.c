#include "signal_gen.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "xil_printf.h"
#include "xil_io.h"
#include "xparameters.h"
#include "sleep.h"

void signal_gen_read_regs(uintptr_t base_addr) {
    signal_gen_regs_t signal_gen_regs;

    signal_gen_regs.data = Xil_In32(base_addr);
    xil_printf("[SIGNAL_GEN] : dds_enable = %d\n", signal_gen_regs.control.dds_enable);
    xil_printf("[SIGNAL_GEN] : dds_reset  = %d\n", signal_gen_regs.control.dds_reset);

    signal_gen_regs.data = Xil_In32(base_addr + 20);
    xil_printf("[SIGNAL_GEN] : fifo_empty = %d\n", signal_gen_regs.status.fifo_empty);
    xil_printf("[SIGNAL_GEN] : fifo_full  = %d\n", signal_gen_regs.status.fifo_full);
    xil_printf("[SIGNAL_GEN] : fifo_cnt   = %d\n", signal_gen_regs.status.fifo_cnt);
    xil_printf("[SIGNAL_GEN] : ampl_ovf   = %d\n", signal_gen_regs.status.ampl_ovf);

    signal_gen_regs.data = Xil_In32(base_addr + 24);
    xil_printf("[SIGNAL_GEN] : ch_num     = %d\n", signal_gen_regs.param.ch_num);
    xil_printf("[SIGNAL_GEN] : reg_num    = %d\n", signal_gen_regs.param.reg_num);
    xil_printf("[SIGNAL_GEN] : fifo_depth = %d\n", signal_gen_regs.param.fifo_depth);

    uint8_t ch_num = signal_gen_regs.param.ch_num;

    for (uint8_t ch_indx = 0; ch_indx < ch_num; ch_indx++) {
        signal_gen_regs.select.select = ch_indx;
        Xil_Out32(base_addr + 16, signal_gen_regs.data);

        signal_gen_regs.data = Xil_In32(base_addr + 4);
        xil_printf("[SIGNAL_GEN] : poff   = %d\n", signal_gen_regs.poff);

        signal_gen_regs.data = Xil_In32(base_addr + 8);
        xil_printf("[SIGNAL_GEN] : pinc   = %d\n", signal_gen_regs.pinc);

        signal_gen_regs.data = Xil_In32(base_addr + 12);
        xil_printf("[SIGNAL_GEN] : ampl       = %d\n", signal_gen_regs.ampl.ampl);
        xil_printf("[SIGNAL_GEN] : round_type = %d\n", signal_gen_regs.ampl.round_type);
    }
}

uint32_t signal_gen_test (uintptr_t base_addr) {
    signal_gen_regs_t signal_gen_regs;
    uint32_t fs = 100e6;
    uint32_t dds_freq[2] = [50e6, 80e6];

    signal_gen_regs.data = Xil_In32(base_addr + 24);
    xil_printf("[SIGNAL_GEN] : ch_num     = %d\n", signal_gen_regs.param.ch_num);
    xil_printf("[SIGNAL_GEN] : reg_num    = %d\n", signal_gen_regs.param.reg_num);
    xil_printf("[SIGNAL_GEN] : fifo_depth = %d\n", signal_gen_regs.param.fifo_depth);

    uint8_t ch_num = signal_gen_regs.param.ch_num;

    for (uint8_t ch_indx = 0; ch_indx < ch_num; ch_indx++) {
        signal_gen_regs.select.select = ch_indx;
        Xil_Out32(base_addr + 16, signal_gen_regs.data);

        signal_gen_regs.pinc = dds_freq[ch_indx] / fs * (1 << 32);
        Xil_Out32(base_addr + 4, signal_gen_regs.data);

        signal_gen_regs.poff = 0;
        Xil_Out32(base_addr + 8, signal_gen_regs.data);

        signal_gen_regs.ampl.ampl = 100 * (ch_indx+1);
        signal_gen_regs.ampl.round_type = 0;
        Xil_Out32(base_addr + 12, signal_gen_regs.data);
    }

    signal_gen_regs.control.dds_enable = 3;
    signal_gen_regs.control.dds_reset = 0;
    Xil_Out32(base_addr, signal_gen_regs.data);

    usleep(100000);

    signal_gen_read_regs(base_addr);

    xil_printf("[SIGNAL_GEN]: stop test\n");

    return EXIT_SUCCESS;
}
