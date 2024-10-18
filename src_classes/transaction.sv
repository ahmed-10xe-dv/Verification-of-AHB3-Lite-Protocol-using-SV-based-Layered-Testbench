/////////////////////////////////////////////////////////////////////
//   ,------.                    ,--.                ,--.          //
//   |  .--. ' ,---.  ,--,--.    |  |    ,---. ,---. `--' ,---.    //
//   |  '--'.'| .-. |' ,-.  |    |  |   | .-. | .-. ||  || .--'    //
//   |  |\  \ ' '-' '\ '-'  |    |  '--.' '-' ' '-' ||  | \ `--.   //
//   `--' '--' `---'  `--`--'    `-----' `---' `---' `--'  `---'   //
//                                                                 //
//                    AHB3-Lite Transaction Class                   //
//                                                                 //
/////////////////////////////////////////////////////////////////////
//                                                                 //
//             Copyright (C) 2024 10xEngineers                    //
//             www.10xengineers.com                                 //
//                                                                 //
//                                                                 //
/////////////////////////////////////////////////////////////////////

// +FHDR -  Semiconductor Reuse Standard File Header Section  -------
// FILE NAME      : Transaction.sv
// DEPARTMENT     :
// AUTHOR         : Ahmed Raza
// AUTHOR'S EMAIL :
// COMPANY        : 10xEngineers
// ------------------------------------------------------------------
// RELEASE HISTORY
// VERSION DATE        AUTHOR      DESCRIPTION
// 1.0     2024-10-10  Ahmed Raza  Initial creation
// ------------------------------------------------------------------
// KEYWORDS : AHB3-Lite, Transaction, Randomization, Constraints
// ------------------------------------------------------------------
// PURPOSE  : Describes AHB3-Lite Transaction items, including randomization
//            constraints, copy functionality, and debug printing.
// ------------------------------------------------------------------

class Transaction #(parameter HADDR_SIZE = 32, parameter HDATA_SIZE = 32);

  //------------------------------------------------------------------------
  // Declaring Transaction items
  rand bit                       HSELx;
  rand bit      [HADDR_SIZE-1:0] HADDR;
  rand bit      [HDATA_SIZE-1:0] HWDATA;
  rand bit                       HWRITE;
  rand bit      [           2:0] HSIZE;
  rand bit      [           2:0] HBURST;
  rand bit      [           3:0] HPROT;
  rand bit      [           1:0] HTRANS;
  rand bit                       HREADY;
  
  //------------------------------------------------------------------------
  // Additional signals for Transaction response
  bit           [HDATA_SIZE-1:0] HRDATA;
  bit                           HREADYOUT;
  bit                             HRESP;
  bit [7:0]                       cnt;

  //------------------------------------------------------------------------
  // Constraint: Limiting to Single burst, 4-beat wrapping burst, and 4-beat increment burst
  constraint burst_types { HBURST inside {3'b000, 3'b010, 3'b011}; }
  
  //------------------------------------------------------------------------
  // Constraint: Transfer sizes limited to byte, half-word, and word
  constraint Hsize { HSIZE inside {3'b000, 3'b001, 3'b010};}
  
  
   // Constraint: Transfer sizes limited to byte, half-word, and word
  constraint Haddr { HADDR inside {[0:255]};}
  
  
  //------------------------------------------------------------------------
    //Constraint: Data access protection control
    constraint protection_control {
        HPROT == 4'b1;
    }
  
  //------------------------------------------------------------------------
  // Constraint: HREADY and HSELx are always set to 1
    // General ready and selection control constraint
  constraint ready_select {
      HSELx  == 1;
    }
  


//------------------------------------------------------------------------
// Method to print Transaction values in the updated tabular format
function void print_trans();
  $display("----------------------------------------");
  $display("--------- [TRANSACTION DETAILS] ---------");
  $display("|      Signal        |       Value        |");
  $display("+--------------------+--------------------+");
  $display("| HSELx              | %0b                |", HSELx);
  $display("| HADDR              | 0x%0h                |", HADDR);
  $display("| HWDATA             | 0x%0h         |", HWDATA);
  $display("| HWRITE             | %0b                |", HWRITE);
  $display("| HSIZE              | %0d                |", HSIZE);
  $display("| HBURST             | %0d                |", HBURST);
  $display("| HPROT              | %0d                |", HPROT);
  $display("| HTRANS             | %0d                |", HTRANS);
  $display("| HREADY             | %0b                |", HREADY);
  $display("| HRDATA             | 0x%0h                |", HRDATA);
  $display("| HREADYOUT          | %0b                |", HREADYOUT);
  $display("| HRESP              | %0b                |", HRESP);
  $display("+--------------------+--------------------+");
endfunction


  //------------------------------------------------------------------------
  // Method to create a deep copy of the Transaction object
  function Transaction copy();
    Transaction tr_copy;
    tr_copy = new(); // Create a new Transaction instance
    tr_copy.HSELx   = this.HSELx; 
    tr_copy.HADDR  = this.HADDR; 
    tr_copy.HWDATA = this.HWDATA; 
    tr_copy.HWRITE = this.HWRITE; 
    tr_copy.HSIZE  = this.HSIZE; 
    tr_copy.HBURST = this.HBURST; 
    tr_copy.HPROT  = this.HPROT; 
    tr_copy.HTRANS = this.HTRANS; 
    tr_copy.HREADY = this.HREADY;
    return tr_copy;
  endfunction

endclass
