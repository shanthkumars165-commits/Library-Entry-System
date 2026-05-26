`default_nettype none

// Tiny Tapeout Library System ASIC Submission
module tt_um_lib_sys (
    input  wire [7:0] ui_in,    // Dedicated inputs: ui_in[0]=card_scan, ui_in[1]=sensor_trip, ui_in[2]=clear_count
    output wire [7:0] uo_out,   // Dedicated outputs: uo_out[0]=gate_lock, uo_out[1]=alarm, uo_out[7:2]=capacity_count
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path
    input  wire       ena,      // Always 1 when design is selected
    input  wire       clk,      // System clock
    input  wire       rst_n     // Active-low master hardware reset
);

    // State Encoding declarations
    localparam [1:0] STATE_IDLE       = 2'b00,
                     STATE_SCAN       = 2'b01,
                     STATE_ACCESS     = 2'b10,
                     STATE_COLLECT    = 2'b11;

    reg [1:0] current_state, next_state;
    reg [5:0] internal_counter; // Tracks library count up to 63 students

    // Connect inputs to readable wire labels
    wire card_scanned   = ui_in[0];
    wire sensor_tripped = ui_in[1];
    wire clear_override = ui_in[2];

    // Combinational block mixing bidirectional lines to prevent optimization pruning
    wire wrapper_anchor = ena ^ (^uio_in) ^ (^ui_in[7:3]);

    // Continuous output pin assignments
    assign uo_out[0]   = (current_state == STATE_ACCESS); // Unlock gate signal
    assign uo_out[1]   = (current_state == STATE_SCAN) && sensor_tripped; // Security alert flag
    assign uo_out[7:2] = internal_counter;                // Send count to output pins
    
    // Assign status monitoring to the bidirectional bus
    assign uio_out = {4'b0000, current_state, wrapper_anchor, 1'b0};
    assign uio_oe  = 8'hF0; // Configure lower bits as inputs, upper bits as outputs

    // FSM State Transition Sequential Block
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state    <= STATE_IDLE;
            internal_counter <= 6'b000000;
        end else begin
            current_state <= next_state;
            
            // Increment visitor register when passing successfully through the collection state
            if (current_state == STATE_COLLECT) begin
                internal_counter <= internal_counter + 1'b1;
            end else if (clear_override) begin
                internal_counter <= 6'b000000;
            end
        end
    end

    // Next State Combinational Logic Block
    always @(*) begin
        case (current_state)
            STATE_IDLE: begin
                if (card_scanned) next_state = STATE_SCAN;
                else              next_state = STATE_IDLE;
            end
            
            STATE_SCAN: begin
                if (sensor_tripped) next_state = STATE_ACCESS;
                else                next_state = STATE_SCAN;
            end
            
            STATE_ACCESS: begin
                next_state = STATE_COLLECT;
            end
            
            STATE_COLLECT: begin
                next_state = STATE_IDLE;
            end
            
            default: next_state = STATE_IDLE;
        endcase
    end

endmodule
