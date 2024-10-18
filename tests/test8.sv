//-----------------------------------------------------------------------------
//  Title       : Increment 4 Burst Test for Half-Word Transfers
//  File        : test8.sv
//  Author      : Ahmed Raza
//  Created     : 14-Oct-2024
//-----------------------------------------------------------------------------
//  Description :
//  This test case is designed to verify 4-beat INCR4 burst transfers with 
//  half-word data size in an AHB3-Lite environment. The test performs a 
//  sequence of half-word write and read transactions. The addresses increment 
//  by 2 bytes for each transfer. Write and read phases alternate based on a 
//  flag (`write_completed`), ensuring the consistency of burst transfer behavior.
//-----------------------------------------------------------------------------
//  Modification History:
//  Rev   Date         Author         Description
//  ---   ----------   -------------  ----------------------------------------
//  1.0   14-Oct-2024  Ahmed Raza     Initial creation for INCR4 half-word burst test
//-----------------------------------------------------------------------------

`include "environment.sv"

program test(ahb_intf intf);

  //---------------------------------------------------------------------------
  //  Class my_trans:
  //  Extends the base Transaction class to implement INCR4 burst operations 
  //  for half-word transfers. The class manages alternating write and read 
  //  phases and controls the address increment.
  //---------------------------------------------------------------------------
  class my_trans extends Transaction;

    // Array to store addresses for read operations
    bit [7:0] rand_address[4];

    // Flag indicating the completion of the write phase
    bit write_completed;

    // Address counter starting at 0x2
    bit [7:0] cnt = 8'h2;

    //-----------------------------------------------------------------------
    //  Function pre_randomize:
    //  Configures the signals for the current phase (write or read) and 
    //  adjusts the address incrementally by 2 for half-word transfers.
    //-----------------------------------------------------------------------
    function void pre_randomize();
      // Control randomization for specific signals
      HWRITE.rand_mode(0);
      HBURST.rand_mode(0);
      HSIZE.rand_mode(0);
      HREADY.rand_mode(0);
      HTRANS.rand_mode(0);
      HADDR.rand_mode(0);

      // Configure fixed transfer parameters
      HSIZE  = 1;  // Half-word transfer
      HREADY = 1;  // Always ready

      // Choose the operation phase: write or read
      if (!write_completed) 
        initiate_write();
      else 
        initiate_read();

      // Increment the address counter by 2 bytes for the next transaction
      cnt += 2;
    endfunction

    //-----------------------------------------------------------------------
    //  Function initiate_write:
    //  Executes INCR4 burst write transactions. The address increments by 
    //  2 bytes for each transfer, ensuring half-word alignment.
    //-----------------------------------------------------------------------
    function void initiate_write();
      HWRITE = 1;  
      HBURST = 3'd3;  // INCR4 burst type

      // Configure the address and transfer type based on the current count
      if (cnt == 8'h2) begin
        HADDR = cnt;
        HTRANS = 2'd2;  // Non-sequential first transfer
        rand_address[0] = HADDR;
      end else if (cnt == 8'h4) begin
        HADDR = cnt;
        HTRANS = 2'd3;  // Sequential transfer
        rand_address[1] = HADDR;
      end else if (cnt == 8'h6) begin
        HADDR = cnt;
        HTRANS = 2'd3;
        rand_address[2] = HADDR;
      end else if (cnt == 8'h8) begin
        HADDR = cnt;
        HTRANS = 2'd3;
        rand_address[3] = HADDR;
      end else begin
        // Mark write phase as completed and reset the counter
        write_completed = 1;
        cnt = 0;
      end
    endfunction

    //-----------------------------------------------------------------------
    //  Function initiate_read:
    //  Performs INCR4 burst read transactions, using addresses stored 
    //  during the write phase.
    //-----------------------------------------------------------------------
    function void initiate_read();
      HWRITE = 0;  
      HBURST = 3'd3;  // INCR4 burst type

      // Configure the read operations based on previously stored addresses
      if (cnt == 8'h2) begin
        HADDR = rand_address[0];
        HTRANS = 2'd2;  // Non-sequential first transfer
      end else if (cnt == 8'h4) begin
        HADDR = rand_address[1];
        HTRANS = 2'd3;  // Sequential transfer
      end else if (cnt == 8'h6) begin
        HADDR = rand_address[2];
        HTRANS = 2'd3;
      end else if (cnt == 8'h8) begin
        HADDR = rand_address[3];
        HTRANS = 2'd3;
      end else begin
        // Reset write completion status to start the process again
        write_completed = 0;
      end
    endfunction

  endclass

  //---------------------------------------------------------------------------
  //  Environment and Transaction Instances
  //---------------------------------------------------------------------------
  environment env;    // Instance of the test environment
  my_trans tr1;       // Instance of the custom transaction for testing

  //---------------------------------------------------------------------------
  //  Initial block:
  //  Initializes the test environment, configures the generator for multiple 
  //  iterations, and runs the test.
  //---------------------------------------------------------------------------
  initial begin
    // Display a message indicating the start of the test
    $display("Starting INCR4 Half-Word Burst Transfer Test");

    // Create the environment with the AHB-Lite interface
    env = new(intf);
    tr1 = new();

    // Set generator parameters and initiate the environment
    env.gen.repeat_count = 10;
    env.gen.tr = tr1;

    // Execute the test sequence
    env.run();
  end

endprogram
