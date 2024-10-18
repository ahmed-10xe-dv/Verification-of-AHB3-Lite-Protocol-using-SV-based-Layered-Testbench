
/////////////////////////////////////////////////////////////////////
//   ,------.                    ,--.                ,--.          //
//   |  .--. ' ,---.  ,--,--.    |  |    ,---. ,---. `--' ,---.    //
//   |  '--'.'| .-. |' ,-.  |    |  |   | .-. | .-. |,--.| .--'    //
//   |  |\  \ ' '-' '\ '-'  |    |  '--.' '-' ' '-' ||  |\ `--.    //
//   `--' '--' `---'  `--`--'    `-----' `---' `-   /`--' `---'    //
//                                             `---'               //
//   AHB3-Lite Driver                                               //
//                                                                 //
/////////////////////////////////////////////////////////////////////
//                                                                 //
//             Copyright (C) 2024 10xEngineers                    //
//             www.10xengineers.com                                 //
//                                                                 //
/////////////////////////////////////////////////////////////////////


// +FHDR -  Semiconductor Reuse Standard File Header Section  -------
// FILE NAME      : driver.sv
// DEPARTMENT     : 
// AUTHOR         : Ahmed Raza
// AUTHOR'S EMAIL : 
// COMPANY        : 10xEngineers
// ------------------------------------------------------------------
// RELEASE HISTORY
// VERSION DATE        AUTHOR      DESCRIPTION
// 1.0     2024-10-09  Ahmed Raza  Initial creation
// ------------------------------------------------------------------
// KEYWORDS : AMBA AHB AHB3-Lite Driver
// ------------------------------------------------------------------
// PURPOSE  : AHB3Lite driver for driving transactions into DUT via interface
// ------------------------------------------------------------------

//-------------------------------------------------------------------------
// gets the packet from the generator and drives the transaction packet 
// items into the interface (interface is connected to DUT, so the items 
// driven into interface signals will get driven into the DUT)
//-------------------------------------------------------------------------

`define DRIV_IF vif.DRIVER.driver_cb

class driver;

  int no_transactions;
  virtual ahb_intf vif;
  mailbox mbx_G2D;

  function new(virtual ahb_intf vif, mailbox mbx_G2D);
    this.vif = vif;
    this.mbx_G2D = mbx_G2D;
  endfunction

  //------------------------------------------------------------------------
  // Reset task: Resets the Interface signals to default/initial values
  //------------------------------------------------------------------------
  task reset;
    wait(!vif.HRESETn);
    $display("--------- [DRIVER] Reset Started ---------");
      `DRIV_IF.HSELx   <= 0;
      `DRIV_IF.HADDR  <= 0;
      `DRIV_IF.HWDATA <= 0;
      `DRIV_IF.HWRITE <= 0;
      `DRIV_IF.HSIZE  <= 0;
      `DRIV_IF.HBURST <= 0;
      `DRIV_IF.HPROT  <= 0;
      `DRIV_IF.HTRANS <= 0;
      `DRIV_IF.HREADY <= 0;        
    wait(vif.HRESETn);
    $display("--------- [DRIVER] Reset Ended ---------");
  endtask

  //------------------------------------------------------------------------
  // Drives the transaction items to interface signals
  //------------------------------------------------------------------------
  task drive;
    Transaction tr;
    mbx_G2D.get(tr);
    @(posedge vif.DRIVER.HCLK);
      `DRIV_IF.HADDR  <= tr.HADDR;
      `DRIV_IF.HSELx   <= tr.HSELx;
      `DRIV_IF.HSIZE  <= tr.HSIZE;
      `DRIV_IF.HBURST <= tr.HBURST;
      `DRIV_IF.HPROT  <= tr.HPROT;
      `DRIV_IF.HTRANS <= tr.HTRANS;
      `DRIV_IF.HREADY <= tr.HREADY; 
      
    if (tr.HWRITE) begin
      `DRIV_IF.HWRITE <= tr.HWRITE;
       @(posedge vif.DRIVER.HCLK);
      `DRIV_IF.HWDATA <= tr.HWDATA;
      tr.HREADYOUT = `DRIV_IF.HREADYOUT;
      tr.HRESP     = `DRIV_IF.HRESP;
    end else begin
       @(posedge vif.DRIVER.HCLK);
      `DRIV_IF.HWRITE <= tr.HWRITE;
      tr.HRDATA    = `DRIV_IF.HRDATA;
      tr.HREADYOUT = `DRIV_IF.HREADYOUT;
      tr.HRESP     = `DRIV_IF.HRESP;
    end

    $display("--------- [DRIVER-TRANSFER: %0d] ---------", no_transactions);
    $display("|      Signal        |       Value        |");
    $display("+--------------------+--------------------+");
    $display("| HSELx              | %0b                |", tr.HSELx);
    $display("| HADDR              | 0x%8h       |", tr.HADDR);
    $display("| HWDATA             | 0x%8h       |", tr.HWDATA);
    $display("| HWRITE             | %0b                |", tr.HWRITE);
    $display("| HSIZE              | %0d                |", tr.HSIZE);
    $display("| HBURST             | %0d                |", tr.HBURST);
    $display("| HPROT              | %0d                |", tr.HPROT);
    $display("| HTRANS             | %0d                |", tr.HTRANS);
    $display("| HREADY             | %0b                |", tr.HREADY);
    $display("| HRDATA             | 0x%8h       |", `DRIV_IF.HRDATA);
    $display("| HREADYOUT          | %0b                |", `DRIV_IF.HREADYOUT);
    $display("| HRESP              | %0b                |", `DRIV_IF.HRESP);
    $display("+--------------------+--------------------+\n");
    no_transactions++;
  endtask

  //------------------------------------------------------------------------
  // Main task: Continuously drives transactions after reset
  //------------------------------------------------------------------------
  task main;
    forever begin
      fork
        begin
          wait(!vif.HRESETn);
        end
        begin
          forever
            drive();
        end
      join_any
      disable fork;
    end
  endtask

endclass



