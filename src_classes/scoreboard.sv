//-----------------------------------------------------------------------------
//  Title       : AHB-Lite Scoreboard Class
//  File        : scoreboard.sv
//  Author      : Ahmed Raza
//  Created     : 10-Oct-2024
//-----------------------------------------------------------------------------
//  Description :
//  The scoreboard class receives transaction packets from the monitor, uses 
//  the reference model to generate expected results, and compares them with 
//  the actual results. Any mismatches between the expected and actual values 
//  are flagged for further investigation.
//
//  This class includes local memory to store data and compares read/write 
//  transactions against the expected values.
//-----------------------------------------------------------------------------
//  Revisions   :
//  Date        : 10-Oct-2024
//  Version     : 1.0
//  Comments    : Initial version that integrates with the reference model and 
//                performs transaction comparison with a local memory array.
//-----------------------------------------------------------------------------

`include "golden_mod.sv"

class scoreboard;

  mailbox mbx_M2Sc;
  int no_transactions;
  bit [31:0] mem[0:255];      // Local memory array to store data (4-byte width, 256 entries)

 
  function new(mailbox mbx_M2Sc);
    this.mbx_M2Sc = mbx_M2Sc;
    // Initialize memory from an external file (ex_mem.mem)
    $readmemh("ex_mem.mem", mem);
  endfunction

  //-------------------------------------------------------------------------
  // Main Task: Transaction Processing and Comparison
  // Receives Transactions from the monitor, sends them to the reference model,
  // and compares the expected and actual results using local memory.
  //-------------------------------------------------------------------------
  task main;
    Transaction tr;
    forever begin
      mbx_M2Sc.get(tr);
      // Call the golden model to perform the comparison
      golden_model(tr, mem);
      no_transactions++;
    end
  endtask
endclass
