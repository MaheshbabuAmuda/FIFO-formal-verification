# FIFO Formal Verification using SystemVerilog Assertions (SVA)

This project demonstrates the formal verification of a synchronous FIFO using
SystemVerilog Assertions (SVA) and Cadence JasperGold.

The assertions are written in a separate property module and connected to the
FIFO RTL using the `bind` construct, enabling non-intrusive verification without
modifying the original RTL.

## Repository Structure
<img width="495" height="326" alt="image" src="https://github.com/user-attachments/assets/ae9e1f1f-e31d-42e2-914e-eaaaff31cccc" />
        
## Assertions Verified

The following properties are formally verified:

- Reset behavior
- FIFO Full flag generation
- FIFO Empty flag generation
- Overflow detection
- Underflow detection
- Read pointer increment
- Write pointer increment
- Read pointer wrap-around
- Write pointer wrap-around
- FIFO status increment
- FIFO status decrement
- Data input validity
- Data output validity
- Memory stability
- Data output stability

- ## Bug Injection Demonstration

To validate the effectiveness of the assertions, an intentional bug was injected
into the RTL.

// Correct
write_ptr <= write_ptr + 1'b1;

// Bug Injected
write_ptr <= write_ptr + 1'b0;

---

## Learning Outcomes

Through this project I gained hands-on experience in:

- Formal verification methodology
- Writing SystemVerilog Assertions
- Assertion-based verification (ABV)
- Counterexample debugging
- Bug localization using waveforms
- Coverage analysis
- Assertion binding using `bind`
- JasperGold proof and coverage analysis

---

ASIC Design Verification Engineer | SystemVerilog | UVM | Formal Verification | JasperGold
