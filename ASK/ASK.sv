// =============================================================================
//  ASK.sv  –  Modulador ASK (Amplitude Shift Keying)
//  Chaveamento pelo sinal externo data_in (onda quadrada do top_level)
//
//  data_in = 0 → ganho 1.0  (amplitude cheia)
//  data_in = 1 → silêncio   (gain = 0)
//
//  Correções aplicadas:
//    - COEF ímpar para melhor comportamento em ponto fixo
//    - YN2_INIT correto para 1000 Hz
//    - Clamp em yn_v para evitar divergência numérica
//    - out_v com largura correta para o produto yn_v * gain (era 18 bits, overflow)
// =============================================================================
module ASK #(
    parameter int Q        = 14,
    parameter int CLK_FREQ = 97_656,

    parameter logic signed [(Q+1):0] COEF     = 'sd32699,  // 1000 Hz (ímpar)
    parameter logic signed [(Q+1):0] YN1_INIT = 'sd16384,
    parameter logic signed [(Q+1):0] YN2_INIT = 'sd16375   // calculado para 1000 Hz
)(
    input  logic clk,
    input  logic clk_ce,
    input  logic rst,
    input  logic data_in,
    output logic signed [(Q+1):0] out
);

    logic signed [(Q+1):0]     yn1, yn2;
    logic signed [(Q+1):0]     gain;

    logic signed [(Q*2+3):0]   temp_v;
    logic signed [(Q+1):0]     yn_v;
    logic signed [(Q*2+3):0]   out_v;   // BUG CORRIGIDO: era (Q+3) — overflow no produto

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            yn1  <= YN1_INIT;
            yn2  <= YN2_INIT;
            gain <= (1 <<< Q);
            out  <= '0;
        end else if (clk_ce) begin

            // chaveamento pelo data_in
            if (data_in == 1'b0)
               gain <= 0;           // silêncio
				else
					gain <= (1 <<< Q);   // amplitude cheia
                

            // oscilador IIR
            temp_v = COEF * yn1;
            yn_v   = (temp_v >>> Q) - yn2;

            // clamp para evitar divergência numérica
            if (yn_v > (1 <<< Q))
                yn_v = (1 <<< Q);
            else if (yn_v < -(1 <<< Q))
                yn_v = -(1 <<< Q);

            yn2   <= yn1;
            yn1   <= yn_v;

            // aplica ganho e escala de volta para Q14
            out_v  = yn_v * gain;
            out   <= out_v >>> Q;
        end
    end

endmodule