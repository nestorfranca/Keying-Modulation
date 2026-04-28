module sigma_delta #(
    parameter Q = 14
)(
    input  logic clk,
    input  logic clk_ce,
    input  logic rst,
    input  logic signed [(Q+1):0] input_signal,
    output logic out
);

    logic signed [(Q+4):0] integrator;  // 🔥 AUMENTEI 1 BIT
    logic signed [(Q+1):0] feedback;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            integrator <= '0;
            feedback   <= '0;
            out        <= 0;
        end else begin
            if (clk_ce) begin
                logic signed [(Q+2):0] diff;
                logic signed [(Q+4):0] next_integrator;

                // 🔥 MELHOR CONTROLE DE SINAL
                diff = input_signal - feedback;

                next_integrator = integrator + diff;
                integrator <= next_integrator;

                if (next_integrator >= 0) begin
                    out      <= 1'b1;
                    feedback <=  (1 <<< Q);
                end else begin
                    out      <= 1'b0;
                    feedback <= -(1 <<< Q);
                end 
            end
        end
    end

endmodule