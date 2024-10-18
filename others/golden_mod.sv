//-----------------------------------------------------------------------------
//  Title       : AHB-Lite Reference Model
//  File        : Reference_Model.sv
//  Author      : Ahmed Raza
//  Created     : 10-Oct-2024
//-----------------------------------------------------------------------------
//  Description :
//  This function serves as a reference model for AHB-Lite transactions. It 
//  compares the actual results from the monitor with expected results stored 
//  in local memory. The function handles both read and write operations, 
//  performs byte, half-word, and word-level operations based on the HSIZE 
//  signal, and checks the HRESP response for pass/fail conditions.
//-----------------------------------------------------------------------------

task golden_model(Transaction tr, ref bit [31:0] local_mem[0:255]);

    //-------------------------------------------------------------------------
    // HRESP Check
    // Ensure that the HRESP signal indicates "OKAY"
    //-------------------------------------------------------------------------
  if (tr.HTRANS > 1 && tr.HBURST == 0 ) begin
      if (!tr.HRESP) begin
        $display("[SCB-PASS] HRESP is OKAY");
      end
      else begin
        $error("[SCB-FAIL] HRESP is ERROR, expected OKAY");
      end
    end
  
    //-------------------------------------------------------------------------
    // Burst Transaction and HRESP Check
    //-------------------------------------------------------------------------
  if (tr.HTRANS >= 1 && tr.HBURST >= 1) begin
      if (!tr.HRESP) begin
        $display("[SCB-PASS] HRESP is OKAY during burst transaction");
      end
      else begin
        $error("[SCB-FAIL] HRESP is ERROR during burst transaction, expected OKAY");
      end
    end
  
  
  if (tr.HREADY ) begin  //Perform Read and Write only if HREADY is asserted

    //-------------------------------------------------------------------------
    // Write Operation: Write to Memory Based on HSIZE and HADDR
    //-------------------------------------------------------------------------
    if (tr.HWRITE && tr.HSELx ) begin
        if (tr.HTRANS == 2 || tr.HTRANS == 3 ) begin
          case (tr.HSIZE)
            0: // Byte Write (8 bits)
              case (tr.HADDR[1:0])
                2'b00: local_mem[tr.HADDR[31:2]][7:0]   = tr.HWDATA[7:0];   // 0th Byte
                2'b01: local_mem[tr.HADDR[31:2]][15:8]  = tr.HWDATA[15:8];  // 1st Byte
                2'b10: local_mem[tr.HADDR[31:2]][23:16] = tr.HWDATA[23:16]; // 2nd Byte
                2'b11: local_mem[tr.HADDR[31:2]][31:24] = tr.HWDATA[31:24]; // 3rd Byte
              endcase
            1: // Half-word Write (16 bits)
              case (tr.HADDR[1:0])
                2'b00: local_mem[tr.HADDR[31:2]][15:0]  = tr.HWDATA[15:0];  // 0th Halfword
                2'b10: local_mem[tr.HADDR[31:2]][31:16] = tr.HWDATA[31:16]; // 1st Halfword
              endcase
            2: // Word Write (32 bits)
              if (tr.HADDR[1:0] == 2'b00) begin
                local_mem[tr.HADDR] = tr.HWDATA;  // Full Word Write
              end
            default: 
              $error("[SCB-ERROR] HSIZE %0d is not supported, should be in range 0, 1, 2", tr.HSIZE);
          endcase
        end
      end
    
      //-------------------------------------------------------------------------
      // Read Operation: Compare Memory Data Based on HSIZE and HADDR
      //-------------------------------------------------------------------------
      else if (!tr.HWRITE) begin
        if (tr.HTRANS == 2 || tr.HTRANS == 3) begin
          case (tr.HSIZE)
            0: // Byte Read (8 bits)
              case (tr.HADDR[1:0])
                2'b00: test(local_mem[tr.HADDR[31:2]][7:0],   tr.HRDATA[7:0],  "Byte 0");
                2'b01: test(local_mem[tr.HADDR[31:2]][15:8],  tr.HRDATA[15:8], "Byte 1");
                2'b10: test(local_mem[tr.HADDR[31:2]][23:16], tr.HRDATA[23:16],"Byte 2");
                2'b11: test(local_mem[tr.HADDR[31:2]][31:24], tr.HRDATA[31:24],"Byte 3");
              endcase
            1: // Half-word Read (16 bits)
              case (tr.HADDR[1:0])
                2'b00: test(local_mem[tr.HADDR[31:2]][15:0],   tr.HRDATA[15:0],  "Halfword 0");
                2'b10: test(local_mem[tr.HADDR[31:2]][31:16],  tr.HRDATA[31:16], "Halfword 1");
              endcase
            2: // Word Read (32 bits)
              if (tr.HADDR[1:0] == 2'b00) begin
                test(local_mem[tr.HADDR], tr.HRDATA, "Word");
              end
            default: 
              $error("[SCB-ERROR] HSIZE %0d is not supported, should be in range 0, 1, 2", tr.HSIZE);
          endcase
        end
      end
    end
    
  endtask

  //-----------------------------------------------------------------------------
  // Test Task: Handles Displaying Pass/Fail Messages
  //-----------------------------------------------------------------------------
  task test(input [31:0] expected, input [31:0] actual, input string label);
    if (expected == actual) begin
      $display("[SCB-PASS-%s] \t Expected = %0h, Actual = %0h at time %0t", label, expected, actual, $time);
    end
    else begin
      $error("[SCB-FAIL-%s] \t Expected = %0h, Actual = %0h at time %0t", label, expected, actual, $time);
    end
  endtask