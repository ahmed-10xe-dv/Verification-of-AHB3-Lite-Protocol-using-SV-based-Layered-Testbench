/////////////////////////////////////////////////////////////////////
//   ,------.                    ,--.                ,--.          //
//   |  .--. ' ,---.  ,--,--.    |  |    ,---. ,---. `--' ,---.    //
//   |  '--'.'| .-. |' ,-.  |    |  |   | .-. | .-. ||  || .--'    //
//   |  |\  \ ' '-' '\ '-'  |    |  '--.' '-' ' '-' ||  | \ `--.   //
//   `--' '--' `---'  `--`--'    `-----' `---' `---' `--'  `---'   //
//                                                                 //
//                      AHB3-Lite Generator                        //
//                                                                 //
/////////////////////////////////////////////////////////////////////
//                                                                 //
//             Copyright (C) 2024 10xEngineers                    //
//             www.10xengineers.com                                 //
//                                                                 //
/////////////////////////////////////////////////////////////////////

// +FHDR -  Semiconductor Reuse Standard File Header Section  -------
// FILE NAME      : generator.sv
// DEPARTMENT     :
// AUTHOR         : Ahmed Raza
// AUTHOR'S EMAIL :
// COMPANY        : 10xEngineers
// ------------------------------------------------------------------
// RELEASE HISTORY
// VERSION DATE        AUTHOR      DESCRIPTION
// 1.0     2024-10-10  Ahmed Raza  Initial creation
// ------------------------------------------------------------------
// KEYWORDS : AHB3-Lite, Generator, Transaction, Randomization
// ------------------------------------------------------------------
// PURPOSE  : Generates randomized transactions for AHB3-Lite protocol 
//            verification and sends them to the driver via mailbox.
// ------------------------------------------------------------------

class generator;
  
  rand Transaction tr;
  int  repeat_count;
  mailbox mbx_G2D;
  event completion;
  
  function new(mailbox mbx_G2D, event completion);
    this.mbx_G2D = mbx_G2D;
    this.completion    = completion;
    tr = new();
  endfunction
  
  //------------------------------------------------------------------------
  // Main task: Generates, randomizes, and sends `repeat_count` transaction
  //            packets via the mailbox
  task main();
    repeat(repeat_count) begin
      if (!tr.randomize()) 
        $fatal("Generator:: Transaction randomization failed");
      mbx_G2D.put(tr.copy());
//       tr.print_trans();
    end
    
    // Trigger the end event after generation is complete
    -> completion; 
  endtask
  
endclass
