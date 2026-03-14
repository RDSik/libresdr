// (c) Copyright 1995-2026 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:ip:axis_data_fifo:2.0
// IP Revision: 9

(* X_CORE_INFO = "axis_data_fifo_v2_0_9_top,Vivado 2022.2" *)
(* CHECK_LICENSE_TYPE = "axis_data_fifo,axis_data_fifo_v2_0_9_top,{}" *)
(* CORE_GENERATION_INFO = "axis_data_fifo,axis_data_fifo_v2_0_9_top,{x_ipProduct=Vivado 2022.2,x_ipVendor=xilinx.com,x_ipLibrary=ip,x_ipName=axis_data_fifo,x_ipVersion=2.0,x_ipCoreRevision=9,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,C_FAMILY=zynq,C_AXIS_TDATA_WIDTH=8,C_AXIS_TID_WIDTH=1,C_AXIS_TDEST_WIDTH=1,C_AXIS_TUSER_WIDTH=1,C_AXIS_SIGNAL_SET=0b00000000000000000000000000011111,C_FIFO_DEPTH=512,C_FIFO_MODE=2,C_IS_ACLK_ASYNC=1,C_SYNCHRONIZER_STAGE=3,C_ACLKEN_CONV_MODE=3,C_ECC_MODE=0,C_FIFO_MEMORY_TYPE=auto,C_USE_ADV_FEAT\
URES=826617925,C_PROG_EMPTY_THRESH=5,C_PROG_FULL_THRESH=11}" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module axis_data_fifo #(
    parameter                C_FAMILY             = "virtex7",
    parameter integer        C_AXIS_TDATA_WIDTH   = 8,
    parameter integer        C_AXIS_TID_WIDTH     = 1,
    parameter integer        C_AXIS_TDEST_WIDTH   = 1,
    parameter integer        C_AXIS_TUSER_WIDTH   = 1,
    parameter         [31:0] C_AXIS_SIGNAL_SET    = 32'h03,
    // C_AXIS_SIGNAL_SET: each bit if enabled specifies which axis optional signals are present
    //   [0] => TREADY present
    //   [1] => TDATA present
    //   [2] => TSTRB present, TDATA must be present
    //   [3] => TKEEP present, TDATA must be present
    //   [4] => TLAST present
    //   [5] => TID present
    //   [6] => TDEST present
    //   [7] => TUSER present
    parameter integer        C_FIFO_DEPTH         = 512,
    //  Valid values 16,32,64,128,256,512,1024,2048,4096,...
    parameter integer        C_FIFO_MODE          = 1,
    // Values:
    //   0 == N0 FIFO
    //   1 == Regular FIFO
    //   2 == Store and Forward FIFO (Packet Mode). Requires TLAST.
    parameter integer        C_IS_ACLK_ASYNC      = 0,
    //  Enables async clock cross when 1.
    parameter integer        C_SYNCHRONIZER_STAGE = 2,
    // Specifies the number of synchronization stages to implement
    parameter integer        C_ACLKEN_CONV_MODE   = 0,
    // C_ACLKEN_CONV_MODE: Determines how to handle the clock enable pins during
    // clock conversion
    // 0 -- Clock enables not converted
    // 1 -- S_AXIS_ACLKEN can toggle,  M_AXIS_ACLKEN always high.
    // 2 -- S_AXIS_ACLKEN always high, M_AXIS_ACLKEN can toggle.
    // 3 -- S_AXIS_ACLKEN can toggle,  M_AXIS_ACLKEN can toggle.
    parameter                C_ECC_MODE           = 0,          // 0 - no_ecc, 1 - en_ecc
    parameter                C_FIFO_MEMORY_TYPE   = "auto",
    parameter                C_USE_ADV_FEATURES   = "1000",
    // |  Setting USE_ADV_FEATURES[1]  to 1 enables prog_full flag;    Default value of this bit is 0                        |
    // |   Setting USE_ADV_FEATURES[2]  to 1 enables wr_data_count;     Default value of this bit is 0                       |
    // |   Setting USE_ADV_FEATURES[3]  to 1 enables almost_full flag;  Default value of this bit is 0                       |
    // |   Setting USE_ADV_FEATURES[9]  to 1 enables prog_empty flag;   Default value of this bit is 0                       |
    // |   Setting USE_ADV_FEATURES[10] to 1 enables rd_data_count;     Default value of this bit is 0                       |
    // |   Setting USE_ADV_FEATURES[11] to 1 enables almost_empty flag; Default value of this bit is 0                       |
    // |                                                                                                                     |
    // | CAUTION: DO NOT change the default value of USE_ADV_FEATURES[12].                                                   |
    parameter integer        C_PROG_EMPTY_THRESH  = 5,
    // |  Min_Value = 5                                                                                                      |
    // |   Max_Value = FIFO_WRITE_DEPTH - 5                                                                                  |
    // |                                                                                                                     |
    // | NOTE: The default threshold value is dependent on default FIFO_WRITE_DEPTH value. If FIFO_WRITE_DEPTH value is      |
    // | changed, ensure the threshold value is within the valid range though the programmable flags are not used.           |
    parameter integer        C_PROG_FULL_THRESH   = 11
    // |  Min_Value = 5 + CDC_SYNC_STAGES                                                                                    |
    // |   Max_Value = FIFO_WRITE_DEPTH - 5                                                                                  |
    // |                                                                                                                     |
    // | NOTE: The default threshold value is dependent on default FIFO_WRITE_DEPTH value. If FIFO_WRITE_DEPTH value is      |
    // | changed, ensure the threshold value is within the valid range though the programmable flags are not used.           |
) (
    ///////////////////////////////////////////////////////////////////////////////
    // Port Declarations
    ///////////////////////////////////////////////////////////////////////////////
    // Slave side
    input  wire                            s_axis_aclk,
    input  wire                            s_axis_aresetn,
    input  wire                            s_axis_aclken,
    input  wire                            s_axis_tvalid,
    output wire                            s_axis_tready,
    input  wire [  C_AXIS_TDATA_WIDTH-1:0] s_axis_tdata,
    input  wire [C_AXIS_TDATA_WIDTH/8-1:0] s_axis_tstrb,
    input  wire [C_AXIS_TDATA_WIDTH/8-1:0] s_axis_tkeep,
    input  wire                            s_axis_tlast,
    input  wire [    C_AXIS_TID_WIDTH-1:0] s_axis_tid,
    input  wire [  C_AXIS_TDEST_WIDTH-1:0] s_axis_tdest,
    input  wire [  C_AXIS_TUSER_WIDTH-1:0] s_axis_tuser,
    output wire                            almost_full,
    output wire                            prog_full,
    output wire [                    31:0] axis_wr_data_count,
    input  wire                            injectsbiterr,
    input  wire                            injectdbiterr,

    // Master side
    input  wire                            m_axis_aclk,
    input  wire                            m_axis_aclken,
    output wire                            m_axis_tvalid,
    input  wire                            m_axis_tready,
    output wire [  C_AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
    output wire [C_AXIS_TDATA_WIDTH/8-1:0] m_axis_tstrb,
    output wire [C_AXIS_TDATA_WIDTH/8-1:0] m_axis_tkeep,
    output wire                            m_axis_tlast,
    output wire [    C_AXIS_TID_WIDTH-1:0] m_axis_tid,
    output wire [  C_AXIS_TDEST_WIDTH-1:0] m_axis_tdest,
    output wire [  C_AXIS_TUSER_WIDTH-1:0] m_axis_tuser,
    output wire                            almost_empty,
    output wire                            prog_empty,
    output wire [                    31:0] axis_rd_data_count,

    output wire sbiterr,
    output wire dbiterr
);

    axis_data_fifo_v2_0_9_top #(
        .C_FAMILY            (C_FAMILY),
        .C_AXIS_TDATA_WIDTH  (C_AXIS_TDATA_WIDTH),
        .C_AXIS_TID_WIDTH    (C_AXIS_TID_WIDTH),
        .C_AXIS_TDEST_WIDTH  (C_AXIS_TDEST_WIDTH),
        .C_AXIS_TUSER_WIDTH  (C_AXIS_TUSER_WIDTH),
        .C_AXIS_SIGNAL_SET   (C_AXIS_SIGNAL_SET),
        .C_FIFO_DEPTH        (C_FIFO_DEPTH),
        .C_FIFO_MODE         (C_FIFO_MODE),
        .C_IS_ACLK_ASYNC     (C_IS_ACLK_ASYNC),
        .C_SYNCHRONIZER_STAGE(C_SYNCHRONIZER_STAGE),
        .C_ACLKEN_CONV_MODE  (C_ACLKEN_CONV_MODE),
        .C_ECC_MODE          (C_ECC_MODE),
        .C_FIFO_MEMORY_TYPE  (C_FIFO_MEMORY_TYPE),
        .C_USE_ADV_FEATURES  (C_USE_ADV_FEATURES),
        .C_PROG_EMPTY_THRESH (C_PROG_EMPTY_THRESH),
        .C_PROG_FULL_THRESH  (C_PROG_FULL_THRESH)
    ) inst (
        .s_axis_aresetn    (s_axis_aresetn),
        .s_axis_aclk       (s_axis_aclk),
        .s_axis_aclken     (s_axis_aclken),
        .s_axis_tvalid     (s_axis_tvalid),
        .s_axis_tready     (s_axis_tready),
        .s_axis_tdata      (s_axis_tdata),
        .s_axis_tstrb      (s_axis_tstrb),
        .s_axis_tkeep      (s_axis_tkeep),
        .s_axis_tlast      (s_axis_tlast),
        .s_axis_tid        (s_axis_tid),
        .s_axis_tdest      (s_axis_tdest),
        .s_axis_tuser      (s_axis_tuser),
        .m_axis_aclk       (m_axis_aclk),
        .m_axis_aclken     (m_axis_aclken),
        .m_axis_tvalid     (m_axis_tvalid),
        .m_axis_tready     (m_axis_tready),
        .m_axis_tdata      (m_axis_tdata),
        .m_axis_tstrb      (m_axis_tstrb),
        .m_axis_tkeep      (m_axis_tkeep),
        .m_axis_tlast      (m_axis_tlast),
        .m_axis_tid        (m_axis_tid),
        .m_axis_tdest      (m_axis_tdest),
        .m_axis_tuser      (m_axis_tuser),
        .axis_wr_data_count(axis_wr_data_count),
        .axis_rd_data_count(axis_rd_data_count),
        .almost_empty      (almost_empty),
        .prog_empty        (prog_empty),
        .almost_full       (almost_full),
        .prog_full         (prog_full),
        .sbiterr           (sbiterr),
        .dbiterr           (dbiterr),
        .injectsbiterr     (injectsbiterr),
        .injectdbiterr     (injectdbiterr)
    );

endmodule
