set path [file dirname [info script]]

set axi_dmac "
    $path/hdl/library/axi_dmac/inc_id.vh
    $path/hdl/library/axi_dmac/resp.vh
    $path/hdl/library/axi_dmac/axi_dmac_burst_memory.v
    $path/hdl/library/axi_dmac/axi_dmac_regmap.v
    $path/hdl/library/axi_dmac/axi_dmac_regmap_request.v
    $path/hdl/library/axi_dmac/axi_dmac_reset_manager.v
    $path/hdl/library/axi_dmac/axi_dmac_resize_dest.v
    $path/hdl/library/axi_dmac/axi_dmac_resize_src.v
    $path/hdl/library/axi_dmac/axi_dmac_response_manager.v
    $path/hdl/library/axi_dmac/axi_dmac_transfer.v
    $path/hdl/library/axi_dmac/address_generator.vh
    $path/hdl/library/axi_dmac/data_mover.v
    $path/hdl/library/axi_dmac/request_arb.v
    $path/hdl/library/axi_dmac/request_generator.v
    $path/hdl/library/axi_dmac/response_handler.v
    $path/hdl/library/axi_dmac/axi_register_slice.v
    $path/hdl/library/axi_dmac/dmac_2d_transfer.v
    $path/hdl/library/axi_dmac/dest_axi_mm.v
    $path/hdl/library/axi_dmac/dest_axi_stream.v
    $path/hdl/library/axi_dmac/dest_fifo_inf.vh
    $path/hdl/library/axi_dmac/src_axi_mm.v
    $path/hdl/library/axi_dmac/src_axi_stream.v
    $path/hdl/library/axi_dmac/src_fifo_inf.v
    $path/hdl/library/axi_dmac/splitter.v
    $path/hdl/library/axi_dmac/response_generator.v
    $path/hdl/library/axi_dmac/axi_dmac.v
    $path/hdl/library/util_cdc/sync_bits.v
    $path/hdl/library/util_cdc/sync_event.v
    $path/hdl/library/common/up_axi.v
    $path/hdl/library/common/ad_mem_asym.v
    $path/hdl/library/util_axis_fifo/util_axis_fifo.v
    $path/hdl/library/util_axis_fifo/util_axis_fifo_address_generator.v
"

add_files -norecurse $axi_dmac

set axi_ad_9361 "
    $path/hdl/library/axi_ad9361/axi_ad9361_rx_pnmon.v
    $path/hdl/library/axi_ad9361/axi_ad9361_rx_channel.v
    $path/hdl/library/axi_ad9361/axi_ad9361_rx.v
    $path/hdl/library/axi_ad9361/axi_ad9361_tx_channel.v
    $path/hdl/library/axi_ad9361/axi_ad9361_tx.v
    $path/hdl/library/axi_ad9361/axi_ad9361_tdd.v
    $path/hdl/library/axi_ad9361/axi_ad9361_tdd_if.v
    $path/hdl/library/axi_ad9361/axi_ad9361.v
    $path/hdl/library/axi_ad9361/xilinx/axi_ad9361_lvds_if.v
    $path/hdl/library/axi_ad9361/xilinx/axi_ad9361_cmos_if.v
    $path/hdl/library/common/ad_rst.v
    $path/hdl/library/common/ad_pnmon.v
    $path/hdl/library/common/ad_dds_cordic_pipe.v
    $path/hdl/library/common/ad_dds_sine_cordic.v
    $path/hdl/library/common/ad_dds_sine.v
    $path/hdl/library/common/ad_dds_2.v
    $path/hdl/library/common/ad_dds_1.v
    $path/hdl/library/common/ad_dds.v
    $path/hdl/library/common/ad_datafmt.v
    $path/hdl/library/common/ad_iqcor.v
    $path/hdl/library/common/ad_addsub.v
    $path/hdl/library/common/ad_tdd_control.v
    $path/hdl/library/common/ad_pps_receiver.v
    $path/hdl/library/common/up_axi.v
    $path/hdl/library/common/ad_iobuf.v
    $path/hdl/library/common/up_xfer_cntrl.v
    $path/hdl/library/common/up_xfer_status.v
    $path/hdl/library/common/up_clock_mon.v
    $path/hdl/library/common/up_delay_cntrl.v
    $path/hdl/library/common/up_adc_common.v
    $path/hdl/library/common/up_adc_channel.v
    $path/hdl/library/common/up_dac_common.v
    $path/hdl/library/common/up_dac_channel.v
    $path/hdl/library/common/up_tdd_cntrl.v
    $path/hdl/library/xilinx/common/ad_data_clk.v
    $path/hdl/library/xilinx/common/ad_data_in.v
    $path/hdl/library/xilinx/common/ad_data_out.v
    $path/hdl/library/xilinx/common/ad_dcfilter.v
    $path/hdl/library/xilinx/common/ad_mul.v
"

add_files -norecurse $axi_ad_9361
add_files -norecurse $path/hdl/library/axi_ad9361/axi_ad9361_constr.xdc
add_files -norecurse $path/hdl/library/xilinx/common/ad_rst_constr.xdc
add_files -norecurse $path/hdl/library/xilinx/common/up_xfer_status_constr.xdc
add_files -norecurse $path/hdl/library/xilinx/common/up_clock_mon_constr.xdc
add_files -norecurse $path/hdl/library/xilinx/common/up_xfer_cntrl_constr.xdc
