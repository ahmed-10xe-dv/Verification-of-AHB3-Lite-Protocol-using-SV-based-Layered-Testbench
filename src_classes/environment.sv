/////////////////////////////////////////////////////////////////////
//   ,------.                    ,--.                ,--.          //
//   |  .--. ' ,---.  ,--,--.    |  |    ,---. ,---. `--' ,---.    //
//   |  '--'.'| .-. |' ,-.  |    |  |   | .-. | .-. ||  || .--'    //
//   |  |\  \ ' '-' '\ '-'  |    |  '--.' '-' ' '-' ||  | \ `--.   //
//   `--' '--' `---'  `--`--'    `-----' `---' `---' `--'  `---'   //
//                                                                 //
//                       AHB3-Lite Environment                     //
//                                                                 //
/////////////////////////////////////////////////////////////////////
//                                                                 //
//             Copyright (C) 2024 10xEngineers                     //
//             www.10xengineers.com                                //
//                                                                 //
//                                                                 //
/////////////////////////////////////////////////////////////////////

// +FHDR -  Semiconductor Reuse Standard File Header Section  -------
// FILE NAME      : environment.sv
// DEPARTMENT     :
// AUTHOR         : Ahmed Raza
// AUTHOR'S EMAIL :
// COMPANY        : 10xEngineers
// ------------------------------------------------------------------
// RELEASE HISTORY
// VERSION DATE        AUTHOR      DESCRIPTION
// 1.0     2024-10-10  Ahmed Raza  Initial creation
// ------------------------------------------------------------------
// KEYWORDS : AHB3-Lite, Environment, Generator, Driver, Monitor, Scoreboard
// ------------------------------------------------------------------
// PURPOSE  : Test environment for AHB3-Lite protocol verification, connecting 
//            generator, driver, monitor, and scoreboard components.
// ------------------------------------------------------------------

//-------------------------------------------------------------------------
// Including necessary component files for environment setup
`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"

//-------------------------------------------------------------------------
// Environment class definition, handling interactions between components
class environment;
  
  //------------------------------------------------------------------------
  // Instances of generator, driver, monitor, and scoreboard
  generator  gen;
  driver     drv;
  monitor    mon;
  scoreboard scb;
  
  //------------------------------------------------------------------------
  // Mailbox handles for communication between components
  mailbox mbx_G2D;
  mailbox mbx_M2Sc;
  
  //------------------------------------------------------------------------
  // Event for synchronization between generator and test completion
  event completion;
  
  //------------------------------------------------------------------------
  // Virtual interface connecting to the AHB3-Lite signals
  virtual ahb_intf vif;
  
  //------------------------------------------------------------------------
  // Constructor to initialize environment components and shared resources
  function new(virtual ahb_intf vif);
    // Getting the interface from the testbench
    this.vif = vif;
    
    // Creating mailboxes to pass transactions between components
    mbx_G2D = new();
    mbx_M2Sc  = new();
    
    // Creating instances of generator, driver, monitor, and scoreboard
    gen  = new(mbx_G2D, completion);
    drv = new( vif, mbx_G2D);
    mon  = new(vif, mbx_M2Sc);
    scb  = new(mbx_M2Sc);
  endfunction
  
  //------------------------------------------------------------------------
  // Task to perform pre-test setup, like resetting the driver
  task pre_test();
    drv.reset();
  endtask
  
  //------------------------------------------------------------------------
  // Main test task, running all components concurrently
  task test();
    fork 
      gen.main();
      drv.main();
      mon.main();
      scb.main();      
    join_any
  endtask
  
  //------------------------------------------------------------------------
  // Task to perform post-test checks and synchronization
  task post_test();
    wait(completion.triggered);
    wait(gen.repeat_count == drv.no_transactions);
    wait(gen.repeat_count == mon.no_transactions);
    wait(gen.repeat_count == scb.no_transactions);
  endtask
  
  //------------------------------------------------------------------------
  // Run task to execute the entire test sequence
  task run;
    pre_test();
    test();
    post_test();
    $finish;
  endtask
  
endclass //Environment
