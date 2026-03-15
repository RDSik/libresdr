`timescale 1ns / 1ps

`include "../../../../../modules/signal_gen/tb/signal_gen_class.svh"

module signal_gen_tb ();

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

    logic s_clk_i;
    logic m_clk_i;
    logic arstn_i;

    axil_if #(
        .ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .DATA_WIDTH(AXIL_DATA_WIDTH)
    ) s_axil (
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
        signal_gen_class #(
            .BYPASS_EN (BYPASS_EN),
            .DATA_WIDTH(AXIL_DATA_WIDTH),
            .ADDR_WIDTH(AXIL_ADDR_WIDTH),
            .BASE_ADDR (BASE_ADDR)
        ) signal_gen;
        signal_gen = new(s_axil, m_axis, s_axis);
        signal_gen.signal_gen_start();
        #10 $stop;
    end

    initial begin
        $dumpfile("signal_gen_tb.vcd");
        $dumpvars(0, signal_gen_tb);
    end

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
        .s_axil (s_axil),
        .s_axis (m_axis),
        .m_axis (s_axis)
    );

endmodule
