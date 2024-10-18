//-----------------------------------------------------------------------------
//  Title       : read_single_byte_nonseq_single_Htransfer
//  File        : test1.sv
//  Author      : Ahmed Raza
//  Description : This test verifies read and write operations for a single 
//                byte using non-sequential transfers in an AHB-Lite environment. 
//                The test performs repeated transactions, alternating between 
//                write and read operations, with a simple address increment 
//                for each read operation.
//
//-----------------------------------------------------------------------------

`include "environment.sv"

program test(ahb_intf intf);
  
  // Class representing the transaction used in the test
  class my_trans extends Transaction;
    
    bit [7:0] rand_address;
    bit [7:0] cnt = 0;  // Counter to alternate between write and read operations
    
    // Pre-randomization function for setting up the transaction
    function void pre_randomize();
      // Disable randomization for certain signals to ensure deterministic behavior
      HADDR.rand_mode(0);
      HWRITE.rand_mode(0);
      HSIZE.rand_mode(0);
      HBURST.rand_mode(0);
      HTRANS.rand_mode(0);
      HWDATA.rand_mode(0);

      // Randomize the write data for variability in transactions
      HWDATA = $urandom;

      // Set static values for transaction parameters
      HSIZE  = 0;        // Byte-sized transfer
      HBURST = 0;        // Single transfer (no burst)
      HTRANS = 2;        // Non-sequential transfer

      // Alternate between write and read transactions
      if (cnt % 2 == 0) begin
        HWRITE = 1;                 // Write transaction
        HADDR  = rand_address;      // Address for write
      end 
      else begin
        HWRITE = 0;                 // Read transaction
        HADDR  = rand_address;      // Address for read
        rand_address = rand_address + 1; // Increment address for the next read
      end
      
      // Increment the transaction counter
      cnt++;
    endfunction
    
  endclass
  
  // Environment and transaction instance declarations
  environment env;
  my_trans tr1;
  
  initial begin
    // Create an environment instance, passing the AHB-Lite interface
    env = new(intf);
    tr1 = new();

    // Configure the generator settings
    env.gen.repeat_count = 10;   // Number of transactions to perform
    env.gen.tr = tr1;            // Assign the transaction to the generator

    // Run the environment to start the test
    env.run();
  end

endprogram
