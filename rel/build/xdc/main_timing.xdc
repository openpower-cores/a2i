set_false_path -from [get_clocks -of_objects [get_pins a2x_axi_bd_i/a2x_reset_0/U0/clk]] -to [get_clocks clk]
set_false_path -from [get_clocks -of_objects [get_pins a2x_axi_bd_i/a2x_reset_0/U0/clk]] -to [get_clocks clk2x]
