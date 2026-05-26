`default_nettype none

module tt_um_lib_sys (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    localparam [1:0]
        STATE_IDLE    = 2'b00,
        STATE_SCAN    = 2'b01,
        STATE_ACCESS  = 2'b10,
        STATE_COLLECT = 2'b11;

    reg [1:0] current_state;
    reg [1:0] next_state;

    reg [5:0] internal_counter;

    wire card_scanned   = ui_in[0];
    wire sensor_tripped = ui_in[1];
    wire clear_override = ui_in[2];

    // Outputs
    assign uo_out[0]   = (current_state == STATE_ACCESS);
    assign uo_out[1]   = (current_state == STATE_SCAN) && sensor_tripped;
    assign uo_out[7:2] = internal_counter;

    // Unused bidirectional pins
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

    // Sequential logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state    <= STATE_IDLE;
            internal_counter <= 6'b000000;
        end else begin
            current_state <= next_state;

            if (clear_override)
                internal_counter <= 6'b000000;
            else if (current_state == STATE_COLLECT)
                internal_counter <= internal_counter + 1'b1;
        end
    end

    // Next-state logic
    always @(*) begin
        next_state = current_state;

        case (current_state)

            STATE_IDLE: begin
                if (card_scanned)
                    next_state = STATE_SCAN;
            end

            STATE_SCAN: begin
                if (sensor_tripped)
                    next_state = STATE_ACCESS;
            end

            STATE_ACCESS: begin
                next_state = STATE_COLLECT;
            end

            STATE_COLLECT: begin
                next_state = STATE_IDLE;
            end

            default: begin
                next_state = STATE_IDLE;
            end
        endcase
    end

endmodule
