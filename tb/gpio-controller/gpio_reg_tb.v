module gpio_reg_tb();

reg clk;
reg resetn;

reg i_rd_en;
reg [2:0] i_rd_addr;
wire [31:0] o_r_rd_data;

reg i_wr_en;
reg [2:0] i_wr_addr;
reg [31:0] i_wr_data;
reg [3:0] i_wr_strb;

reg [31:0] i_gpio_pin_data;

gpio_reg uut (
    .clk(clk),
    .resetn(resetn),
    .i_rd_en(i_rd_en),
    .i_rd_addr(i_rd_addr),
    .o_r_rd_data(o_r_rd_data),
    .i_wr_en(i_wr_en),
    .i_wr_addr(i_wr_addr),
    .i_wr_data(i_wr_data),
    .i_wr_strb(i_wr_strb),
    .i_gpio_pin_data(i_gpio_pin_data)
);

always begin
    #10 clk = ~clk;
end

initial begin
    clk <= 1'b0;    
    resetn <= 1'b0;
    repeat (4) @(posedge clk);   
    resetn <= 1'b1;
    @(posedge clk);   


    // test - reading data regoister to check if its the same we gave above synced input
    // ----------------------------------------------------------------------
    i_gpio_pin_data <= 32'hFFFFFFFF;
    @(posedge clk);
        // reading
    i_rd_en <= 1'b1;
    i_rd_addr <= 1'b1;
    @(posedge clk);
    i_rd_en <= 1'b0;
    @(posedge clk);
    if (o_r_rd_data == i_gpio_pin_data)
        $display("Test passed");
    else
        $display("Test Failed");    


    // reset to normal
    resetn <= 1'b0;
    repeat (4) @(posedge clk);   
    resetn <= 1'b1;
    @(posedge clk);   


    // test - writing into a register and reading it back
    // --------------------------------------------------
        // writing
    i_wr_en <= 1'b1;
    i_wr_addr <= 2'd2;
    i_wr_data <= 32'hFFFFFFFF;
    i_wr_strb <= 4'b1111;
    @(posedge clk);   
    i_wr_en <= 1'b0;
    @(posedge clk);   
        // reading
    i_rd_en <= 1'b1;
    i_rd_addr <= 2'd2;
    @(posedge clk);
    i_rd_en <= 1'b0;
    @(posedge clk);
    if (o_r_rd_data == i_wr_data)
        $display("Test passed");
    else
        $display("Test Failed");    


    // reset to normal
    resetn <= 1'b0;
    repeat (4) @(posedge clk);   
    resetn <= 1'b1;
    @(posedge clk);   


    // test - writing a value and writng a strobe value and check by reading it
    // -------------------------------------------------------------------
        // writing full value
    i_wr_en <= 1'b1;
    i_wr_addr <= 2'd2;
    i_wr_data <= 32'hFFFFFFFF;
    i_wr_strb <= 4'b1111;
    @(posedge clk);   
    i_wr_en <= 1'b0;
    @(posedge clk);   
        // writing strobe editing small part
    i_wr_en <= 1'b1;
    i_wr_addr <= 2'd2;
    i_wr_data <= 8'h00;
    i_wr_strb <= 4'b0100;
    @(posedge clk);
    i_wr_en <= 1'b0;
    @(posedge clk);
        // reading
    i_rd_en <= 1'b1;
    i_rd_addr <= 2'd2;
    @(posedge clk);
    i_rd_en <= 1'b0;
    @(posedge clk);

    $finish;

end
endmodule
