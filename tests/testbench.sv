/////////////////////////////////////////////////////////////////////
//   ,------.                    ,--.                ,--.          //
//   |  .--. ' ,---.  ,--,--.    |  |    ,---. ,---. `--' ,---.    //
//   |  '--'.'| .-. |' ,-.  |    |  |   | .-. | .-. |,--.| .--'    //
//   |  |\  \ ' '-' '\ '-'  |    |  '--.' '-' ' '-' ||  |\ `--.    //
//   `--' '--' `---'  `--`--'    `-----' `---' `-   /`--' `---'    //
//                                             `---'               //
//   AHB3-Lite Testbench                                           //
//                                                                 //
/////////////////////////////////////////////////////////////////////
//                                                                 //
//             Copyright (C) 2024 10xEngineers                     //
//             www.10xengineers.com                                //
//                                                                 //
/////////////////////////////////////////////////////////////////////

// +FHDR -  Semiconductor Reuse Standard File Header Section  -------
// FILE NAME      : testbench.sv
// DEPARTMENT     :
// AUTHOR         : Ahmed Raza
// AUTHOR'S EMAIL : ahmed.raza@10xengineer.ai
// COMPANY        : 10xEngineers
// ------------------------------------------------------------------
// RELEASE HISTORY
// VERSION DATE        AUTHOR      DESCRIPTION
// 1.0     2024-10-09  Ahmed Raza  Initial creation
// ------------------------------------------------------------------
// PURPOSE  : Top-level testbench for AHB3Lite SRAM verification
// ------------------------------------------------------------------


//-------------------------------------------------------------------------
// Including interface and testcase files
`include "interface.sv"


//-------------------------------------------------------------------------
// [NOTE]
// Particular testcase can be run by uncommenting, and commenting the rest
//-------------------------------------------------------------------------


// ____________________________[Tests]________________________________


`include "test1.sv"   // Test 1:  read_single_byte_nonseq_single_Htransfer
// `include "test2.sv"   // Test 2:  write_single_byte_nonseq_single_Htransfer
// `include "test3.sv"   // Test 3:  write_single_halfword_nonseq_single_Htransfer
// `include "test4.sv"   // Test 4:  Reset Single Transfer Test
// `include "test5.sv"   // Test 5:  HSELx Test (Slave Select Test)
// `include "test6.sv"   // Test 6:  WRAP4 Burst Transfer Test for Word
// `include "test7.sv"   // Test 7:  Increment 4 Burst Test for Byte Transfers
// `include "test8.sv"   // Test 8:  Increment 4 Burst Test for Half-Word Transfers
// `include "test9.sv"   // Test 9:  Increment 4 Burst Test for Word Transfers
// `include "test10.sv"  // Test 10: Write/Read Test for Byte
// `include "test11.sv"  // Test 11: Write/Read Test for Half Word
// `include "test12.sv"  // Test 12: Write/Read Test for Word


module tb_top;

  bit HCLK;
  bit HRESETn;
  always #5 HCLK = ~HCLK;
  
  initial begin
    HRESETn = 0;
    #5 HRESETn = 1;
  end

  //------------------------------------------------------------------------
  // Creating instance of interface, to connect DUT and testcase and 
  //------------------------------------------------------------------------
  ahb_intf intf(HCLK, HRESETn);

  //------------------------------------------------------------------------
  // Testcase instance, interface handle is passed to test as an argument
  //------------------------------------------------------------------------
  test t1(intf);

  //------------------------------------------------------------------------
  // DUT instance, interface signals are connected to the DUT ports
  //------------------------------------------------------------------------
  ahb3lite_sram1rw DUT (
    .HCLK       (intf.HCLK),
    .HRESETn    (intf.HRESETn),
    .HSEL       (intf.HSELx),
    .HADDR      (intf.HADDR),
    .HWDATA     (intf.HWDATA),
    .HRDATA     (intf.HRDATA),
    .HWRITE     (intf.HWRITE),
    .HSIZE      (intf.HSIZE),
    .HBURST     (intf.HBURST),
    .HPROT      (intf.HPROT),
    .HTRANS     (intf.HTRANS),
    .HREADYOUT  (intf.HREADYOUT),
    .HREADY     (intf.HREADY),
    .HRESP      (intf.HRESP)
  );
  
  initial begin 
    $dumpfile("dump.vcd"); 
    $dumpvars;
  end

endmodule
