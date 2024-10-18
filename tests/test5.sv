//-----------------------------------------------------------------------------
//  Title       : HSELx Test (Slave Select Test)
//  File        : test5.sv
//  Author      : Ahmed Raza
//  Created     : 10-Oct-2024
//-----------------------------------------------------------------------------
//  Description :
//  This test generates AHB3-Lite write and read transactions using the 
//  environment class. It toggles between write and read operations based on a 
//  counter value, setting transaction parameters such as HSIZE (word transfers), 
//  HBURST (single burst), HTRANS (non-sequential), and HSELx (slave select). 
//  The HSELx signal is set to zero, indicating that no slave is selected, which 
//  simulates scenarios where a slave device is not present or enabled.
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
  //  This class extends the base Transaction class and provides specific 
  //  behavior for the AHB3-Lite protocol by overriding the `pre_randomize()` 
  //  function to control the generation of read and write transactions.
  //---------------------------------------------------------------------------
  class my_trans extends Transaction;

    // Address counter for generating unique addresses for each transaction
    bit [7:0] rand_address;

    //-----------------------------------------------------------------------
    //  Function pre_randomize:
    //  Configures the necessary control signals for AHB-Lite transactions, 
    //  setting HSIZE, HBURST, HTRANS, and HSELx for either read or write 
    //  operations based on the current counter value.
    //-----------------------------------------------------------------------
    function void pre_randomize();

      // Disable randomization for specific signals to maintain test control
      HADDR.rand_mode(0);
      HWRITE.rand_mode(0);
      HSIZE.rand_mode(0);
      HBURST.rand_mode(0);
      HTRANS.rand_mode(0);
      HSELx.rand_mode(0);

      // Set static values for transaction parameters
      HSIZE  = 2;         // Word transfer (32-bit)
      HBURST = 0;         // Single burst
      HTRANS = 2;         // Non-sequential transfer type
      HSELx  = 0;         // No slave selected

      // Toggle between write and read based on counter value
      if (cnt % 2 == 0) begin
        HWRITE = 1;                // Write operation
        HADDR  = rand_address;     // Assign current address for the transaction
      end else begin
        HWRITE = 0;                // Read operation
        HADDR  = rand_address;     // Assign current address for reading

        // Increment the address by 4 (word-size) for the next transaction
        rand_address = rand_address + 4;
      end

      cnt++;  // Update the counter for the next transaction
    endfunction
  endclass

  //---------------------------------------------------------------------------
  //  Environment and Transaction Instances
  //---------------------------------------------------------------------------
  environment env;    // Test environment instance
  my_trans tr1;       // Transaction instance for read/write operations

  //---------------------------------------------------------------------------
  //  Initial block:
  //  Creates an instance of the environment, sets the number of iterations 
  //  for the generator, and starts the simulation by calling `run()`.
  //---------------------------------------------------------------------------
  initial begin
    // Display test start message
    $display("Starting HSELx Test: Write and Read Transactions with No Slave Selected");

    // Instantiate the environment with the provided AHB-Lite interface
    env = new(intf);
    tr1 = new();
    
    // Set the repeat count for the generator to define the number of iterations
    env.gen.repeat_count = 10;
    env.gen.tr = tr1;  // Assign the transaction object to the generator

    // Execute the environment to run the test
    env.run();
  end

endprogram
