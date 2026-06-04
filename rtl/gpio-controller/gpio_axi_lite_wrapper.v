module gpio_axi_lite_wrapper#(
    parameter INPUT_ADDR_WIDTH = 32,
    parameter INPUT_DATA_WIDTH = 32,
    parameter INPUT_STROBE_WIDTH = 4,
    parameter OUTPUT_ADDR_WIDTH = 3,
    parameter OUTPUT_STROBE_WIDTH = 4,
    parameter OUTPUT_DATA_WIDTH = 32
)(
    input aclk, 
    input aresetn, // not asynchronous reset just AXI_reset_negative (active low)
    
    // AXI write addr channel
    input s_axi_awvalid,
    input [INPUT_ADDR_WIDTH - 1:0] s_axi_awaddr,
    output reg s_axi_awready,
    // AXI write data channel
    input s_axi_wvalid,
    input [INPUT_DATA_WIDTH - 1:0] s_axi_wdata,
    input [INPUT_STROBE_WIDTH - 1:0] s_axi_wstrb,
    output reg s_axi_wready,
    // AXI write response
    input s_axi_bready,
    output reg s_axi_bvalid,
    output reg [1:0] s_axi_bresp,
    // AXI read addr channel 
    input s_axi_arvalid, 
    input [INPUT_ADDR_WIDTH - 1:0] s_axi_araddr, 
    output reg s_axi_arready, 
    // AXI read data channel 
    output reg s_axi_rvalid, 
    output reg [INPUT_DATA_WIDTH - 1:0] s_axi_rdata, 
    output reg s_axi_rresp, 
    input s_axi_rready,

    output reg o_r_wr_en,
    output reg [OUTPUT_ADDR_WIDTH - 1:0] o_r_wr_addr, 
    output reg [OUTPUT_DATA_WIDTH - 1:0] o_r_wr_data,
    output reg [OUTPUT_STROBE_WIDTH - 1:0] o_r_wr_strb,

    output reg o_r_rd_en,
    output reg [OUTPUT_ADDR_WIDTH - 1:0] o_r_rd_addr,
    input  [OUTPUT_DATA_WIDTH - 1:0] i_rd_data

); 

localparam ST_W_IDLE = 2'b00;
localparam ST_WRITE = 2'b01;
localparam ST_W_RESP = 2'b10;

localparam ST_R_IDLE = 2'b00;
localparam ST_READ  = 2'b01;
localparam ST_WAIT = 2'b10;
localparam ST_R_RESP = 2'b11;


reg [1:0] w_curr_st;
reg [1:0] w_nxt_st; // will be inferred as wire 

reg [1:0] r_curr_st;
reg [1:0] r_nxt_st; // will be inferred as wire 

always @(*) begin
    w_nxt_st = w_curr_st; // <-- Fixed: Pre-assign default to prevent latches completely   
    case (w_curr_st)
        ST_W_IDLE:begin
            if (s_axi_awvalid & s_axi_wvalid)
                w_nxt_st = ST_WRITE;
        end
        ST_WRITE:begin
            w_nxt_st = ST_W_RESP;
        end        
        ST_W_RESP:begin
            if (s_axi_bready)
                w_nxt_st = ST_W_IDLE;
        end
        default:
            w_nxt_st = w_curr_st;
    endcase
end

always @(posedge aclk) begin
    if (!aresetn)
        w_curr_st <= ST_W_IDLE;
    else
        w_curr_st <= w_nxt_st;
end

always @(posedge aclk) begin
    if (!aresetn) begin
        s_axi_awready <= 1'b0;
        s_axi_wready <= 1'b0;    
        s_axi_bvalid <= 1'b0;
        s_axi_bresp <= 2'b00;

        w_addr <= 0;
        w_data <= 0;
        w_en <= 1'b0;               
    end
    else begin
        // look ahdead next state, so output and curr state updates at the next edge
        case (w_nxt_st)
            ST_W_IDLE:begin
                s_axi_bvalid <= 1'b0;
                s_axi_bresp <= 2'b00;     
                s_axi_awready <= 1'b1;
                s_axi_wready <= 1'b1;
    
            end
            ST_WRITE:begin
                s_axi_awready <= 1'b0;
                s_axi_wready <= 1'b0; 

                w_addr <= s_axi_awaddr[4:2];
                w_data <= s_axi_wdata;
                w_en <= 1'b1;

            end        
            ST_W_RESP:begin
                s_axi_bvalid <= 1'b1;
                s_axi_bresp <= 2'b00; 

                w_en <= 1'b0;            

            end
            default:begin
                s_axi_awready <= 1'b0;
                s_axi_wready <= 1'b0;    
                s_axi_bvalid <= 1'b0;
                s_axi_bresp <= 2'b00;                    
            end
        endcase 
    end
end 

always @(*) begin 
    r_nxt_st = r_curr_st;    
    case (r_curr_st)
        ST_R_IDLE:begin
            // Just wait in the state, until the valid signal comes
            if (s_axi_arvalid)
                r_nxt_st = ST_READ;    
        end
        ST_READ:begin
            r_nxt_st = ST_WAIT;    
        end
        ST_WAIT:begin
            r_nxt_st = ST_R_RESP;                
        end
        ST_R_RESP:begin
            if (s_axi_rready) begin
                r_nxt_st = ST_R_IDLE;    
            end
        end                
        default:
            r_nxt_st = r_curr_st;
    endcase
end

always @(posedge aclk) begin 
    if (!aresetn)
        r_curr_st <= ST_R_IDLE;
    else
        r_curr_st <= r_nxt_st;
end

always @(posedge aclk) begin 
    case (r_nxt_st) 
        ST_R_IDLE:begin
            s_axi_arready <= 1'b1;            
            s_axi_rvalid <= 1'b0;
        end
        ST_READ:begin
            s_axi_arready <= 1'b0;                  
            r_addr <= s_axi_araddr[4:2];
            r_en <= 1'b1;
        end
        ST_WAIT:begin
            r_en <= 1'b0;   
        end
        ST_R_RESP:begin
            s_axi_rvalid <= 1'b1;
            s_axi_rdata <= r_data;                     
        end                
        default:begin
            s_axi_rvalid <= 1'b0;
            s_axi_rdata <= 32'b0;          
            r_en <= 1'b0;         
            r_addr <= 1'b0;                             
        end
    endcase
end

endmodule
