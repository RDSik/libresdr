`ifndef SIGNAL_GEN_PKG_SVH
`define SIGNAL_GEN_PKG_SVH

package signal_gen_pkg;

    localparam int DDS_PHASE_WIDTH = 32;

    typedef struct packed {
        logic [7:0]  reg_num;
        logic [7:0]  ch_num;
        logic [15:0] fifo_depth;
    } signal_gen_param_reg_t;

    typedef struct packed {
        logic [12:0] rsrvd;
        logic        fifo_full;
        logic        fifo_empty;
        logic        dds_ready;
        logic [15:0] fifo_cnt;
    } signal_gen_status_reg_t;

    typedef struct packed {
        logic [15:0] enable;
        logic [15:0] resetn;
    } signal_gen_control_reg_t;

    typedef struct packed {
        logic [DDS_PHASE_WIDTH-1:0] pinc;
        logic [DDS_PHASE_WIDTH-1:0] poff;
    } signal_gen_settings_reg_t;

    typedef struct packed {
        logic [22:0]              rsrvd;
        logic [7:0]               select;
        logic                     bypass_en;
        signal_gen_settings_reg_t settings;
    } signal_gen_dds_reg_t;

    typedef struct packed {
        signal_gen_param_reg_t   param;
        signal_gen_status_reg_t  status;
        signal_gen_dds_reg_t     dds;
        signal_gen_control_reg_t control;
    } signal_gen_regs_t;

    localparam int SIGNAL_GEN_CONTROL_REG_POS = 0;
    localparam int SIGNAL_GEN_POFF_REG_POS = SIGNAL_GEN_CONTROL_REG_POS + $bits(
        signal_gen_control_reg_t
    ) / 32;
    localparam int SIGNAL_GEN_PINC_REG_POS = SIGNAL_GEN_CONTROL_REG_POS + $bits(
        signal_gen_settings_reg_t
    ) / 32;
    localparam int SIGNAL_GEN_DDS_REG_POS = SIGNAL_GEN_CONTROL_REG_POS + $bits(
        signal_gen_dds_reg_t
    ) / 32;
    localparam int SIGNAL_GEN_STATUS_REG_POS = SIGNAL_GEN_POFF_REG_POS + $bits(
        signal_gen_dds_reg_t
    ) / 32;
    localparam int SIGNAL_GEN_PARAM_REG_POS = SIGNAL_GEN_STATUS_REG_POS + $bits(
        signal_gen_status_reg_t
    ) / 32;

    localparam int SIGNAL_GEN_REG_NUM = $bits(signal_gen_regs_t) / 32;

    localparam signal_gen_regs_t SIGNAL_GEN_REG_INIT = '{default: '0};

endpackage

`endif  // SIGNAL_GEN_PKG_SVH
