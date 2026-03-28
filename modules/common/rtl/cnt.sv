module cnt #(
    parameter int CNT_WIDTH = 16
) (
    input logic clk_i,
    input logic arstn_i,
    input logic en_i,

    input logic [CNT_WIDTH-1:0] num_i,

    output logic cnt_last_o
);

    logic [CNT_WIDTH-1:0] cnt;
    logic                 cnt_last;

    always_ff @(posedge clk_i) begin
        if (~arstn_i) begin
            cnt <= '0;
        end else if (en_i) begin
            if (cnt_last) begin
                cnt <= '0;
            end else begin
                cnt <= cnt + 1'b1;
            end
        end
    end

    assign cnt_last   = (cnt == (num_i - 1));
    assign cnt_last_o = cnt_last;

endmodule
