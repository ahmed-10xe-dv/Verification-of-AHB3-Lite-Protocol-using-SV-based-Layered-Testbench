//-----------------------------------------------------------------------------
//  Title       : Increment 4 Burst Test for Word Transfers
//  File        : test9.sv
//  Author      : Ahmed Raza
//  Created     : 14-Oct-2024
//-----------------------------------------------------------------------------
//  Description :
//  This test case verifies 4-beat INCR4 burst transfers with word data size 
//  in an AHB3-Lite environment. The test alternates between write and read 
//  transactions, incrementing addresses by 4 bytes for each transfer. The 
//  address for each transaction is stored during the write phase to ensure 
//  that the read phase retrieves data from the correct locations.
//-----------------------------------------------------------------------------
//  Modification History:
//  Rev   Date         Author         Description
//  ---   ----------   -------------  ----------------------------------------
//  1.0   14-Oct-2024  Ahmed Raza     Initial creation for INCR4 word burst test
//-----------------------------------------------------------------------------

`include "environment.sv"

program test(ahb_intf intf);

  //---------------------------------------------------------------------------
  //  Class my_trans:
  //  Extends the base Transaction class to implement INCR4 burst operations 
  //  for word transfers. The class handles the alternation between write and 
  //  read phases and controls the address increment.
  //---------------------------------------------------------------------------
  class my_trans extends Transaction;

    // Array to store addresses for subsequent read operations
    bit [7:0] rand_address[4];

    // Flag indicating whether the write phase is completed
    bit write_completed;

    // Address counter, initialized to start at 0x4
    bit [7:0] cnt = 8'h4;

    //-----------------------------------------------------------------------
    //  Function pre_randomize:
    //  Configures the signal randomization for the current phase (write or read) 
    //  and increments the address counter by 4 bytes for word transfers.
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
      HSIZE  = 2;  // Word transfer
      HREADY = 1;  // Always ready

      // Choose the operation phase: write or read
      if (!write_completed) 
        initiate_write();
      else 
        initiate_read();

      // Increment the address counter by 4 bytes for the next transaction
      cnt += 4;
    endfunction

    //-----------------------------------------------------------------------
    //  Function initiate_write:
    //  Executes INCR4 burst write transactions. Addresses increment by 
    //  4 bytes for each transfer to maintain word alignment.
    //-----------------------------------------------------------------------
    function void initiate_write();
      HWRITE = 1;  
      HBURST = 3'd3;  // INCR4 burst type

      // Configure the address and transfer type based on the current count
      if (cnt == 8'h4) begin
        HADDR = cnt;
        HTRANS = 2'd2;  // Non-sequential first transfer
        rand_address[0] = HADDR; 
      end else if (cnt == 8'h8) begin
        HADDR = cnt;
        HTRANS = 2'd3;  // Sequential transfer
        rand_address[1] = HADDR; 
      end else if (cnt == 8'hc) begin
        HADDR = cnt;
        HTRANS = 2'd3;  
        rand_address[2] = HADDR; 
      end else if (cnt == 8'h10) begin
        HADDR = cnt;
        HTRANS = 2'd3;  
        rand_address[3] = HADDR; 
      end else begin
        // Mark the write phase as completed and reset the counter
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
      if (cnt == 8'h4) begin 
        HADDR = rand_address[0];
        HTRANS = 2'd2;  // Non-sequential first transfer
      end else if (cnt == 8'h8) begin 
        HADDR = rand_address[1];
        HTRANS = 2'd3;  // Sequential transfer
      end else if (cnt == 8'hc) begin 
        HADDR = rand_address[2];
        HTRANS = 2'd3;  
      end else if (cnt == 8'h10) begin 
        HADDR = rand_address[3];
        HTRANS = 2'd3;  
      end else begin
        // Reset the write completion status to start the process again
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
    $display("Starting INCR4 Word Burst Transfer Test");

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
