module logic_gates(
    input wire a, b,
    output wire and_out, or_out, not_a, nand_out, nor_out, xor_out, xnor_out
);

    // AND Gate
    assign and_out = a & b;

    // OR Gate
    assign or_out = a | b;

    // NOT Gate (Inverted a)
    assign not_a = ~a;

    // NAND Gate
    assign nand_out = ~(a & b);

    // NOR Gate
    assign nor_out = ~(a | b);

    // XOR Gate
    assign xor_out = a ^ b;

    // XNOR Gate
    assign xnor_out = ~(a ^ b);

endmodule
