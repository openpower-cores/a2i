#!/usr/bin/env python3

"""VUnit run script."""

from pathlib import Path
from vunit import VUnit

_rel = Path(__file__).parent / "rel"

prj = VUnit.from_argv()

for libName in ["support", "ibm", "clib", "tri"]:
    prj.add_library(libName).add_source_files(_rel / "src" / "vhdl" / f"{libName}" / "*.vhdl")

# VUnit doesn't accept libraries named work. These files are compiled to the top library
prj.add_library("top").add_source_files(_rel / "src" / "vhdl" / "work" / "*.vhdl")

# Simulation only library containing VHDL mocks for Verilog UNIMACROs
prj.add_library("unimacro").add_source_files(_rel / "sim" / "unimacro" / "*.vhdl")

prj.main()
