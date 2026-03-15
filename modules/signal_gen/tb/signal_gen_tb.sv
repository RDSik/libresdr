`timescale 1ns / 1ps

`include "../../../../../modules/signal_gen/rtl/signal_gen_pkg.svh"

module signal_gen_tb ();

    import signal_gen_pkg::*;

    localparam logic ILA_EN = 0;
    localparam int ASYNC_MODE_EN = 1;
    localparam int SYNC_STAGE_NUM = 3;
    localparam int AXIL_ADDR_WIDTH = 32;
    localparam int AXIL_DATA_WIDTH = 32;
    localparam int AXIS_DATA_WIDTH = 64;
    localparam int DATA_WIDTH = 64;
    localparam int FIFO_DEPTH = 4096;
    localparam FIFO_MEM_TYPE = "block";
    localparam FAMILY = "";

    localparam logic [AXIL_ADDR_WIDTH-1:0] BASE_ADDR = 'h200000;
    localparam logic BYPASS_EN = 0;

    localparam int S_CLK_PER_NS = 2;
    localparam int M_CLK_PER_NS = 4;
    localparam int RESET_DELAY = 10;
    localparam int MAX_DELAY = 20;
    localparam int MIN_DELAY = 5;

    logic s_clk_i;
    logic m_clk_i;
    logic arstn_i;

    axil_if #(
        .ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .DATA_WIDTH(AXIL_DATA_WIDTH)
    ) axil (
        .clk_i  (s_clk_i),
        .arstn_i(arstn_i)
    );

    axis_if #(
        .DATA_WIDTH(AXIS_DATA_WIDTH)
    ) m_axis (
        .clk_i  (s_clk_i),
        .arstn_i(arstn_i)
    );

    axis_if #(
        .DATA_WIDTH(AXIS_DATA_WIDTH)
    ) s_axis (
        .clk_i  (m_clk_i),
        .arstn_i(arstn_i)
    );

    initial begin
        arstn_i = 1'b0;
        repeat (RESET_DELAY) @(posedge s_clk_i);
        arstn_i = 1'b1;
        $display("Reset done in: %0t ns\n.", $time());
    end

    initial begin
        s_clk_i = 1'b0;
        forever begin
            #(S_CLK_PER_NS / 2) s_clk_i = ~s_clk_i;
        end
    end

    initial begin
        m_clk_i = 1'b0;
        forever begin
            #(M_CLK_PER_NS / 2) m_clk_i = ~m_clk_i;
        end
    end

    initial begin
        signal_gen_write_regs();
        signal_gen_read_regs();
    end

    initial begin
        $dumpfile("signal_gen_tb.vcd");
        $dumpvars(0, signal_gen_tb);
    end

    axil_master #(
        .AXIL_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .AXIL_DATA_WIDTH(AXIL_DATA_WIDTH),
        .MAX_DELAY      (MAX_DELAY),
        .MIN_DELAY      (MIN_DELAY)
    ) master (
        .m_axil(axil)
    );

    signal_gen #(
        .ILA_EN         (ILA_EN),
        .DATA_WIDTH     (AXIS_DATA_WIDTH),
        .AXIL_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .AXIL_DATA_WIDTH(AXIL_DATA_WIDTH),
        .SYNC_STAGE_NUM (SYNC_STAGE_NUM),
        .ASYNC_MODE_EN  (ASYNC_MODE_EN),
        .FIFO_DEPTH     (FIFO_DEPTH),
        .FIFO_MEM_TYPE  (FIFO_MEM_TYPE),
        .FAMILY         (FAMILY)
    ) dut (
        .clk_i  (clk),
        .arstn_i(arstn_i),
        .s_axil (axil),
        .s_axis (m_axis),
        .m_axis (s_axis)
    );

    task automatic signal_gen_write_regs();
        signal_gen_regs_t signal_gen_regs;
        signal_gen_regs.control.reset  = '1;
        signal_gen_regs.control.enable = '1;
        begin
            master.master_read_reg(BASE_ADDR + ADDR_OFFSET * SIGNAL_GEN_PARAM_REG_POS,
                                   signal_gen_regs.param);

            master.master_write_reg(BASE_ADDR + ADDR_OFFSET * SIGNAL_GEN_CONTROL_REG_POS,
                                    signal_gen_regs.control);
            for (int ch_indx = 0; ch_indx < signal_gen_regs.param.ch_num; ch_indx++) begin
                master.master_write_reg(BASE_ADDR + ADDR_OFFSET * SIGNAL_GEN_SELECT_REG_POS, {
                                        ch_indx, BYPASS_EN});
                master.master_write_reg(BASE_ADDR + ADDR_OFFSET * SIGNAL_GEN_POFF_REG_POS,
                                        POFF[ch_indx]);
                master.master_write_reg(BASE_ADDR + ADDR_OFFSET * SIGNAL_GEN_PINC_REG_POS,
                                        PINC[ch_indx]);
            end
        end
    endtask

    task automatic signal_gen_read_regs();
        signal_gen_regs_t signal_gen_regs;
        begin
            master.master_read_reg(BASE_ADDR + ADDR_OFFSET * SIGNAL_GEN_CONTROL_REG_POS,
                                   signal_gen_regs.control);
            master.master_read_reg(BASE_ADDR + ADDR_OFFSET * SIGNAL_GEN_SELECT_REG_POS,
                                   signal_gen_regs.dds.select);
            master.master_read_reg(BASE_ADDR + ADDR_OFFSET * SIGNAL_GEN_STATUS_REG_POS,
                                   signal_gen_regs.status);
            master.master_read_reg(BASE_ADDR + ADDR_OFFSET * SIGNAL_GEN_PARAM_REG_POS,
                                   signal_gen_regs.param);

            for (int ch_indx = 0; ch_indx < signal_gen_regs.param.ch_num; ch_indx++) begin
                master.master_write_reg(BASE_ADDR + ADDR_OFFSET * SIGNAL_GEN_SELECT_REG_POS,
                                        ch_indx);
                master.master_read_reg(BASE_ADDR + ADDR_OFFSET * SIGNAL_GEN_SELECT_REG_POS,
                                       signal_gen_regs.dds.select);
                master.master_read_reg(BASE_ADDR + ADDR_OFFSET * SIGNAL_GEN_POFF_REG_POS,
                                       signal_gen_regs.dds.settings.poff);
                master.master_read_reg(BASE_ADDR + ADDR_OFFSET * SIGNAL_GEN_PINC_REG_POS,
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

endmodule
