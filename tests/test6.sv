//-----------------------------------------------------------------------------
//  Title       : WRAP4 Burst Transfer Test for Word
//  File        : test6.sv
//  Author      : Ahmed Raza
//  Created     : 14-Oct-2024
//-----------------------------------------------------------------------------
//  Description :
//  This test program generates WRAP4 burst transactions (4-beat wrapping 
//  bursts) for AHB3-Lite. It tests the behavior of the AHB3-Lite protocol 
//  when the address wraps to a lower boundary after reaching the end of a 
//  burst. The test performs both write and read operations, toggling between 
//  them based on the `write_completed` flag. The initial address starts at 
//  0x20, and the WRAP4 burst allows the address to wrap back when crossing 
//  the 16-byte boundary.
//-----------------------------------------------------------------------------
//  Modification History:
//  Rev   Date         Author         Description
//  ---   ----------   -------------  ----------------------------------------
//  1.0   14-Oct-2024  Ahmed Raza     Initial creation for WRAP4 burst test
//-----------------------------------------------------------------------------

`include "environment.sv"

program test(ahb_intf intf);

  //---------------------------------------------------------------------------
  //  Class my_trans:
  //  Extends the base Transaction class to implement WRAP4 burst behavior.
  //  It controls the generation of read and write transactions, simulating 
  //  the address wrapping scenario in AHB3-Lite.
  //---------------------------------------------------------------------------
  class my_trans extends Transaction;

    // Array to store addresses for burst transactions
    bit [7:0] rand_address[4];

    // Flag to indicate if write operations have been completed
    bit write_completed;

    // Counter initialized at 0x20 for address generation
    bit [7:0] cnt = 8'h20;

    //-----------------------------------------------------------------------
    //  Function pre_randomize:
    //  Configures signal settings and initiates either write or read 
    //  operations based on the write completion status.
    //-----------------------------------------------------------------------
    function void pre_randomize();
      // Disable randomization for controlled signals
      HWRITE.rand_mode(0);
      HBURST.rand_mode(0);
      HSIZE.rand_mode(0);
      HREADY.rand_mode(0);
      HTRANS.rand_mode(0);
      HADDR.rand_mode(0);

      // Set transaction parameters
      HSIZE  = 2;     // Word-sized transfer
      HREADY = 1;     // Always ready for the next transfer

      // Perform write operations if not completed, otherwise read
      if (!write_completed) 
        initiate_write();
      else 
        initiate_read();

      // Increment address pointer for next operation
      cnt += 4;
    endfunction

    //-----------------------------------------------------------------------
    //  Function initiate_write:
    //  Handles the generation of WRAP4 write bursts, wrapping addresses at 
    //  the appropriate boundary. WRAP4 ensures that after the last burst, 
    //  the address wraps around to the starting boundary.
    //-----------------------------------------------------------------------
    function void initiate_write();
      HWRITE = 1;  
      HBURST = 3'd2;  // WRAP4 burst type

      // Set address and transaction type based on current count
      if (cnt == 8'h20) begin
        HADDR = cnt;
        HTRANS = 2'd2;  // Non-sequential
        rand_address[0] = HADDR;
      end else if (cnt == 8'h24) begin
        HADDR = cnt;
        HTRANS = 2'd3;  // Sequential
        rand_address[1] = HADDR;
      end else if (cnt == 8'h28) begin
        HADDR = cnt - 16;  // Wrap to 0x18
        HTRANS = 2'd3;
        rand_address[2] = HADDR;
      end else if (cnt == 8'h2C) begin
        HADDR = cnt - 16;  // Wrap to 0x1C
        HTRANS = 2'd3;
        rand_address[3] = HADDR;
      end else begin
        // Mark write completion and reset address for the next round
        write_completed = 1;  
        cnt = 8'h1C;
      end
    endfunction

    //-----------------------------------------------------------------------
    //  Function initiate_read:
    //  Manages the read operations for WRAP4 bursts by utilizing the 
    //  previously stored addresses during the write phase.
    //-----------------------------------------------------------------------
    function void initiate_read();
      HWRITE = 0;  
      HBURST = 3'd2;  // WRAP4 burst

      // Read addresses based on saved values
      if (cnt == 8'h20) begin
        HADDR = rand_address[0];
        HTRANS = 2'd2;  // Non-sequential
      end else if (cnt == 8'h24) begin
        HADDR = rand_address[1];
        HTRANS = 2'd3;  // Sequential
      end else if (cnt == 8'h28) begin
        HADDR = rand_address[2];
        HTRANS = 2'd3;
      end else if (cnt == 8'h2C) begin
        HADDR = rand_address[3];
        HTRANS = 2'd3;
      end else begin
        // Reset write completion for the next set of operations
        write_completed = 0;
      end
    endfunction

  endclass

  //---------------------------------------------------------------------------
  //  Environment and Transaction Instances
  //---------------------------------------------------------------------------
  environment env;    // Test environment instance
  my_trans tr1;       // Transaction instance for WRAP4 burst testing

  //---------------------------------------------------------------------------
  //  Initial block:
  //  Initializes the environment, sets the number of iterations for the 
  //  generator, and runs the test sequence.
  //---------------------------------------------------------------------------
  initial begin
    // Display test start message
    $display("Starting WRAP4 Burst Transfer Test: 4-beat WRAP4 Burst Transactions");

    // Instantiate the environment with the provided AHB-Lite interface
    env = new(intf);
    tr1 = new();
    
    // Configure generator to repeat the sequence for multiple iterations
    env.gen.repeat_count = 10;
    env.gen.tr = tr1;  // Assign transaction object to the generator

    // Execute the environment to run the test
    env.run();
  end

endprogram
