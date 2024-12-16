module logic_gates_tb;
    // Inputs
    reg a, b;

    // Outputs
    wire and_out, or_out, not_a, nand_out, nor_out, xor_out, xnor_out;

    // Instantiate the logic gates design
    logic_gates uut (
        .a(a),
        .b(b),
        .and_out(and_out),
        .or_out(or_out),
        .not_a(not_a),
        .nand_out(nand_out),
        .nor_out(nor_out),
        .xor_out(xor_out),
        .xnor_out(xnor_out)
    );

    // Testbench logic
    initial begin
        // Apply test cases with different values for a and b
        $monitor("Time=%0d | a=%b b=%b | AND=%b OR=%b NOT_a=%b NAND=%b NOR=%b XOR=%b XNOR=%b", 
                 $time, a, b, and_out, or_out, not_a, nand_out, nor_out, xor_out, xnor_out);
        
        // Test Case 1: a=0, b=0
        a = 0; b = 0; #10;

        // Test Case 2: a=0, b=1
        a = 0; b = 1; #10;

        // Test Case 3: a=1, b=0
        a = 1; b = 0; #10;

        // Test Case 4: a=1, b=1
        a = 1; b = 1; #10;

        // End simulation
        $finish;
    end
endmodule
