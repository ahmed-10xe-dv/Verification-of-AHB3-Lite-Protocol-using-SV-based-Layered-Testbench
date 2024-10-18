//-----------------------------------------------------------------------------
//  Title       : Increment 4 Burst Test for Byte Transfers
//  File        : test7.sv
//  Author      : Ahmed Raza
//  Created     : 14-Oct-2024
//-----------------------------------------------------------------------------
//  Description :
//  This test verifies the behavior of 4-beat INCR4 burst transfers in an 
//  AHB3-Lite environment. It performs a sequence of byte-sized write and 
//  read transactions using the INCR4 burst type, where addresses increment 
//  by 1 byte for each transfer. Both write and read operations alternate, 
//  using a flag (`write_completed`) to switch phases and ensure proper 
//  verification of incrementing burst functionality.
//-----------------------------------------------------------------------------
//  Modification History:
//  Rev   Date         Author         Description
//  ---   ----------   -------------  ----------------------------------------
//  1.0   14-Oct-2024  Ahmed Raza     Initial creation for INCR4 burst test
//-----------------------------------------------------------------------------

`include "environment.sv"

program test(ahb_intf intf);

  //---------------------------------------------------------------------------
  //  Class my_trans:
  //  Extends the base Transaction class to implement INCR4 burst behavior. 
  //  The class manages write and read phases, ensuring proper address 
  //  increments for the INCR4 burst.
  //---------------------------------------------------------------------------
  class my_trans extends Transaction;

    // Array to store burst addresses for the read phase
    bit [7:0] rand_address[4];

    // Flag to indicate if the write phase is completed
    bit write_completed;

    // Address counter initialized to 0x1 for the test
    bit [7:0] cnt = 8'h1;

    //-----------------------------------------------------------------------
    //  Function pre_randomize:
    //  Configures signal settings and initiates either a write or read 
    //  phase based on the `write_completed` flag. The address is incremented 
    //  by 1 byte for each transaction.
    //-----------------------------------------------------------------------
    function void pre_randomize();
      // Disable randomization for controlled signals
      HWRITE.rand_mode(0);
      HBURST.rand_mode(0);
      HSIZE.rand_mode(0);
      HREADY.rand_mode(0);
      HTRANS.rand_mode(0);
      HADDR.rand_mode(0);

      // Set transfer parameters
      HSIZE  = 0;  // Byte-sized transfer
      HREADY = 1;  // Always ready for the next transfer

      // Execute write or read phase based on write completion status
      if (!write_completed) 
        initiate_write();
      else 
        initiate_read();

      // Increment the address counter for the next transaction
      cnt += 1;
    endfunction

    //-----------------------------------------------------------------------
    //  Function initiate_write:
    //  Performs INCR4 burst write transactions with byte-sized transfers. 
    //  Addresses increment sequentially for each transaction.
    //-----------------------------------------------------------------------
    function void initiate_write();
      HWRITE = 1;  
      HBURST = 3'd3;  // INCR4 burst type

      // Configure write transactions based on the current address count
      if (cnt == 8'h1) begin
        HADDR = cnt;
        HTRANS = 2'd2;  // Non-sequential for the first transaction
        rand_address[0] = HADDR;
      end else if (cnt == 8'h2) begin
        HADDR = cnt;
        HTRANS = 2'd3;  // Sequential transfer
        rand_address[1] = HADDR;
      end else if (cnt == 8'h3) begin
        HADDR = cnt;
        HTRANS = 2'd3;
        rand_address[2] = HADDR;
      end else if (cnt == 8'h4) begin
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
    //  Executes INCR4 burst read transactions using the stored addresses 
    //  from the write phase.
    //-----------------------------------------------------------------------
    function void initiate_read();
      HWRITE = 0;  
      HBURST = 3'd3;  // INCR4 burst type

      // Perform read transactions using the saved burst addresses
      if (cnt == 8'h1) begin 
        HADDR = rand_address[0];
        HTRANS = 2'd2;  // Non-sequential for the first transaction
      end else if (cnt == 8'h2) begin 
        HADDR = rand_address[1];
        HTRANS = 2'd3;  // Sequential transfer
      end else if (cnt == 8'h3) begin 
        HADDR = rand_address[2];
        HTRANS = 2'd3;
      end else if (cnt == 8'h4) begin 
        HADDR = rand_address[3];
        HTRANS = 2'd3;
      end else begin
        // Reset the write completion flag to restart the sequence
        write_completed = 0;
      end
    endfunction

  endclass

  //---------------------------------------------------------------------------
  //  Environment and Transaction Instances
  //---------------------------------------------------------------------------
  environment env;    // Test environment instance
  my_trans tr1;       // Transaction instance for the INCR4 burst test

  //---------------------------------------------------------------------------
  //  Initial block:
  //  Sets up the test environment, configures the generator for multiple 
  //  iterations, and initiates the test sequence.
  //---------------------------------------------------------------------------
  initial begin
    // Display message indicating the start of the test
    $display("Starting INCR4 Burst Transfer Test: Byte-Sized INCR4 Burst Transactions");

    // Instantiate the environment with the AHB-Lite interface
    env = new(intf);
    tr1 = new();
    
    // Configure the generator for 10 iterations
    env.gen.repeat_count = 10;
    env.gen.tr = tr1;  // Assign the transaction object to the generator

    // Run the environment to execute the test
    env.run();
  end

endprogram
