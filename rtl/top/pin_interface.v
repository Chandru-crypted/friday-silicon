// Note: This is not a part of GPIO controller.
// It is just an electrical interface for the pad which can be driven as input and output
module pin_interface#(
    parameter WIDTH_GPIO_PADS = 32
)
(
    input clk,
    input resetn, 
    input [WIDTH_GPIO_PADS - 1 : 0] i_dir_gpio_pad,
    input [WIDTH_GPIO_PADS - 1 : 0] i_out_data_gpio_pad,
    inout [WIDTH_GPIO_PADS - 1 : 0] io_gpio_pad,
    output [WIDTH_GPIO_PADS - 1 : 0] o_gpio_synced_pad
);

    // Output, check direction reg and drive the output,
    // if configured as input, dirve High impedance.
    assign io_gpio_pad = i_dir_gpio_pad ? i_out_data_gpio_pad : 1'bz;
    
    // Input
    two_stage_FF_sync gpio_pads_sync #(
        WIDTH_INPUT_TO_SYNC = WIDTH_GPIO_PADS
    )(
        .clk(clk),
        .resetn(resetn),
        .i_w_pads_to_sync(io_gpio_pad),
        .o_w_synced_pad(o_gpio_synced_pad)
    );
endmodule

module two_stage_FF_sync#(
    parameter WIDTH_INPUT_TO_SYNC = 32
)
(
    input clk,
    input resetn,     
    input [WIDTH_INPUT_TO_SYNC - 1 : 0] i_w_pads_to_sync,
    output [WIDTH_INPUT_TO_SYNC - 1 : 0] o_w_synced_pad
);
    reg [WIDTH_INPUT_TO_SYNC - 1 : 0] r_sync_pad1, r_sync_pad2;
    assign o_w_synced_pad = r_sync_pad2;

    always @(posedge clk) begin
        if (!resetn) begin
            r_sync_pad1 <= {WIDTH_INPUT_TO_SYNC{1'b0}};
            r_sync_pad2 <= {WIDTH_INPUT_TO_SYNC{1'b0}};
        end
        else begin
            r_sync_pad1 <= i_w_pads_to_sync;
            r_sync_pad2 <= r_sync_pad1;
        end
    end 

endmodule
