# 4-Stage Library Entry and Collection System

## How it works

This project implements an automated **Library Entry and Collection System** using a structural Finite State Machine (FSM) architecture designed in Verilog HDL. The system regulates an automated physical turnstile gate by monitoring student credential scans, tracking security compliance to prevent tailgating or forced entry, and maintaining a real-time visitor capacity log.

The hardware sequences dynamically through four distinct states based on the system clock:
1. **STATE_IDLE (`2'b00`):** The system waits at rest. The gate lock relay is disabled. When a valid card scan pulse is registered on input pin `ui_in[0]`, the system transitions to the validation phase.
2. **STATE_SCAN (`2'b01`):** Represents the verification phase of student credentials. If the physical turnstile loop sensor is tripped prematurely (`ui_in[1]`) before authentication finishes, an alarm flag (`uo_out[1]`) is raised. Otherwise, it safely advances to the next state.
3. **STATE_ACCESS (`2'b10`):** The gate lock mechanism is officially unlocked by driving output pin `uo_out[0]` HIGH, permitting physical entry through the barrier.
4. **STATE_COLLECT (`2'b11`):** As the student passes through, the internal 6-bit counter increments to update the library's active headcount capacity. The machine then cleanly auto-loops back to `STATE_IDLE`.

An asynchronous active-low reset string (`rst_n`) is integrated to cleanly restore the system to default states and clear capacity counts. A dedicated manual override switch (`ui_in[2]`) is also included to instantly clear the headcount register to zero during operations.

---

## External Hardware Interfaces

To operate this chip in a real-world environment, the physical IO pins interface with standard electronic components on a printed circuit board (PCB) as detailed below:

### Input Peripherals
* **RFID / Barcode Card Scanner (`ui_in[0]`):** Emits a temporary Active-High pulse when a student scans their ID card to initiate entry logic.
* **Walkway Infrared (IR) Beam Sensor (`ui_in[1]`):** Positioned inside the turnstile frame to detect physical movement through the gate walkway.
* **Manual Counter Reset Switch (`ui_in[2]`):** A physical toggle switch or button used by a librarian to manually flush the student count back to zero.
* **System Clock Oscillator (`clk`):** Provides a stable square-wave clock pulse (typically 10 MHz) to synchronize the internal state transitions.
* **Master Hardware Reset (`rst_n`):** An Active-Low push-button to initialize or safely reboot the entire hardware layout.

### Output Peripherals
* **5V Solenoid Gate Lock Relay (`uo_out[0]`):** An electronic relay switch that mechanically releases the turnstile physical locking arm when driven HIGH.
* **Piezo Buzzer / Warning LED (`uo_out[1]`):** Sounds an audible alert or flashes a red indicator lamp if the IR beam sensor is tripped out of order.
* **7-Segment Display / LCD Meter (`uo_out[7:2]`):** Connects to a standard driver chip (like a CD4511 decoder) to display the current library student capacity from the 6-bit binary bus (maximum count value = 63).

---

## How to test

### 1. Initializing the Hardware
* Drive the master reset line `rst_n` LOW to completely flush the register matrix. 
* Verify that the capacity counter (`uo_out[7:2]`) drops to zero and the gate relay (`uo_out[0]`) remains safely locked.

### 2. Normal Entry Simulation Sequence
* Bring `rst_n` HIGH and ensure the project enable line `ena` is driven HIGH.
* Pulse the card scanner pin `ui_in[0]` HIGH for one clock cycle to move from IDLE into the SCAN state.
* Assert the turnstile loop sensor pin `ui_in[1]` HIGH to simulate walking through. Verify that the gate lock relay pin `uo_out[0]` switches to HIGH.
* Allow the clock to cycle; the design will automatically process through the COLLECTION state, incrementing the binary value shown on the capacity bus `uo_out[7:2]` by `1`.

### 3. Testing the Security Alert System
* Trigger a fresh card scan transition via `ui_in[0]` to enter the SCAN phase.
* While stuck in the authentication phase, assert the trip sensor `ui_in[1]` out of order. Verify that the alarm flag pin `uo_out[1]` immediately goes HIGH.

### 4. Manual Counter Override
* Once the capacity meter shows an active count, assert the clear override button `ui_in[2]` HIGH. Verify that `uo_out[7:2]` instantly drops back to `0` on the next rising clock edge.
*
