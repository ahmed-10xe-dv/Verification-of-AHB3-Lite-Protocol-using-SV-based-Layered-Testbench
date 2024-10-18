# Verification-of-AHB3-Lite-Protocol-using-SV-based-Layered-Testbench
This repository showcases my work on AHB3 Lite verification using SystemVerilog, featuring a layered testbench design. It includes various test cases for read and write operations, ensuring data integrity and performance. The project serves as a comprehensive resource for understanding AHB protocol verification and provides practical example.
# AHB3 Lite Verification using SystemVerilog

## Table of Contents
- [Introduction](#introduction)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Verification Plan](#verification-plan)
  - [Functional Test Cases](#functional-test-cases)
  - [Corner Case Test Cases](#corner-case-test-cases)
  - [Performance and Stress Testing](#performance-and-stress-testing)
- [Test Cases Overview](#test-cases-overview)
- [Results and Analysis](#results-and-analysis)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgments](#acknowledgments)

## Introduction
This repository contains a comprehensive implementation of AHB3 Lite verification using SystemVerilog, designed to ensure data integrity, performance, and adherence to the AHB protocol. The project features a layered testbench architecture, facilitating effective verification of both read and write operations, along with detailed test cases that validate various operational scenarios.

## Project Structure

The directory structure of the AHB3 Lite Verification project is as follows:
```markdown
AHB3_Lite_Verification/
├── design/
│   ├── ahb3lite_pkg.sv
│   ├── design.sv
│   ├── mem.mem
│   ├── rl_ram_1r1w_generic.sv
│   └── rl_ram_1r1w.sv
├── others/
│   ├── ex_mem.mem
│   ├── golden_mod.sv
│   ├── run.do
│   └── run.sh
├── src_classes/
│   ├── driver.sv
│   ├── environment.sv
│   ├── generator.sv
│   ├── interface.sv
│   ├── monitor.sv
│   ├── scoreboard.sv
│   └── transaction.sv
├── tests/
│   ├── test1.sv
│   ├── test2.sv
│   ├── test3.sv
│   ├── test4.sv
│   ├── test5.sv
│   ├── test6.sv
│   ├── test7.sv
│   ├── test8.sv
│   ├── test9.sv
│   ├── test10.sv
│   ├── test11.sv
│   ├── test12.sv
│   └── testbench.sv
└── verification_plan/
    ├── Ahmed_Raza_FinalProject.pdf
    └── Testplan_Ahmed_Raza - Testplan.pdf
```


## Getting Started

### Prerequisites
To work with this project, you need the following:
- A SystemVerilog simulator (e.g., ModelSim, VCS, QuestaSim).
- Basic knowledge of digital design and verification concepts.

### Installation
1. Clone the repository to your local machine:
   ```bash
   git clone https://github.com/yourusername/AHB3_Lite_Verification.git
## Verification Plan

### Functional Test Cases
This section describes the functional test cases implemented to verify basic read, write, and burst transfers. Tests include:
- **Single Write and Read Transfers**: Validates data integrity in basic transactions.
- **Burst Transfers**: Tests sequential and non-sequential burst transfers.
- **Error Scenarios**: Simulates and validates responses under erroneous conditions (e.g., incorrect address alignment).

### Corner Case Test Cases
Tests for boundary conditions and edge cases, such as:
- Minimum and maximum burst lengths.
- Idle states.
- Varying response delays.

### Performance and Stress Testing
Describes how performance testing is conducted under different workloads and configurations to evaluate the efficiency and reliability of the AHB3 Lite protocol.

## Test Cases Overview
The following test cases are included:
- **test_001**: Basic Read Data (Byte Sized)
- **test_002**: Basic Write Byte Sized
- **test_003**: Basic Write Half-Word Sized
- **test_004**: Reset Single Transfer Test
- **test_005**: HSELx Test (Slave Select Test)
- **test_006**: WRAP4 Burst Transfer Test for Word
- **test_007**: Increment 4 Burst Test for Byte Transfers
- **test_008**: Increment 4 Burst Test for Half-Word Transfers
- **test_009**: Increment 4 Burst Test for Word Transfers
- **test_010**: Write/Read Test for Byte
- **test_011**: Write/Read Test for Half Word
- **test_012**: Write/Read Test for Word

Each test case includes detailed descriptions and objectives to ensure clarity and ease of understanding.

## Results and Analysis
This section provides a summary of the verification results, including metrics such as code coverage, functional coverage, and bug counts. It discusses the coverage achieved by executed test cases, identified coverage gaps, and an analysis of any failures encountered during verification, along with their root causes and solutions.

## Usage
To run the testbench and execute the test cases:
1. Compile the source files and testbench using your SystemVerilog simulator.
2. Execute the simulation and view the results in the console or waveform viewer.

## Contributing
Contributions are welcome! If you have suggestions for improvements or additional test cases, please fork the repository and submit a pull request.

## License
This project is licensed under the MIT License. See the LICENSE file for details.

## Acknowledgments
I would like to thank all the resources and individuals who contributed to the development and understanding of the AHB protocol and SystemVerilog verification methodologies.

