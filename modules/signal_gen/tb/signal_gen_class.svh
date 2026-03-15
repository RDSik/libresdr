`ifndef AXIL_SIGNAL_GEN_SVH
`define AXIL_SIGNAL_GEN_SVH

`include "modules/signal_gen_pkg/rtl/signal_gen_pkg.svh"
`include "modules/verification/tb/axil_env.svh"

import signal_gen_pkg::*;

class signal_gen_class #(
    parameter logic BYPASS_EN = 0,
    parameter int AXIL_ADDR_WIDTH = 32,
    parameter int AXIL_DATA_WIDTH = 32,
    parameter int AXIS_DATA_WIDTH = 64,
    parameter logic [AXIL_ADDR_WIDTH-1:0] BASE_ADDR = 'h200000
);

    localparam int ADDR_OFFSET = AXIL_DATA_WIDTH / 8;
    localparam logic [1:0][31:0] POFF = {32'd44, 32'd22};
    localparam logic [1:0][31:0] PINC = {32'd233, 32'd677};

    env_base #(
        .DATA_WIDTH_IN (AXIS_DATA_WIDTH),
        .DATA_WIDTH_OUT(AXIS_DATA_WIDTH),
        .TLAST_EN      (0)
    ) env;

    virtual axis_if #(.DATA_WIDTH(AXIS_DATA_WIDTH)) s_axis;
    virtual axis_if #(.DATA_WIDTH(AXIS_DATA_WIDTH)) m_axis;

    axil_env #(
        .ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .DATA_WIDTH(AXIL_DATA_WIDTH)
    ) env;

    virtual axil_if #(
        .ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .DATA_WIDTH(AXIL_DATA_WIDTH)
    ) s_axil;

    function new(
        virtual axil_if #(
            .ADDR_WIDTH(AXIL_ADDR_WIDTH),
            .DATA_WIDTH(AXIL_DATA_WIDTH)
        ) s_axil,
        virtual axis_if #(.DATA_WIDTH(AXIS_DATA_WIDTH)) m_axis,
        virtual axis_if #(.DATA_WIDTH(AXIS_DATA_WIDTH)) s_axis);
        this.s_axil = s_axil;
        this.s_axis = s_axis;
        this.m_axis = m_axis;
        axil_env    = new(s_axil);
        env         = new(s_axis, m_axis);
    endfunction

    task automatic signal_gen_write_regs();
        signal_gen_regs_t signal_gen_regs;
        signal_gen_regs.control.bypass_en = BYPASS_EN;
        signal_gen_regs.control.reset     = 1'b0;
        signal_gen_regs.control.enable    = 1'b1;
        begin
            env.master_read_reg(BASE_ADDR + ADDR_OFFSET * SIGNAL_GEN_PARAM_REG_POS,
                                signal_gen_regs.param);

            env.master_write_reg(BASE_ADDR + ADDR_OFFSET * SIGNAL_GEN_CONTROL_REG_POS,
                                 signal_gen_regs.control);
            for (int ch_indx = 0; ch_indx < signal_gen_regs.param.ch_num; ch_indx++) begin
                env.master_write_reg(BASE_ADDR + ADDR_OFFSET * SIGNAL_GEN_SELECT_REG_POS, ch_indx);
                env.master_write_reg(BASE_ADDR + ADDR_OFFSET * SIGNAL_GEN_POFF_REG_POS,
                                     POFF[ch_indx]);
                env.master_write_reg(BASE_ADDR + ADDR_OFFSET * SIGNAL_GEN_PINC_REG_POS,
                                     PINC[ch_indx]);
            end
        end
    endtask

    task automatic signal_gen_read_regs();
        signal_gen_regs_t signal_gen_regs;
        begin
            env.master_read_reg(BASE_ADDR + ADDR_OFFSET * SIGNAL_GEN_CONTROL_REG_POS,
                                signal_gen_regs.control);
            env.master_read_reg(BASE_ADDR + ADDR_OFFSET * SIGNAL_GEN_SELECT_REG_POS,
                                signal_gen_regs.dds.select);
            env.master_read_reg(BASE_ADDR + ADDR_OFFSET * SIGNAL_GEN_STATUS_REG_POS,
                                signal_gen_regs.status);
            env.master_read_reg(BASE_ADDR + ADDR_OFFSET * SIGNAL_GEN_PARAM_REG_POS,
                                signal_gen_regs.param);

            for (int ch_indx = 0; ch_indx < signal_gen_regs.param.ch_num; ch_indx++) begin
                env.master_write_reg(BASE_ADDR + ADDR_OFFSET * SIGNAL_GEN_SELECT_REG_POS, ch_indx);
                env.master_read_reg(BASE_ADDR + ADDR_OFFSET * SIGNAL_GEN_SELECT_REG_POS,
                                    signal_gen_regs.dds.select);
                env.master_read_reg(BASE_ADDR + ADDR_OFFSET * SIGNAL_GEN_POFF_REG_POS,
                                    signal_gen_regs.dds.settings.poff);
                env.master_read_reg(BASE_ADDR + ADDR_OFFSET * SIGNAL_GEN_PINC_REG_POS,
                                    signal_gen_regs.dds.settings.pinc);
                $display("[%0t][SIGNAL_GEN]: select = %0d", $time, signal_gen_regs.dds.select);
                $display("[%0t][SIGNAL_GEN]: poff   = %0d", $time,
                         signal_gen_regs.dds.settings.poff);
                $display("[%0t][SIGNAL_GEN]: poff   = %0d", $time,
                         signal_gen_regs.dds.settings.pinc);
            end

            $display("[%0t][SIGNAL_GEN]: base_addr  = %0h", $time, BASE_ADDR);
            $display("[%0t][SIGNAL_GEN]: reset      = %0d", $time, signal_gen_regs.control.reset);
            $display("[%0t][SIGNAL_GEN]: enable     = %0d", $time, signal_gen_regs.control.enable);
            $display("[%0t][SIGNAL_GEN]: bypass_en  = %0d", $time,
                     signal_gen_regs.control.bypass_en);
            $display("[%0t][SIGNAL_GEN]: data_cnt   = %0d", $time, signal_gen_regs.status.data_cnt);
            $display("[%0t][SIGNAL_GEN]: dds_ready  = %0d", $time,
                     signal_gen_regs.status.dds_ready);
            $display("[%0t][SIGNAL_GEN]: dds_ready  = %0d", $time,
                     signal_gen_regs.status.fifo_empty);
            $display("[%0t][SIGNAL_GEN]: fifo_full  = %0d", $time,
                     signal_gen_regs.status.fifo_full);
            $display("[%0t][SIGNAL_GEN]: fifo_depth = %0d", $time,
                     signal_gen_regs.param.fifo_depth);
            $display("[%0t][SIGNAL_GEN]: ch_num     = %0d", $time, signal_gen_regs.param.ch_num);
            $display("[%0t][SIGNAL_GEN]: reg_num    = %0d", $time, signal_gen_regs.param.reg_num);
        end
    endtask

    task automatic signal_gen_start();
        begin
            signal_gen_write_regs();
            signal_gen_read_regs();
            if (BYPASS_EN) begin
                env.run();
            end
        end
    endtask

endclass

`endif  // AXIL_SIGNAL_GEN_SVH
