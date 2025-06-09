module tb_cordic_arcsine_asmd;
    reg clk, rst_n, start;
    reg [15:0] z_in;
    wire [15:0] result;
    wire done, error;

    always #5 clk = ~clk;

    cordic_arcsine_asmd dut (
        .clk(clk), .rst_n(rst_n), .start(start), 
        .z_in(z_in), .result(result), .done(done), .error(error)
    );

    // Test task
    task test_arcsine;
        input real val;
        input [200:0] desc;  // Use bit vector for description
        begin
            $display("Test: %s", desc);
            z_in = val * 4096;  // Convert to Q4.12
            start = 1; #10 start = 0;
            wait(done || error);
            
            if (done) 
                $display("Result: %.3f degrees", $signed(result) * 180.0 / (3.14159 * 4096));
            else 
                $display("Error: Out of range");
            #20;
        end
    endtask

    initial begin
        clk = 0; rst_n = 0; start = 0;
        #10 rst_n = 1; #10;

        test_arcsine(0.5, "sin^-1(0.5)");
        test_arcsine(0.8, "sin^-1(0.8)");  
        test_arcsine(0.0, "sin^-1(0.0)");
        test_arcsine(1.5, "sin^-1(1.5) - Error");

        $finish;
    end
endmodule
