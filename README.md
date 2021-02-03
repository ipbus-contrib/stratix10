IPbus for Intel Stratix 10 MX 2100
==================================

The top folder of the repo has them same structure of the IPbus firmware repository.
One folder is added, _Stratix10mx2100_project_, which containes all the Intel dedicated files.

## The project

To build the project Intel Quartus Pro v19.2 is recommended.

The main project files are placed in the folder Stratix10mx2100_project:

- tcl file to build the project: _monitoring.tcl_
- project top level: _Monitoring.vhd_
- ipbus top level (instantiad in Monitoring.vhd): _ipbus_top.vhd_
- project constraints: _monitoring.out.sdc_

In the folder _imported_from_design_example_ one can find an updated version on the project example provided by Intel.

### Building the Intel project

Open Quartus and in the tcl console cd to the _Stratix10mx2100_project_ folder, e.g.:

`cd c:/Users/myuser/Documents//ipbus_for_intel/Stratix10mx2100_project`

Source the tcl file to create the project file, with extension `.qpf`, as follow:

`source monitoring.tcl`

From the Quartus menu go to File -> Open Project and select monitoring.qpf, or simply double click on monitoring.qpf.

### Compiling the code

To prodice the binary file, in the Quartus Compilation Dashboard, double click on the Assembler step.
This will produce, in the auto generate folder _output_files_, the binary file with extension .bit.







