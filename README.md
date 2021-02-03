# IPbus for Intel Stratix 10 MX 2100

To build the project Intel Quartus Pro v19.2 is recommended.

All the IPbus code sits into _IPbus_code_ folder.

The main project files are placed in the folder Stratix10mx2100_project:

- tcl file to build the project: _monitoring.tcl_
- project top level: _Monitoring.vhd_
- ipbus top level (instantiad in Monitoring.vhd): _ipbus_top.vhd_
- project constraints: _monitoring.out.sdc_

In the folder _imported_from_design_example_ one can find an updated version on the project example provided by Intel.

In the folders _/PHY_MAC_setup/system_console_ the set of scripts to setup the firwmare from the system console, for hardware tests, is also available.

## From the Quartus GUI

### Project creation

Open Quartus and in the tcl console cd to the _Stratix10mx2100_project_ folder, e.g.:

`cd c:/Users/myuser/Documents//ipbus_for_intel/Stratix10mx2100_project`

Source the tcl file to create the project file, with extension `.qpf`, as follow:

`source monitoring.tcl`

From the Quartus menu go to File -> Open Project and select monitoring.qpf, or simply double click on monitoring.qpf.
The intermediate steps (Synthesis, Fitting, Timing Analysis, etc.) are also available in the GUI.

### Compiling the code

To prodice the binary file, in the Quartus Compilation Dashboard, double click on the Assembler step.
This will produce, in the auto generate folder _output_files_, the binary file with extension .bit.

## From the command line

### Project creation

Make sure you licence is properly setup:

`export LM_LICENSE_FILE="1800@lixlicen01,1800@lxlicen02,1800@lxlicen03"`

Open the folder where the tcl file of the project is placed:

`cd c:/Users/myuser/Documents//ipbus_for_intel/Stratix10mx2100_project`

Generate the project file:

`quartus_sh -t monitoring.tcl`

### Compiling the code

The following steps are needed to compile the code and generate a binary file:

1. Running Quartus Prime IP Generation Tool 

`quartus_ipgenerate --run_default_mode_op monitoring -c monitoring`

2. Runnign Quartus Prime Analysis and Synthesis

`quartus_syn --read_settings_files=on --write_settings_files=off monitoring -c monitoring`

3. Running Quartus Prime Fitter (complete)

`quartus_fit --read_settings_files=on --write_settings_files=off monitoring -c monitoring --plan --place --route --retime --finalize`

4. Running Quartus Prime Assembler

`quartus_asm --read_settings_files=on --write_settings_files=off monitoring -c monitoring`


## How to run a test in hardware

To run a tests in hardware, with a Stratix 10 MX development kit, please [refer to this link](http://prm-fw-docs.web.cern.ch/03_hw_testing/02_ethernet_standalone_tests/).







