module axil_master #(
    parameter int AXIL_ADDR_WIDTH = 32,
    parameter int AXIL_DATA_WIDTH = 32,
    parameter int MAX_DELAY       = 10,
    parameter int MIN_DELAY       = 5
) (
    axil.master m_axil
);

    task automatic master_write_wdata(input logic [AXIL_DATA_WIDTH-1:0] data, int delay_min,
                                      int delay_max);
        int delay;
        void'(std::randomize(delay) with {delay inside {[delay_min : delay_max]};});
        repeat (delay) @(posedge m_axil.clk_i);
        m_axil.wvalid = '1;
        m_axil.wstrb  = '1;
        m_axil.wdata  = data;
        do begin
            @(posedge m_axil.clk_i);
        end while (~m_axil.wready);
        m_axil.wvalid = '0;
        m_axil.wstrb  = '0;
    endtask

    task automatic master_write_awaddr(input logic [AXIL_ADDR_WIDTH-1:0] addr, int delay_min,
                                       int delay_max);
        int delay;
        void'(std::randomize(delay) with {delay inside {[delay_min : delay_max]};});
        repeat (delay) @(posedge m_axil.clk_i);
        m_axil.awprot  = 0;
        m_axil.awvalid = 1;
        m_axil.awaddr  = addr;
        do begin
            @(posedge m_axil.clk_i);
        end while (~m_axil.awready);
        m_axil.awvalid = 0;
    endtask

    task automatic master_read_bresp(output logic [1:0] bresp, int delay_min, int delay_max);
        int delay;
        void'(std::randomize(delay) with {delay inside {[delay_min : delay_max]};});
        repeat (delay) @(posedge m_axil.clk_i);
        m_axil.bready = 1;
        do begin
            @(posedge m_axil.clk_i);
        end while (~m_axil.bvalid);
        m_axil.bready = 0;
        bresp         = m_axil.bresp;
    endtask

    task automatic master_write_reg(
        input logic [AXIL_ADDR_WIDTH-1:0] addr, input logic [AXIL_DATA_WIDTH-1:0] data,
        int master_delay_min = MIN_DELAY, int master_delay_max = MAX_DELAY);
        logic bresp;
        wait (m_axil.arstn_i);
        fork
            master_write_awaddr(addr, master_delay_min, master_delay_max);
            master_write_wdata(data, master_delay_min, master_delay_max);
            master_read_bresp(bresp, master_delay_min, master_delay_max);
        join
        $display("[%0t][WRITE]: addr = 0x%0h, data = 0x%0h, bresp = 0x%0h", $time, addr, data,
                 bresp);
    endtask

    task automatic master_write_araddr(input logic [AXIL_ADDR_WIDTH-1:0] addr, int delay_min,
                                       int delay_max);
        int delay;
        void'(std::randomize(delay) with {delay inside {[delay_min : delay_max]};});
        repeat (delay) @(posedge m_axil.clk_i);
        m_axil.arprot  = 0;
        m_axil.arvalid = 1;
        m_axil.araddr  = addr;
        do begin
            @(posedge m_axil.clk_i);
        end while (~m_axil.arready);
        m_axil.arvalid = 0;
    endtask

    task automatic master_read_rdata(output logic [AXIL_DATA_WIDTH-1:0] data,
                                     output logic [1:0] rresp, int delay_min, int delay_max);
        int delay;
        void'(std::randomize(delay) with {delay inside {[delay_min : delay_max]};});
        repeat (delay) @(posedge m_axil.clk_i);
        m_axil.rready = 1;
        do begin
            @(posedge m_axil.clk_i);
        end while (~m_axil.rvalid);
        m_axil.rready = 0;
        data          = m_axil.rdata;
        rresp         = m_axil.rresp;
    endtask

    task automatic master_read_reg(
        input logic [AXIL_ADDR_WIDTH-1:0] addr, output logic [AXIL_DATA_WIDTH-1:0] data,
        int master_delay_min = MIN_DELAY, int master_delay_max = MAX_DELAY);
        logic [1:0] rresp;
        wait (m_axil.arstn_i);
        fork
            master_write_araddr(addr, master_delay_min, master_delay_max);
            master_read_rdata(data, rresp, master_delay_min, master_delay_max);
        join
        $display("[%0t][READ]: addr = 0x%0h, data = 0x%0h, rresp = 0x%0h", $time, addr, data,
                 rresp);
    endtask

endmodule
