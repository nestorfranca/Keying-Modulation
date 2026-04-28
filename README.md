## Keying-Modulation
Este repositório apresenta a implementação e simulação de técnicas clássicas de modulação digital por chaveamento (Keying Modulation).

# Configuração para o ASK


    
    vsim work.tb_top_level

    delete wave *
    view wave

    add wave -label "square_out" /tb_top_level/square_out
    add wave -label "gain"       -radix dec /tb_top_level/dut/u_mod/gain
    add wave -label "scaled_out" -format analog -max 2048 -min -2048 -height 74 /tb_top_level/dut/scaled_out
    add wave -label "dac_out"    /tb_top_level/dac_out

    run 300ms
    wave zoom full

# Configuração para o FSK

    vsim work.tb_top_level

    delete wave *
    view wave
    
    add wave -label "square_out" /tb_top_level/square_out
    add wave -label "coef"       -radix dec /tb_top_level/dut/u_mod/coef
    add wave -label "scaled_out" -format analog -max 2048 -min -2048 -height 74 /tb_top_level/dut/scaled_out
    add wave -label "dac_out"    /tb_top_level/dac_out

    run 300ms
    wave zoom full

# Configuração para o PSK

    vsim work.tb_top_level

    delete wave *
    view wave

    add wave -label "square_out" /tb_top_level/square_out
    add wave -label "phase"      -radix dec /tb_top_level/dut/u_mod/phase
    add wave -label "scaled_out" -format analog -max 2048 -min -2048 -height 74 /tb_top_level/dut/scaled_out
    add wave -label "dac_out"    /tb_top_level/dac_out

    run 300ms
    wave zoom full