Project name  : PROJ-NAME
Release       : V.R
Date          : YYYY-MM-DD

General Description
--------------------------------------------------------------------------

Version control
--------------------------------------------------------------------------

Directory structure
--------------------------------------------------------------------------

DOC
	DOX_HDL : Auto-generated Doxygen documentation

HDL
	RTL	: Synthesized RTL codes.
	BHV	: Behavioral codes.
	TB	: Testbenches.

LA
	Logic analyzer waveform and screenshots

PYTHON

VIVADO
	BIN    : Binary files
	CONSTR : Constraint files
	IMPL   : Implementation files
	SYNTH  : Synthesis files
	TCL    : Vivado scripts
	WORK   : Working directory for TCL based operations

Hardware
--------------------------------------------------------------------------

Connections
--------------------------------------------------------------------------

Simulation
--------------------------------------------------------------------------

Synthesis
--------------------------------------------------------------------------

Vivado in TCL mode:

	Go to VIVADO/WORK directory.
	cmd
	vivado -mode tcl
	source ../TCL/build.tcl

Implementation results:

  - Area  :
  - Speed :

Programming the FPGA
--------------------------------------------------------------------------

Run program.tcl to program the FPGA:

	vivado -mode tcl
	source ../TCL/program.tcl

Run flash.tcl to program the configuration flash memory:
	
	source ../TCL/flash.tcl

Verification
--------------------------------------------------------------------------

Notes
--------------------------------------------------------------------------

Revision history
--------------------------------------------------------------------------

--------------------------------------------------------------------------
END OF README
--------------------------------------------------------------------------
