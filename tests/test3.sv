//-----------------------------------------------------------------------------
//  Title       : write_single_halfword_nonseq_single_Htransfer
//  File        : test3.sv
//  Author      : Ahmed Raza
//  Description : This test verifies single half-word (16-bit) write and read 
//                operations using non-sequential transfers in an AHB-Lite 
//                environment. The transactions alternate between writing 
//                and reading at specified addresses, with an address 
//                increment for each read operation to test single transfers.
//
//-----------------------------------------------------------------------------

`include "environment.sv"

program test(ahb_intf intf);

  // Transaction class for generating AHB-Lite transactions
  class my_trans extends Transaction;
    
    bit [7:0] rand_address; // Random address for the current transaction
    bit [31:0] cnt = 0;     // Counter to alternate write and read operations

    // Pre-randomization function for setting up the transaction
    function void pre_randomize();
      // Disable randomization for specific signals to control test behavior
      HADDR.rand_mode(0);
      HWRITE.rand_mode(0);
      HSIZE.rand_mode(0);
      HBURST.rand_mode(0);
      HTRANS.rand_mode(0);
      HWDATA.rand_mode(0);

      // Randomize the write data for variability in the test
      HWDATA = $urandom;

      // Set static values for transaction parameters
      HSIZE  = 1;    // Half-word transfer (16-bit)
      HBURST = 0;    // Single transfer, no burst
      HTRANS = 2;    // Non-sequential transfer

      // Alternate between write and read transactions
      if (cnt % 2 == 0) begin
        HWRITE = 1;               // Write operation
        HADDR  = rand_address;    // Assign address for writing
      end else begin
        HWRITE = 0;               // Read operation
        HADDR  = rand_address;    // Assign address for reading
        rand_address = rand_address + 2; // Increment address by 2 for next read
      end

      // Increment the counter for the next transaction
      cnt++;
    endfunction

  endclass
  
  // Declare environment and transaction instances
  environment env;
  my_trans tr1;
  
  initial begin
    // Display a message indicating the start of the test
    $display("\n");
    $display("Running write_single_halfword_nonseq_single_Htransfer test");
    
    // Create an environment instance with the AHB-Lite interface
    env = new(intf);
    tr1 = new();

    // Configure the generator settings
    env.gen.repeat_count = 15;   // Set the number of transactions to 15
    env.gen.tr = tr1;            // Assign the transaction object to the generator

    // Start the environment to execute the test
    env.run();
  end

endprogram
