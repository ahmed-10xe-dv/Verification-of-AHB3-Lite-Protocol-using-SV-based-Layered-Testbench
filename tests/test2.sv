//-----------------------------------------------------------------------------
//  Title       : write_single_byte_nonseq_single_Htransfer
//  File        : test2.sv
//  Author      : Ahmed Raza
//  Description : This test verifies single-byte write and read operations 
//                using non-sequential transfers in an AHB-Lite environment. 
//                The transactions alternate between writing and reading at 
//                specified addresses, with an address increment for each 
//                read operation to test single transfers.
//
//-----------------------------------------------------------------------------

`include "environment.sv"

program test(ahb_intf intf);

  // Transaction class for generating AHB-Lite transactions
  class my_trans extends Transaction;
    
    bit [7:0] rand_address; // Address for the current transaction
    bit [7:0] cnt = 0;     // Counter for alternating write and read operations

    // Pre-randomization function for setting up the transaction
    function void pre_randomize();
      // Disable randomization for certain signals for controlled behavior
      HADDR.rand_mode(0);
      HWRITE.rand_mode(0);
      HSIZE.rand_mode(0);
      HBURST.rand_mode(0);
      HTRANS.rand_mode(0);
      HWDATA.rand_mode(0);

      // Randomize the write data to introduce variability in the test
      HWDATA = $urandom;

      // Set fixed values for the transaction parameters
      HSIZE  = 0;   // Byte transfer size
      HBURST = 0;   // Single transfer, no burst
      HTRANS = 2;   // Non-sequential transfer

      // Alternate between write and read transactions
      if (cnt % 2 == 0) begin
        HWRITE = 1;               // Write transaction
        HADDR  = rand_address;    // Address for writing
      end else begin
        HWRITE = 0;               // Read transaction
        HADDR  = rand_address;    // Address for reading
        rand_address = rand_address + 1; // Increment address for next read
      end

      // Increment the counter for the next transaction
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
    env.gen.repeat_count = 10;   // Number of transactions to execute
    env.gen.tr = tr1;            // Assign the transaction object to the generator

    // Start the environment to execute the test
    env.run();
  end

endprogram
