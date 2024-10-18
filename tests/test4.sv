//-----------------------------------------------------------------------------
//  Title       : Reset Single Transfer Test
//  File        : test4.sv
//  Author      : Ahmed Raza
//  Description : This test performs single-word transfers using the AHB-Lite
//                interface in a reset scenario. It tests read operations by
//                incrementing the address for each transaction. The burst 
//                type is set to 'Single Transfer,' and the transfer type 
//                is set as 'Non-sequential' for the first transfer. 
//-----------------------------------------------------------------------------

`include "environment.sv"

program test(ahb_intf intf);

  // Transaction class for generating AHB-Lite transactions
  class my_trans extends Transaction;

    bit [7:0] count = 8'h0; // Counter to track current transaction address

    // Pre-randomization function for setting up the transaction
    function void pre_randomize();
      // Disable randomization for specific signals to control transaction flow
      HWRITE.rand_mode(0);
      HADDR.rand_mode(0);
      HBURST.rand_mode(0);
      HSIZE.rand_mode(0);
      HTRANS.rand_mode(0);

      // Perform single transfer if in read mode (reset scenario)
      if (!HWRITE) begin
        HADDR  = count;       // Address for the current transaction
        HBURST = 3'd0;        // Burst type: Single Transfer
        HSIZE  = 3'd2;        // Transfer size: Word (32-bit)
        HTRANS = 2'd2;        // Transfer type: Non-sequential
        count  = count + 4;   // Increment address by word size for next transfer
      end
    endfunction

  endclass

  // Test environment and transaction instance
  environment env;
  my_trans tr1;

  initial begin
    // Display a message indicating the start of the Reset Single Transfer Test
    $display("Running Reset Single Transfer Test");

    // Create an environment instance with the AHB-Lite interface
    env = new(intf);
    tr1 = new();

    // Configure the generator settings for the test
    env.gen.repeat_count = 10; // Set the number of transactions to 10
    env.gen.tr = tr1;          // Assign the transaction object to the generator

    // Start the environment to execute the test
    env.run();
  end

endprogram
