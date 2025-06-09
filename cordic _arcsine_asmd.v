module cordic_arcsine_asmd #(
    parameter WIDTH = 16,           // Data width
    parameter FRAC_BITS = 12,       // Number of fractional bits
    parameter MAX_ITER = 10         // Maximum number of iterations
)(
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [WIDTH-1:0] z_in,    // Input value for sin^-1(z)
    output reg [WIDTH-1:0] result,  // Output arcsine result
    output reg done,
    output reg error                
);

    // State definitions
    localparam IDLE = 3'b000;
    localparam INIT = 3'b001;
    localparam COMPUTE = 3'b010;
    localparam FINISH = 3'b011;
    localparam ERROR_STATE = 3'b100;

    // Internal registers
    reg [2:0] state, next_state;
    reg signed [WIDTH-1:0] x, y, theta;
    reg signed [WIDTH-1:0] next_x, next_y, next_theta;
    reg [4:0] i;                    // Iteration counter
    reg [4:0] next_i;
    reg m;                          // Direction flag

    
    reg signed [WIDTH-1:0] atan_table [0:MAX_ITER-1];
    
    
    localparam [WIDTH-1:0] K_FACTOR = 16'h09B7; 
    
    // Initialize arctangent lookup table
    initial begin
        // Values in radians, scaled by 2^FRAC_BITS
        atan_table[0] = 16'h0C90;  // atan(2^0) = 0.7854 (45°)
        atan_table[1] = 16'h076B;  // atan(2^-1) = 0.4636
        atan_table[2] = 16'h03EB;  // atan(2^-2) = 0.2450
        atan_table[3] = 16'h01FD;  // atan(2^-3) = 0.1244
        atan_table[4] = 16'h00FF;  // atan(2^-4) = 0.0624
        atan_table[5] = 16'h007F;  // atan(2^-5) = 0.0312
        atan_table[6] = 16'h003F;  // atan(2^-6) = 0.0156
        atan_table[7] = 16'h001F;  // atan(2^-7) = 0.0078
        atan_table[8] = 16'h000F;  // atan(2^-8) = 0.0039
        atan_table[9] = 16'h0007;  // atan(2^-9) = 0.0019
    end

    // State register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            x <= 0;
            y <= 0;
            theta <= 0;
            i <= 0;
        end else begin
            state <= next_state;
            x <= next_x;
            y <= next_y;
            theta <= next_theta;
            i <= next_i;
        end
    end

    // Next state logic
    always @(*) begin
        next_state = state;
        next_x = x;
        next_y = y;
        next_theta = theta;
        next_i = i;
        done = 1'b0;
        error = 1'b0;
        result = 16'h0000;
        m = 1'b0;

        case (state)
            IDLE: begin
                if (start) begin
                    // Check if input is in valid range [-1, 1]
                    // In Q4.12 format: 1.0 = 0x1000, -1.0 = 0xF000
                    if ($signed(z_in) > $signed(16'h1000) || $signed(z_in) < $signed(16'hF000)) begin
                        next_state = ERROR_STATE;
                    end else begin
                        next_state = INIT;
                    end
                end
            end

            INIT: begin
                 
                next_x = K_FACTOR;
                next_y = 16'h0000;
                next_theta = 16'h0000;
                next_i = 5'b00000;
                next_state = COMPUTE;
            end

            COMPUTE: begin
                if (i < MAX_ITER) begin
                    
                    m = (y < $signed(z_in)) ? 1'b1 : 1'b0;
                    
                    if (m) begin
                        // Counter-clockwise rotation
                        next_x = x - (y >>> i);
                        next_y = y + (x >>> i);
                        next_theta = theta + atan_table[i];
                    end else begin
                        // Clockwise rotation
                        next_x = x + (y >>> i);
                        next_y = y - (x >>> i);
                        next_theta = theta - atan_table[i];
                    end
                    
                    next_i = i + 1;
                end else begin
                    next_state = FINISH;
                end
            end

            FINISH: begin
                result = theta;
                done = 1'b1;
                if (!start) begin
                    next_state = IDLE;
                end
            end

            ERROR_STATE: begin
                error = 1'b1;
                if (!start) begin
                    next_state = IDLE;
                end
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule


