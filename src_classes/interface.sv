//-----------------------------------------------------------------------------
//  Title       : AHB Interface
//  File        : ahb_intf.sv
//  Author      : Ahmed Raza
//  Created     : 10-Oct-2024
//-----------------------------------------------------------------------------
//  Description :
//  This interface defines the AHB slave interface signals and clocking blocks
//  used for communication between the AHB master and slave. It also includes
//  the modports for driver and monitor to handle read/write operations and 
//  synchronization with the respective clocking blocks.
//-----------------------------------------------------------------------------
//  Revisions   :
//  Date        : 10-Oct-2024
//  Version     : 1.0
//  Comments    : Initial version with well-organized port declarations and 
//                clocking blocks for driver and monitor.
//-----------------------------------------------------------------------------



interface ahb_intf #(parameter HADDR_SIZE = 32, parameter HDATA_SIZE = 32)
  (input logic HCLK, HRESETn);

  //-------------------------------------------------------------------------
  // AHB Slave Interfaces
  // These signals are received by the AHB slave from the AHB master. The 
  // master initiates communication by driving these signals.
  //-------------------------------------------------------------------------

  logic                       HSELx;        // Slave select signal
  logic      [HADDR_SIZE-1:0] HADDR;       // Address bus
  logic      [HDATA_SIZE-1:0] HWDATA;      // Write data bus
  logic      [HDATA_SIZE-1:0] HRDATA;      // Read data bus
  logic                       HWRITE;      // Write control signal
  logic      [           2:0] HSIZE;       // Transfer size
  logic      [           2:0] HBURST;      // Burst type
  logic      [           3:0] HPROT;       // Protection control
  logic      [           1:0] HTRANS;      // Transfer type
  logic                       HREADYOUT;   // Ready output signal from slave
  logic                       HREADY;      // Ready input signal to master
  logic                       HRESP;       // Response signal

  //-------------------------------------------------------------------------
  // Driver Clocking Block
  // This block defines the signals driven by the driver during simulation, 
  // synchronized to the rising edge of HCLK.
  //-------------------------------------------------------------------------

  clocking driver_cb @(posedge HCLK);
    default input #1 output #1;
    output                       HSELx;
    output                       HADDR;
    output                       HWDATA;
    output                       HWRITE;
    output                       HSIZE;
    output                       HBURST;
    output                       HPROT;
    output                       HTRANS;
    output                       HREADY;
    input                        HRDATA;
    input                        HREADYOUT;
    input                        HRESP;
  endclocking

  //-------------------------------------------------------------------------
  // Monitor Clocking Block
  // This block captures the signals driven by the AHB master and slave. The 
  // monitor observes and records these signals for comparison and debugging.
  //-------------------------------------------------------------------------

  clocking monitor_cb @(posedge HCLK);
    default input #1 output #1;
    input                        HSELx;
    input                        HADDR;
    input                        HWDATA;
    input                        HWRITE;
    input                        HSIZE;
    input                        HBURST;
    input                        HPROT;
    input                        HTRANS;
    input                        HREADY;
    input                        HRDATA;
    input                        HREADYOUT;
    input                        HRESP;
  endclocking

  //-------------------------------------------------------------------------
  // Modport for Driver
  // Allows the driver to drive the necessary signals through the clocking 
  // block and access HCLK and HRESETn.
  //-------------------------------------------------------------------------
  modport DRIVER (
    clocking driver_cb,
    input HRESETn,
    input HCLK
  );

  //-------------------------------------------------------------------------
  // Modport for Monitor
  // Allows the monitor to observe the necessary signals through the clocking 
  // block and access HCLK and HRESETn.
  //-------------------------------------------------------------------------
  modport MONITOR (
    clocking monitor_cb,
    input HRESETn,
    input HCLK
  );

endinterface
