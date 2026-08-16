# Digital Clock Using Verilog HDL

This project implements a digital clock in Verilog HDL that keeps track of hours, minutes, and seconds using clock-driven sequential logic, following a standard 24-hour format.

## 1. Project Overview

The clock maintains three time fields:

```text
Hour   → 00 to 23
Minute → 00 to 59
Second → 00 to 59
```

The overall counting flow works like this:

```text
                Clock
                  |
                  v
             Clock Counter
                  |
          After required count
                  |
                  v
             Second + 1
                  |
        Second reaches 59?
             /          \
           No            Yes
           |              |
           v              v
        Continue       Second = 0
                           |
                           v
                       Minute + 1
                           |
                  Minute reaches 59?
                       /       \
                     No         Yes
                     |           |
                     v           v
                  Continue    Minute = 0
                                  |
                                  v
                              Hour + 1
                                  |
                         Hour reaches 23?
                              /      \
                            No        Yes
                            |          |
                            v          v
                         Continue   Hour = 0
```

This produces a repeating 24-hour clock sequence, where seconds drive minutes, and minutes drive hours.

## 2. Project Objective

This project was built to get practical experience with:

- Sequential digital logic
- Clock-driven counters
- Cascaded counters (seconds feeding minutes feeding hours)
- Modulo-style counting and rollover conditions
- Reset logic
- Verilog HDL
- Behavioral simulation
- RTL elaboration in Vivado

## 3. Features

Based strictly on `clk.v`:

- 24-hour clock format
- Separate hour, minute, and second counters
- 5-bit hour output
- 6-bit minute output
- 6-bit second output
- Reset functionality that clears the internal counter and all three time fields
- Automatic second rollover (59 → 0)
- Automatic minute rollover (59 → 0)
- Automatic hour rollover (23 → 0)
- Full `23:59:59 → 00:00:00` rollover
- A Verilog testbench (`clk_tb.v`) for simulation
- Behavioral simulation in Vivado

## 4. Inputs and Outputs

| Signal | Direction | Width | Description |
|--------|-----------|------:|-------------|
| `clk` | Input | 1 bit | Clock signal driving the design |
| `reset` | Input | 1 bit | Resets the clock values to zero |
| `hour` | Output | 5 bits | Current hour, from 0 to 23 |
| `minute` | Output | 6 bits | Current minute, from 0 to 59 |
| `second` | Output | 6 bits | Current second, from 0 to 59 |

5 bits are enough for `hour` since it only needs to represent values 0–23, which fits within a 5-bit range (0–31). 6 bits are enough for `minute` and `second` since they need to represent 0–59, which fits within a 6-bit range (0–63).

## 5. Internal Counter

```verilog
reg [22:0] count;
```

`count` is a 23-bit internal register that isn't exposed as a module output. Its job is to control how frequently `second` gets incremented. The code checks:

```verilog
if (count == 4)
```

When `count` reaches `4`, it resets back to `0` and `second` increments by one. Otherwise, `count` just keeps incrementing on every clock edge.

It's worth being clear about what this counter is and isn't: in this design, `second` increments once every 5 clock edges (`count` cycling from 0 to 4). This is **not** a real one-second interval — it's a small comparison value chosen so the clock's counting behavior can be observed quickly during simulation, rather than one derived from an actual clock frequency. A real hardware deployment would need `count` compared against a much larger value, calculated from the actual input clock frequency, to produce a genuine 1-second tick.

## 6. Working Principle

### Step 1 — Clock

The entire design is driven by:

```verilog
posedge clk
```

so all register updates — reset, counting, and rollovers — happen only on the rising edge of `clk`. This makes the whole design a synchronous, clock-driven sequential circuit.

### Step 2 — Reset

When `reset` is high at a rising clock edge, `count`, `hour`, `minute`, and `second` are all cleared to `0`. Since this check happens inside the same `always @(posedge clk)` block as everything else, the reset is **synchronous** — it only takes effect at a clock edge, not the instant `reset` goes high.

### Step 3 — Counter

On every clock edge where `reset` is low, the design checks `count`. If `count` hasn't yet reached `4`, it just increments. Once `count` reaches `4`, it resets to `0` and triggers a `second` increment.

### Step 4 — Seconds

Each time `count` reaches `4`, `second` increases by one. When `second` reaches `59`, it's reset to `0` and `minute` is incremented in the same clock edge.

### Step 5 — Minutes

When `minute` reaches `59` (as part of a second rolling over), `minute` resets to `0` and `hour` is incremented.

### Step 6 — Hours

When `hour` reaches `23` (as part of a minute rolling over), `hour` resets to `0`, completing the full cycle:

```text
23:59:59
     |
     v
00:00:00
```

## 7. Clock Sequence

```text
clk
 │
 ├──> count
 │      │
 │      └──> second
 │              │
 │              └──> minute
 │                      │
 │                      └──> hour
 │
 └──> reset control
```

`second`, `minute`, and `hour` form a cascaded counting structure — each field only increments when the field below it rolls over, similar to how a real digital clock counts.

## 8. Time Ranges

| Parameter | Range | Rollover |
|-----------|-------|----------|
| Hour | 0–23 | 23 → 0 |
| Minute | 0–59 | 59 → 0 |
| Second | 0–59 | 59 → 0 |

Each rollover is what triggers the next field up to increment: seconds rolling over increments minutes, and minutes rolling over increments hours. Hours rolling over on their own just wrap back to 0, since there's no larger field above it in this design.

## 9. Verilog Implementation

### Module declaration

`digital_clock` has two inputs (`clk`, `reset`) and three registered outputs (`hour`, `minute`, `second`), with widths of 5, 6, and 6 bits respectively.

### Internal counter

`count[22:0]` is declared as a 23-bit register, though only its comparison against the small value `4` is actually used by the logic — it isn't used as a full 23-bit timer in this version of the design.

### Sequential logic

Everything lives inside a single `always @(posedge clk)` block, so `count`, `second`, `minute`, and `hour` are all updated together, only on the rising clock edge.

### Reset logic

The `if (reset)` branch at the top of the block clears all four registers (`count`, `hour`, `minute`, `second`) to zero whenever `reset` is high at a clock edge.

### Second logic

Inside the `else` branch, `second` only changes when `count` has reached `4`; otherwise only `count` itself increments.

### Minute logic

`minute` increments only as part of the nested check that fires when `second` has just reached `59` — it's not checked independently on every clock edge.

### Hour logic

Similarly, `hour` increments only as part of the nested check that fires when `minute` has just reached `59`, and wraps back to `0` once it reaches `23`.

One implementation detail worth noting: the design uses blocking assignments (`=`) throughout the clocked `always` block rather than non-blocking assignments (`<=`). This still produces correct simulation results for this design, but the more conventional style for sequential/clocked logic in Verilog is to use non-blocking assignments to avoid potential race conditions in more complex designs.

## 10. Testbench

`clk_tb.v` declares `clk` and `reset` as registers and `hour`, `minute`, `second` as wires, then instantiates the design as `uut`.

**Clock generation:**

```verilog
always #10 clk = ~clk;
```

This toggles `clk` every 10 ns, giving:

```text
Half-period = 10 ns
Full period = 20 ns
```

**Reset sequence:**

```text
Initially:
  clk   = 0
  reset = 1

After 20 ns:
  reset = 0
  → the digital clock is allowed to run freely from this point

After 100,000 ns:
  $finish is called, simulation ends
```

The testbench does not perform any automatic assertions or pass/fail checking — it simply drives `clk` and `reset` and lets the `hour`, `minute`, and `second` outputs be observed on the waveform.

## 11. Simulation Results

![Digital Clock Simulation Timing Diagram](https://raw.githubusercontent.com/VASUDEVARAO-SANKARAPU/DIGITAL-CLOCK-USING-VERILOG/refs/heads/main/images/timing_clk_D.jpeg)

In a waveform of this design, you'd expect to see:

- `clk` toggling continuously at a fixed rate, matching the `#10` clock generation in the testbench
- `reset` asserted high briefly at the start of the simulation, then released
- `second` incrementing periodically, based on the internal `count` reaching `4` every 5 clock edges
- `minute` and `hour` staying constant for most of the visible run, since they only change once `second` (and eventually `minute`) rolls over — which takes many more clock cycles to reach than a short simulation window would typically show

**Note:** the screenshot provided along with this request was not actually a capture of this digital clock design — it showed signals and register names (`Count[15:0]`, `UpDownCounterTestbench`) belonging to a different project. Please replace it with an actual waveform capture from `digital_clock_tb`, showing `clk`, `reset`, `hour`, `minute`, and `second`, before publishing this README, so the description above can be checked directly against the real simulation.

## 12. RTL / Elaborated Schematic

![Digital Clock RTL Schematic](https://raw.githubusercontent.com/VASUDEVARAO-SANKARAPU/DIGITAL-CLOCK-USING-VERILOG/refs/heads/main/images/schematic_clk_D.jpeg)

A Vivado elaborated schematic for this design would represent the RTL hardware structure inferred from the Verilog code — not a physical chip layout — and would typically include:

- `clk` and `reset` as top-level inputs
- A register for the internal `count[22:0]` counter
- Separate registers for `hour[4:0]`, `minute[5:0]`, and `second[5:0]`
- Combinational comparison logic (checking `count == 4`, `second == 59`, `minute == 59`, `hour == 23`) feeding into the next-value logic for each register
- Feedback paths from each register back into its own next-value logic, plus the cascaded connections from the second-rollover logic into the minute register, and from the minute-rollover logic into the hour register

**Note:** as with the timing diagram, the schematic screenshot supplied with this request was actually the elaborated view of the earlier up/down counter project (`counter_down_reg[3:0]`, `RTL_SUB`, ports named `counter[3:0]`) — not this digital clock design. Please re-elaborate `clk.v` in Vivado and capture a fresh schematic screenshot showing the actual `count`, `hour`, `minute`, and `second` registers before publishing, so this section accurately reflects what's really in the elaborated design.

## 13. Tools and Technologies

- Verilog HDL
- Xilinx Vivado
- RTL Elaboration
- Behavioral Simulation
- Verilog Testbench

No FPGA hardware implementation was performed — this project is demonstrated through RTL elaboration and behavioral simulation only.

## 14. Project Files

| File | Description |
|------|--------------|
| `clk.v` | Main digital clock design |
| `clk_tb.v` | Testbench for simulation |
| `images/schematic_clk_D.jpeg` | Elaborated RTL schematic from Vivado |
| `images/timing_clk_D.jpeg` | Behavioral simulation waveform |
| `README.md` | Project documentation |

## 15. How to Run the Project in Vivado

1. Open Xilinx Vivado.
2. Create a new RTL project.
3. Add `clk.v` as the design source.
4. Add `clk_tb.v` as the simulation source.
5. Select `digital_clock_tb` as the simulation top module if Vivado doesn't select it automatically.
6. Run **Behavioral Simulation** from the Flow Navigator.
7. Add or observe `clk`, `reset`, `hour`, `minute`, and `second` in the waveform window.
8. Run the simulation and inspect how `second`, `minute`, and `hour` change over time.

## 16. Important Note About Simulation Timing

The design uses:

```verilog
if (count == 4)
```

rather than a real-world clock-divider value derived from an actual system clock frequency.

The counter value is intentionally kept small so that the clock behavior can be observed quickly during simulation. For deployment on an FPGA, the counter comparison would need to be selected according to the actual input clock frequency to generate a true 1-second interval. As written, this design does not run in real-time seconds — it's meant purely to demonstrate the counting and rollover logic in simulation.

## 17. Learning Outcomes

- Designing sequential logic in Verilog using a single clocked `always` block
- Understanding how `posedge clk`-triggered logic updates state
- Implementing cascaded counters, where one field's rollover drives the next field's increment
- Handling rollover conditions for seconds, minutes, and hours
- Using different register widths appropriate to each field's actual range
- Writing a basic Verilog testbench with clock generation and a reset sequence
- Running behavioral simulation in Vivado
- Reading and interpreting timing waveforms
- Getting a first look at how Vivado elaborates HDL code into an RTL register/logic structure

## 18. Possible Future Improvements

These are potential extensions, not part of the current implementation:

- A real clock-divider calculated from the actual FPGA/system clock frequency, to produce true 1-second ticks
- A seven-segment display interface to show the current time
- Time-setting buttons or inputs to preload hour/minute/second values
- 12-hour AM/PM mode instead of the current 24-hour format
- Alarm functionality
- A parameterized clock frequency instead of a fixed simulation counter
- FPGA board implementation and hardware testing
- A clock-enable input instead of relying purely on the fixed simulation counter

## 19. Conclusion

This project demonstrates how a digital clock can be implemented as a set of cascaded, clock-driven counters in Verilog HDL — seconds counting up and rolling over into minutes, minutes rolling over into hours, and hours wrapping back to zero after 23. Working through the reset logic, the rollover conditions, and the testbench helped reinforce how sequential logic in Verilog is structured, and how a reduced counter value can be used to make clock-driven behavior observable within a practical simulation time frame.
