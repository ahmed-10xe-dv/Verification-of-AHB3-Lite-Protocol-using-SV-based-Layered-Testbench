//-----------------------------------------------------------------------------
//  Title       : Write/Read Test for Word
//  File        : test12.sv
//  Author      : Ahmed Raza
//  Created     : 10-Oct-2024
//-----------------------------------------------------------------------------
//  Description :
//  This test program generates AHB3-Lite write and read transactions using
//  the environment class. The type of transaction (write or read) is determined 
//  by a counter. Predefined parameters such as HSIZE, HBURST, and HTRANS are 
//  configured for each transaction. The environment class drives the AHB-Lite 
//  interface, simulating basic read and write operations to verify the protocol's 
//  functionality.
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
  //  This class extends the base Transaction class, overriding the 
  //  `pre_randomize()` function to manage transaction generation by alternating
  //  between read and write operations.
  //---------------------------------------------------------------------------
  class my_trans extends Transaction;
    
    // Counter to generate addresses for the transactions
    bit [7:0] rand_address = 8'h0;  // Initialize address to 0

    //-----------------------------------------------------------------------
    //  Function pre_randomize:
    //  This function sets the control signals and address values necessary 
    //  for both read and write transactions based on the current transaction count.
    //-----------------------------------------------------------------------
    function void pre_randomize();

      // Disable randomization for specific signals to control their values
      HADDR.rand_mode(0);
      HWRITE.rand_mode(0);
      HSIZE.rand_mode(0);
      HBURST.rand_mode(0);
      HTRANS.rand_mode(0);

      // Set static values for transaction parameters
      HSIZE  = 2;          // Set data transfer size to word (4 bytes)
      HBURST = 0;          // Single burst transfer
      HTRANS = 2;          // Non-sequential transfer

      // Determine whether the current transaction is a write or read operation
      if (cnt % 2 == 0) begin
        HWRITE = 1;        // Configure as a write transaction
        HADDR  = rand_address;  // Assign current address for writing
      end 
      else begin
        HWRITE = 0;        // Configure as a read transaction
        HADDR  = rand_address;  // Assign current address for reading

        // Increment the address counter by 4 for the next transaction
        rand_address = rand_address + 4; 
      end
      
      // Increment the transaction count for the next call
      cnt++;
    endfunction
  endclass
  
  //---------------------------------------------------------------------------
  //  Environment and Transaction Instances
  //---------------------------------------------------------------------------
  environment env;     // Instance of the test environment
  my_trans tr1;        // Instance of the custom transaction class

  //---------------------------------------------------------------------------
  //  Initial block:
  //  Instantiates the environment, configures the generator, and invokes 
  //  the `run()` function to start executing the test.
  //---------------------------------------------------------------------------
  initial begin
    // Create an instance of the environment, passing the AHB-Lite interface
    env = new(intf);
    tr1 = new();  // Instantiate the transaction class
    env.gen.repeat_count = 10;  // Set the number of test repetitions
    env.gen.tr = tr1;           // Assign the transaction instance to the generator
    env.run();                  // Execute the test sequence
  end

endprogram
