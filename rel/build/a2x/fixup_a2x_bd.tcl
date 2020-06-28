open_bd_design "[get_property DIRECTORY [current_project]]/proj_a2x_axi.srcs/sources_1/bd/a2x_axi_bd/a2x_axi_bd.bd"

set_property SCREENSIZE {1 1} [get_bd_cells /pain]
set_property location {5 1506 2372} [get_bd_cells pain]
set_property SCREENSIZE {1 1} [get_bd_cells /thold_0]
set_property SCREENSIZE {1 1} [get_bd_cells /xlconstant_0]
set_property location {6 2778 2069} [get_bd_cells xlconstant_0]
set_property SCREENSIZE {1 1} [get_bd_cells /xlconstant_1]
set_property location {6 2734 2210} [get_bd_cells xlconstant_1]

# so xil actually connects as bus
set_property SCREENSIZE {1 1} [get_bd_cells /mchk_rv]
set_property location {6 2767 2847} [get_bd_cells mchk_rv]
set_property SCREENSIZE {1 1} [get_bd_cells /rcov_rv]
set_property location {6 2777 2748} [get_bd_cells rcov_rv]
set_property SCREENSIZE {1 1} [get_bd_cells /checkstop_rv]
set_property location {7 2850 2630} [get_bd_cells rcov_rv]
set_property SCREENSIZE {1 1} [get_bd_cells /scomdata_rv]
set_property location {4 1355 2564} [get_bd_cells scomdata_rv]
set_property SCREENSIZE {1 1} [get_bd_cells /thread_running_rv]
set_property location {5 2152 2682} [get_bd_cells thread_running_rv]
set_property SCREENSIZE {1 1} [get_bd_cells /axi_reg00_rv]
set_property location {7 3176 2490} [get_bd_cells axi_reg00_rv]
set_property SCREENSIZE {1 1} [get_bd_cells /reverserator_4_0]
set_property location {7 2156 2797} [get_bd_cells reverserator_4_0]



set_property SCREENSIZE {600 600} [get_bd_cells /a2x_axi_1]
set_property location {5 2000 1000} [get_bd_cells /a2x_axi_1]
set_property location {4 1306 1980} [get_bd_cells a2x_dbug]

set_property location {4.5 1482 792} [get_bd_cells jtag_axi_0]

set_property location {4 1259 2326} [get_bd_cells vio_dbug] ;# no orientation, highlight, etc.
set_property location {5 1957 2377} [get_bd_cells vio_ctrl]
set_property location {6 2704 2401} [get_bd_cells vio_terror]
set_property location {7 3253 2629} [get_bd_cells vio_reg]

set_property location {10.5 4307 861} [get_bd_cells blk_mem_gen_1]
set_property location {11 4297 974} [get_bd_cells blk_mem_gen_2]

set_property location {6 2034 684} [get_bd_cells axi_smc]

set_property location {7 3129 422} [get_bd_cells ila_axi]
set_property location {9 3542 548} [get_bd_cells ila_axi_protocol]
set_property location {7 3173 580} [get_bd_cells axi_protocol_checker]

save_bd_design

