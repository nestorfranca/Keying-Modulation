// =============================================================================
//  reescala.sv  –  Redução de amplitude por deslocamento aritmético
//  SHIFT=3 → divide amplitude por 8
// =============================================================================
module reescala #(
    parameter Q     = 14,
    parameter SHIFT = 1
)(
    input  logic signed [(Q+1):0] in,
    output logic signed [(Q+1):0] out
);

    always_comb begin
        out = in >>> SHIFT;
    end

endmodule
