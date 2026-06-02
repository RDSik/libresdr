module axi_to_axil (
	axi_if.slave   s_axi
	axil_if.master m_axil
);

	assign m_axil.awaddr  = s_axi.awaddr;
	assign m_axil.awprot  = s_axi.awprot;
	assign m_axil.awvalid = s_axi.awvalid;
	assign s_axi.awready  = m_axil.awready;

	assign m_axil.wdata  = s_axi.wdata;
	assign m_axil.wstrb  = s_axi.wstrb;
	assign m_axil.wvalid = s_axi.wvalid;
	assign s_axi.wready  = m_axil.wready;

	assign s_axi.bresp   = m_axil.bresp;
	assign s_axi.bvalid  = m_axil.bvalid;
	assign m_axil.bready = s_axi.bready;

	assign m_axil.araddr  = s_axi.araddr;
	assign m_axil.arprot  = s_axi.arprot;
	assign m_axil.arvalid = s_axi.arvalid;
	assign s_axi.arready  = m_axil.arready;

	assign s_axi.rdata   = m_axil.rdata;
	assign s_axi.rresp   = m_axil.rresp;
	assign s_axi.rvalid  = m_axil.rvalid;
	assign m_axil.rready = s_axi.rready;

endmodule
