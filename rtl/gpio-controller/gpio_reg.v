module gpio_reg#(
    parameter ADDR_WIDTH = 3,
    parameter DATA_WIDTH = 32,
    parameter STROBE_WIDTH = 4
)
(
    input clk, 
    input resetn,

    input i_rd_en,
    input [ADDR_WIDTH - 1:0] i_rd_addr,
    output reg [DATA_WIDTH - 1:0] o_r_rd_data,

    input i_wr_en,
    input [ADDR_WIDTH - 1:0] i_wr_addr,
    input [DATA_WIDTH - 1:0] i_wr_data,
    input [STROBE_WIDTH - 1:0] i_wr_strb,

    input [DATA_WIDTH - 1:0] i_gpio_pin_data,

    // output wire driven through internal register map
    output [DATA_WIDTH - 1:0] o_rmap_dir,  
    output [DATA_WIDTH - 1:0] o_rmap_data,
    output [DATA_WIDTH - 1:0] o_rmap_ie,
    output [DATA_WIDTH - 1:0] o_rmap_is,
    output [DATA_WIDTH - 1:0] o_rmap_ic,
    output [DATA_WIDTH - 1:0] o_rmap_alt,
    output [DATA_WIDTH - 1:0] o_rmap_itype,        
    output [DATA_WIDTH - 1:0] o_rmap_ipol            
);

localparam  [2:0] DIR_REG_ADDR = 3'b000; // direction
localparam  [2:0] DATA_REG_ADDR = 3'b001; // both read and write
localparam  [2:0] IE_REG_ADDR = 3'b010; // Interrupt enable
localparam  [2:0] IS_REG_ADDR = 3'b011; // Interrupt status
localparam  [2:0] IC_REG_ADDR = 3'b100; // Interrupt clear
localparam  [2:0] ALT_REG_ADDR = 3'b101; // (Alternate function)
localparam  [2:0] ITYP_REG_ADDR = 3'b110; // Interrupt type (Edge or lvl triggered)
localparam  [2:0] IPOL_REG_ADDR = 3'b111; // Interrupt polarity

reg [DATA_WIDTH - 1 : 0] REG_MAP[0:7];

assign o_rmap_dir      = REG_MAP[DIR_REG_ADDR];
assign o_rmap_data     = REG_MAP[DATA_REG_ADDR];
assign o_rmap_ie       = REG_MAP[IE_REG_ADDR];
assign o_rmap_is       = REG_MAP[IS_REG_ADDR];
assign o_rmap_ic       = REG_MAP[IC_REG_ADDR];
assign o_rmap_alt      = REG_MAP[ALT_REG_ADDR];
assign o_rmap_itype    = REG_MAP[ITYP_REG_ADDR];        
assign o_rmap_ipol     = REG_MAP[IPOL_REG_ADDR];

function [DATA_WIDTH - 1:0] apply_strb;
    input [DATA_WIDTH - 1:0] old_val;
    input [DATA_WIDTH - 1:0] new_val;
    input [STROBE_WIDTH - 1:0] strb;
    integer b;
    begin
        apply_strb = old_val;
        for (b = 0; b < 4; b++) begin
            if (strb[b])
              apply_strb[8*b +: 8] = new_val[8*b +: 8]; 
        end
    end
endfunction


always @(posedge clk) begin
    if (!resetn) begin
        REG_MAP[0] <= {DATA_WIDTH{1'b0}};
        REG_MAP[1] <= {DATA_WIDTH{1'b0}};
        REG_MAP[2] <= {DATA_WIDTH{1'b0}};
        REG_MAP[3] <= {DATA_WIDTH{1'b0}};
        REG_MAP[4] <= {DATA_WIDTH{1'b0}};
        REG_MAP[5] <= {DATA_WIDTH{1'b0}};
        REG_MAP[6] <= {DATA_WIDTH{1'b0}};
        REG_MAP[7] <= {DATA_WIDTH{1'b0}};
    end
    else begin
        if (i_wr_en) begin
            if (i_wr_addr != IS_REG_ADDR) begin
                REG_MAP[i_wr_addr] <= apply_strb(REG_MAP[i_wr_addr], i_wr_data, i_wr_strb);
            end
            // do nothing in else logic when the write address is not Interrupt status
        end
        if (i_rd_en) begin
            case (i_rd_addr)
                IC_REG_ADDR: begin 
                    // TODO: In future add error reporting signals to axi lite
                    // so axi lite makes an error response
                    o_r_rd_data <= {DATA_WIDTH{1'b0}};                    
                end
                DATA_REG_ADDR: begin 
                    // when data register is read, give the inputs from the pin interace module which is synced input
                    o_r_rd_data <= i_gpio_pin_data;                 
                end
                default: begin
                    o_r_rd_data <= REG_MAP[i_rd_addr];
                end
            endcase
        end
    end
end
endmodule
