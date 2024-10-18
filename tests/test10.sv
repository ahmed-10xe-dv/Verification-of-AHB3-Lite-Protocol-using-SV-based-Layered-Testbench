//-----------------------------------------------------------------------------
//  Title       : Write/Read Test for Byte
//  File        : test10.sv
//  Author      : Ahmed Raza
//  Created     : 10-Oct-2024
//-----------------------------------------------------------------------------
//  Description :
//  This test program generates AHB3-Lite write and read transactions using 
//  the environment class. It toggles between read and write operations based 
//  on a counter. Predefined parameters such as HSIZE, HBURST, and HTRANS 
//  are set for each transaction, and the environment class drives the AHB-Lite 
//  interface. This setup allows for basic verification of the AHB3-Lite protocol 
//  functionality and correctness.
//-----------------------------------------------------------------------------
//  Modification History:
//  Rev   Date         Author         Description
//  ---   ----------   -------------  ----------------------------------------
//  1.0   10-Oct-2024  Ahmed Raza     Initial creation for Write/Read test
//-----------------------------------------------------------------------------

`include "environment.sv"

program test(ahb_intf intf);

  //---------------------------------------------------------------------------
  //  Class my_trans:
  //  This class extends the base Transaction class and overrides the 
  //  `pre_randomize()` function to manage the generation of transactions, 
  //  alternating between read and write operations.
  //---------------------------------------------------------------------------
  class my_trans extends Transaction;

    // Counter to hold the current address for transactions
    bit [7:0] rand_address = 8'h0;  // Initialize address to 0

    //-----------------------------------------------------------------------
    //  Function pre_randomize:
    //  Sets control signals and address values for both read and write 
    //  transactions based on the current counter state.
    //-----------------------------------------------------------------------
    function void pre_randomize();
      // Disable randomization for specific signals to control their values
      HADDR.rand_mode(0);
      HWRITE.rand_mode(0);
      HSIZE.rand_mode(0);
      HBURST.rand_mode(0);
      HTRANS.rand_mode(0);

      // Set static values for transaction parameters
      HSIZE  = 0;        // Byte-sized transfer
      HBURST = 0;        // Single Burst
      HTRANS = 2;        // Non-sequential transfer

      // Determine whether the transaction is a write or read operation
      if (cnt % 2 == 0) begin
        HWRITE = 1;      // Set to write transaction
        HADDR  = rand_address;  // Assign the current address
      end 
      else begin
        HWRITE = 0;      // Set to read transaction
        HADDR  = rand_address;  // Assign the current address for read

        // Increment the address counter for the next transaction
        rand_address = rand_address + 1; 
      end
      
      cnt++;  // Increment the transaction counter
    endfunction
  endclass

  //---------------------------------------------------------------------------
  //  Environment and Transaction Instances
  //---------------------------------------------------------------------------
  environment env;     // Instance of the test environment
  my_trans tr1;        // Instance of the custom transaction class

  //---------------------------------------------------------------------------
  //  Initial block:
  //  Instantiates the environment, configures the generator, and calls 
  //  the `run()` function to start executing the test.
  //---------------------------------------------------------------------------
  initial begin
    // Create an instance of the environment, passing the AHB-Lite interface
    env = new(intf);
    tr1 = new();
    env.gen.repeat_count = 10;  // Set the number of test repetitions
    env.gen.tr = tr1;           // Assign the transaction instance to the generator
    env.run();                  // Execute the test sequence
  end

endprogram
