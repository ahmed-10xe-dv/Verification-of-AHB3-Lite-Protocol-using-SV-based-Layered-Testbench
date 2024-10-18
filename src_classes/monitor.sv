
//-----------------------------------------------------------------------------
//  Title       : AHB-Lite Monitor Class
//  File        : monitor.sv
//  Author      : Ahmed Raza
//  Created     : 10-Oct-2024
//-----------------------------------------------------------------------------
//  Description :
//  The monitor class samples the AHB interface signals, captures them into
//  a transaction packet, and sends the packet to the scoreboard for comparison
//  and validation. It observes the bus transactions and reports any mismatch.
//
//  This class interacts with the environment via a virtual interface handle
//  and communicates with the scoreboard via a mailbox.
//-----------------------------------------------------------------------------
//  Revisions   :
//  Date        : 10-Oct-2024
//  Version     : 1.0
//  Comments    : Initial version with structured signal sampling and display 
//                for transaction debug visibility.
//-----------------------------------------------------------------------------

`define MON_IF vif.MONITOR.monitor_cb

class monitor;

  virtual ahb_intf vif;
  int no_transactions;
  mailbox mbx_M2Sc;

  function new(virtual ahb_intf vif, mailbox mbx_M2Sc);
    this.vif = vif;
    this.mbx_M2Sc = mbx_M2Sc;
  endfunction

  
  //-------------------------------------------------------------------------
  // Main Task: Sampling and Transaction Capture
  // Continuously samples signals, captures them into a transaction packet, 
  // and sends the packet to the scoreboard via mailbox.
  //-------------------------------------------------------------------------
  task main;
    forever begin
      Transaction tr;
      tr = new();

      // Wait for valid clock edges before sampling
      @(posedge vif.MONITOR.HCLK);

      // Wait for either read or write operation
      wait(`MON_IF.HWRITE || !`MON_IF.HWRITE);
      // Capture signals into the transaction object
      tr.HADDR     = `MON_IF.HADDR;
      tr.HSELx      = `MON_IF.HSELx;
      tr.HSIZE     = `MON_IF.HSIZE;
      tr.HBURST    = `MON_IF.HBURST;
      tr.HPROT     = `MON_IF.HPROT;
      tr.HTRANS    = `MON_IF.HTRANS;
      tr.HREADY    = `MON_IF.HREADY;
      tr.HWRITE    = `MON_IF.HWRITE;

      // If it's a write operation, capture additional signals
      if (`MON_IF.HWRITE) begin
        @(posedge vif.MONITOR.HCLK);
        tr.HWDATA    = `MON_IF.HWDATA;
        tr.HREADYOUT = `MON_IF.HREADYOUT;
        tr.HRESP     = `MON_IF.HRESP;
      end

      // If it's a read operation, capture read data and response
      if (!`MON_IF.HWRITE) begin
        tr.HRDATA    = `MON_IF.HRDATA;
        tr.HREADYOUT = `MON_IF.HREADYOUT;
        tr.HRESP     = `MON_IF.HRESP;
        @(posedge vif.MONITOR.HCLK);
      
      end

      // Display transaction details in a tabular format
      $display("----------------------------------------");
      $display("--------- [MONITOR TRANSACTION] %0d ---------", no_transactions);
      $display("|      Signal        |       Value      |");
      $display("+--------------------+------------------+");
      $display("| HSELx              | %0b              |", tr.HSELx);
      $display("| HADDR              | 0x%8h     |", tr.HADDR);
      $display("| HWDATA             | 0x%8h     |", tr.HWDATA);
      $display("| HWRITE             | %0b              |", tr.HWRITE);
      $display("| HSIZE              | %0d              |", tr.HSIZE);
      $display("| HBURST             | %0d              |", tr.HBURST);
      $display("| HPROT              | %0d              |", tr.HPROT);
      $display("| HTRANS             | %0d              |", tr.HTRANS);
      $display("| HREADY             | %0b              |", tr.HREADY);
      $display("| HRDATA             | 0x%8h     |", tr.HRDATA);
      $display("| HREADYOUT          | %0b              |", tr.HREADYOUT);
      $display("| HRESP              | %0b              |", tr.HRESP);
      $display("+--------------------+------------------+");
      $display("----------------------------------------");
      mbx_M2Sc.put(tr);         // Send the transaction packet to the scoreboard
      no_transactions++;
    end
  endtask
endclass