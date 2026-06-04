module chip_top #(
    parameter WIDTH_GPIO_PADS = 32
)(
    input clk, 
    input resetn,
    inout [WIDTH_GPIO_PADS - 1 : 0] io_gpio_pad,   
);

    wire [WIDTH_GPIO_PADS - 1 : 0] gpio_synced_pad_frm_pinif_to_cnt;

    wire [OUTPUT_DATA_WIDTH - 1:0] rmap_dir_frm_cnt;
    wire [OUTPUT_DATA_WIDTH - 1:0] rmap_data_frm_cnt_to_pinif;
    wire [OUTPUT_DATA_WIDTH - 1:0] rmap_ie_frm_cnt;
    wire [OUTPUT_DATA_WIDTH - 1:0] rmap_is_frm_cnt;
    wire [OUTPUT_DATA_WIDTH - 1:0] rmap_ic_frm_cnt;
    wire [OUTPUT_DATA_WIDTH - 1:0] rmap_alt_frm_cnt;
    wire [OUTPUT_DATA_WIDTH - 1:0] rmap_itype_frm_cnt;
    wire [OUTPUT_DATA_WIDTH - 1:0] rmap_ipol_frm_cnt; 

    pin_interface pin_intf #(
        WIDTH_GPIO_PADS = 32
    )(
        .clk(clk),
        .resetn(resetn),
        .i_dir_gpio_pad(rmap_dir_frm_cnt),
        .i_out_data_gpio_pad(rmap_data_frm_cnt_to_pinif),
        .io_gpio_pad(io_gpio_pad),
        .o_gpio_synced_pad(gpio_synced_pad_frm_pinif_to_cnt)
    );

    gpio_controller_top #(
        INPUT_ADDR_WIDTH = 32,
        INPUT_DATA_WIDTH = 32,
        INPUT_STROBE_WIDTH = 4,    
        OUTPUT_ADDR_WIDTH = 3,
        OUTPUT_STROBE_WIDTH = 4,
        OUTPUT_DATA_WIDTH = 32            
    )(
        .aclk(clk),
        .aresetn(resetn),
        // write addr channel
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awready(s_axi_awready),
        // write data channel
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wready(s_axi_wready),
        // write response
        .s_axi_bready(s_axi_bready),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bresp(s_axi_bresp),       
        // read addr channel 
        .s_axi_arvalid(s_axi_arvalid), 
        .s_axi_araddr(s_axi_araddr), 
        .s_axi_arready(s_axi_arready), 
        // read data channel 
        .s_axi_rvalid(s_axi_rvalid), 
        .s_axi_rdata(s_axi_rdata), 
        .s_axi_rresp(s_axi_rresp), 
        .s_axi_rready(s_axi_rready),               

        .r_data(gpio_synced_pad),         
        .w_data(i_out_data_gpio_pad)

        .o_rmap_dir(rmap_dir_frm_cnt),                  
        .o_rmap_data(rmap_data_frm_cnt_to_pinif),
        .o_rmap_ie(rmap_ie_frm_cnt),
        .o_rmap_is(rmap_is_frm_cnt),
        .o_rmap_ic(rmap_ic_frm_cnt),
        .o_rmap_alt(rmap_alt_frm_cnt),
        .o_rmap_itype(rmap_itype_frm_cnt),        
        .o_rmap_ipol(rmap_ipol_frm_cnt),

        .i_gpio_pin_data(gpio_synced_pad_frm_pinif_to_cnt)
    );


endmodule
