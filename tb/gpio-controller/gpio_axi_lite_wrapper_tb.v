module gpio_axi_lite_wrapper_tb();
    reg aclk;
    reg aresetn;    
    // write addr channel
    reg s_axi_awvalid;
    reg [31:0] s_axi_awaddr;
    wire s_axi_awready;
    // write data channel
    reg s_axi_wvalid;
    reg [31:0] s_axi_wdata;
    reg [3:0] s_axi_wstrb;
    wire s_axi_wready;
    // write response
    reg s_axi_bready;
    wire s_axi_bvalid;
    wire [1:0] s_axi_bresp;
    // read addr channel 
    reg s_axi_arvalid;
    reg [31:0] s_axi_araddr; 
    wire s_axi_arready;
    // read data channel 
    wire s_axi_rvalid;
    wire [31:0] s_axi_rdata; 
    wire s_axi_rresp; 
    reg s_axi_rready;

    wire r_en;
    wire [2:0] r_addr;
    reg  [31:0] r_data;


    gpio_axi_lite_wrapper uut (
        .aclk(aclk), 
        .aresetn(aresetn),
        .s_axi_awvalid(s_axi_awvalid), 
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awready(s_axi_awready),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wready(s_axi_wready),
        .s_axi_bready(s_axi_bready),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bresp(s_axi_bresp),
        .w_addr(w_addr), 
        .w_data(w_data),
        .w_en(w_en),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arready(s_axi_arready),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rready(s_axi_rready),
        .r_en(r_en), 
        .r_addr(r_addr),
        .r_data(r_data)
    ); 

    // 1. Clock Generation
    initial begin
        aclk = 1'b0; 
    end
    
    always begin
        #10 aclk = ~aclk; 
    end

    // 2. Reset and Stimulus Generation
    initial begin
        // Initialize inputs
        aresetn       <= 1'b0;
        s_axi_awvalid <= 1'b0;
        s_axi_awaddr  <= 32'b0;
        s_axi_wvalid  <= 1'b0;
        s_axi_wdata   <= 32'b0;
        s_axi_wstrb   <= 4'b0;
        s_axi_bready  <= 1'b0;
        repeat (4) @(posedge aclk);
        aresetn       <= 1'b1; // Release reset
        @(posedge aclk);

        s_axi_awvalid <= 1'b1;
        s_axi_awaddr <= 32'd1;
        s_axi_wvalid <= 1'b1;
        s_axi_wdata <= 32'd1;
        @(posedge aclk);
        s_axi_bready <= 1'b1;
        s_axi_awvalid <= 1'b0;
        s_axi_wvalid <= 1'b0;                
        repeat (3) @(posedge aclk);
        if ((s_axi_wdata == w_data) && (s_axi_awaddr == w_addr))
            $display("Test passed");
        else
            $display("Test failed");

        @(posedge aclk);
        s_axi_awvalid <= 1'b1;
        s_axi_awaddr <= 32'd2;
        s_axi_wvalid <= 1'b1;
        s_axi_wdata <= 32'd2;
        @(posedge aclk);
        s_axi_bready <= 1'b1;
        s_axi_awvalid <= 1'b0;
        s_axi_wvalid <= 1'b0;        
        repeat (3) @(posedge aclk);
        if ((s_axi_wdata == w_data) && (s_axi_awaddr == w_addr))
            $display("Test passed");
        else
            $display("Test failed");
        

        s_axi_arvalid <= 1'b1;
        s_axi_araddr <= 32'd4; // since first 2 bits are not discarded so output r_addr will be 1 since 4 = b100       
        @(posedge aclk)
        s_axi_arvalid <= 1'b0;
        @(posedge aclk)
        r_data <= 1'b1;              
        @(posedge aclk)
        s_axi_rready <= 1'b1;        
        @(posedge aclk)
        s_axi_rready <= 1'b0;
        repeat (3) @(posedge aclk);
        if ((s_axi_wdata == w_data) && (s_axi_awaddr == w_addr))
            $display("Test passed");
        else
            $display("Test failed");        

        // Your simulation logic can go here

        $finish;
    end

endmodule
