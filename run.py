#!/usr/bin/env python3

"""VUnit run script."""

from pathlib import Path
from vunit import VUnit

prj = VUnit.from_argv()

_rel = Path(__file__).parent / "rel"

library_names = ["support", "ibm", "clib", "tri"]
for library_name in library_names:
    prj.add_library(library_name).add_source_files(
        _rel / f"src/vhdl/{library_name}/*.vhdl"
    )

# VUnit doesn't accept libraries named work. These files are compiled to the top library
prj.add_library("top").add_source_files(_rel / "src/vhdl/work/*.vhdl")

# Simulation only library containing VHDL mocks for Verilog UNIMACROs
prj.add_library("unimacro").add_source_files(_rel / "sim/unimacro/*.vhdl")

prj.main()
