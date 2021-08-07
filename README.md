![](https://github.com/openpower-cores/a2i/workflows/VUnit%20Tests/badge.svg)

# A2I

## NOTICE

The license has been modified (see the LICENSE file for details), and the repository is moving soon to an OpenPower Foundation location.

The new repo will be accessible through both Github and Gitlab.

After the move is completed, this readme will be updated, and the repo will be changed to 'archived' state.

## The Project
Release of the A2I POWER processor core RTL and associated FPGA implementation (used ADM-PCIE-9V3 FPGA)

See [Project Info](rel/readme.md) for details.

## The Core
The [A2I core](rel/doc/A2_BGQ.pdf) was created as a high-frequency four-threaded design, optimized for throughput and targeted for 3+ GHz in 45nm technology.

It is a 27 FO4 implementation, with an in-order pipeline supporting 1-4 threads.  It fully supports Power ISA 2.06 using Book III-E.  The core was also designed to support pluggable implementations of MMU and AXU logic macros.  This includes elimination of the MMU and using ERAT-only mode for translation/protection.

## The History

The [A2I platform](rel/doc/a2_1.png) was developed following IBM's game core designs.  It was designed to balance performance and power and provide high streaming throughput.  It supported chip, sim, and FPGA implementations through the use of a configurable latch/array library.

A2I was developed as the "wire-speed processor" for a high-throughput edge-of-network (PowerEN) [SoC design](rel/doc/w_2.png).  This [chip](rel/doc/w_1.png) included four L2's with four A2I per L2, connected through an interconnect called PBus.  The units outside the core included multiple accelerators attached to the PBus.  External interfaces included DDR3, PCI Gen2, and Ethernet.  The chip was built and performed at ~2.3GHz (the core was throttled for power savings), but was not released.

The A2I core was then selected as the general purpose processor for [BlueGene/Q, the successor to BlueGene/L and BlueGene/P supercomputers](https://www.ibm.com/ibm/history/ibm100/us/en/icons/bluegene).  In this [design](rel/doc/HC23.18.121.BlueGene-IBM_BQC_HC23_20110818.pdf), eighteen A2I cores were included on one chip, along with cache and memory controllers, and internal networking components.  The design ran at 1.6 GHz, to meet power/performance goals, and included a special-purpose AXU (high-bandwidth FPU).  Multiple BlueGene/Q installations have been ranked in the top 10 of the TOP500 list for many years
([#1,#3,#7,#8 in 2012](https://www.top500.org/lists/2012/06/)), and
[three](https://www.top500.org/lists/top500/2020/06/)
are still ranked in the TOP500 as of June 2020.

## The Future

There may be uses for this core where a full feature-set is needed, and its limitations can be overcome by the intended environment.  Specifically, single-thread performance is limited by the in-order implementation, requiring a well-behaved application set to enable efficient use of the pipeline to cover pipeline dependencies, branch misprediction, etc.

The design of the A2L2 interface (core-to-L2/nest) is straightforward, and offers multiple configurable options for data interfacing.  There is also some configurability for handling certain Power-specific features (core vs. L2).

The ability to add an AXU that is tightly-coupled to the core enables many possibilities for special-purpose designs, like an open distributed Web 3.0 hardware/software system integrating streaming encryption, blockchain, semantic query, etc.

### Technology Scaling

A comparison of the design in original technology and scaled to 7nm (fixed-point, no MMU):

|      |Freq     |Pwr    |Freq Sort|Pwr Sort|Area     |Vdd    |
|-----:|---------|-------|---------|--------|---------|-------|
|45nm  |2.30 GHz |0.88 W |         |        |2.90 mm<sup>2</sup> |0.97 V |
| 7nm  |3.90 GHz |0.44 W |4.17 GHz |0.47 W  |0.17 mm<sup>2</sup> |1.1  V |
| 7nm  |3.75 GHz |0.35 W |4.03 GHz |0.37 W  |0.17 mm<sup>2</sup> |1.0  V |
| 7nm  |3.55 GHz |0.27 W |3.87 GHz |0.29 W  |0.17 mm<sup>2</sup> |0.9  V |
| 7nm  |3.07 GHz |0.18 W |3.60 GHz |0.21 W  |0.17 mm<sup>2</sup> |0.8  V |
| 7nm  |2.40 GHz |0.08 W |3.00 GHz |0.14 W  |0.17 mm<sup>2</sup> |0.7  V |

These estimates are based on a semicustom design in representative foundry processes (IBM 45nm/Samsung 7nm).

### Compliancy

The A2I core is compliant to Power ISA 2.06 and will need updates to be compliant with either version 3.0c or 3.1.  Power ISA 3.0c and 3.1 are the two Power ISA versions contributed to OpenPOWER Foundation by IBM.  Changes will include:

* radix translation
* op updates, to eliminate noncompliant ones and add missing ones required for a given compliancy level
* various 'mode' and other changes to meet the open specification targeted compliancy level

## Miscellaneous

1. PVR = Ver 48/Rev 2
