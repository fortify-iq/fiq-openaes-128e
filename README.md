# Introduction

This repository contains FIQ-OpenAES-128e - a sample implementation of RAMBAM, the scheme described in the paper [Redundancy AES Masking Basis for Attack Mitigation (RAMBAM)](https://tches.iacr.org/index.php/TCHES/article/view/9481/9022) which protects AES against side-channel attacks. It is intended for academic research only (see [LICENSE](https://raw.githubusercontent.com/fortify-iq/fiq-openaes-128e/master/LICENSE)).

Out of a variety of configurations we chose the fast configuration for publishing in the public domain (one round per clock cycle). We see this configuration as our primary contribution to the protection of AES against physical attacks. According to the orignal AES design goals it should be fast (by the latency and the maximal clock frequency) and compact, equally convenient for implementations in HW and SW. The challenge of combining these design goals with protection against physical attacks remained unsolved for more than 20 years.

In order to solve this challenge, we switched the paradigm. The major existing paradigm is based on the provability of zero leakage under certain assumptions (e.g., TI, DOM, LMDPL). As far as we know, all the suggested schemes based on this paradigm are either slow, or large, or both.

Instead, we suggest a new paradigm - a scheme with the amount of leakage controlled by a security parameter (redundancy). As the redundancy grows, the gate count grows slowly (approximately linearly), while the leakage decreases very rapidly (approximately exponentionally), as we show experimentally in our paper.

The goal of this repository is to provide the academic community with a sample implementation of RAMBAM in the fast configuration (AES128 encryption only), in order to facilitate the research of the RAMBAM protection.

Note that RAMBAM is designed for protection against SCA. Similarly to other masking based protections, it inherently protects against SIFA-1 (see details in [the paper](https://tches.iacr.org/index.php/TCHES/article/view/9481/9022)). However, RAMBAM does not provide protection against other kinds of fault-injection attacks, and for practical use such a protection should be added.

In order to avoid false positives in the t-test analysis, in FIQ-OpenAES-128e we expect the input to be provided in two shares (`state_i = plaintext ^ random; state_share2_i = random`). The output is produced in two shares as well (`ciphertext = state_o ^ state_share2_o`). This way at no point of the calculation is clear data exposed.

FIQ-OpenAES-128e can be configured for redundancies 8 and 13. For redundancy 8, two flavors are supported - one almost literally follows the algorithm described in [the paper](https://tches.iacr.org/index.php/TCHES/article/view/9481/9022)), the other differs form it by an improvement in the implementation of the modular polynomial multiplication only.

For the interface and protocol description, please refer to the [FIQ-OpenAES-128e Datasheet](https://github.com/fortify-iq/fiq-openaes-128e/blob/master/doc/FIQ-OpenAES-128e%20Datasheet.pdf).

## Folders in the Repository

- [aes128enc](https://github.com/fortify-iq/fiq-openaes-128e/blob/master/aes128enc): verilog source code files and headers
- [debug](https://github.com/fortify-iq/fiq-openaes-128e/blob/master/debug): a simple verilog testbench and Makefile to run simulations in Modeslim/Questasim and Xcelium
- [syn](https://github.com/fortify-iq/fiq-openaes-128e/blob/master/syn): an example `bash` script and a liberty library file to run the synthesis in yosys
- [sdc](https://github.com/fortify-iq/fiq-openaes-128e/blob/master/sdc): simple sdc and xdc constraint files with a clock declaration which may be used for sample projects
- [doc](https://github.com/fortify-iq/fiq-openaes-128e/blob/master/doc): Sample RAMBAM AES Implementation Datasheet

## Configuration

The configuration is controlled either from _config.h_ or from scripts. To control the configuration from scripts (sim or syn or other), define Verilog macro _CONFIG_FROM_TOOL_. If this maro is not defined,  the configuratio will be taken from _config.h_.

### Configuration parameters

- PLEVEL: 8 or 13
- NEW_LA_EN: if PLEVEL=8, switches between the two flavors; if REDUDNANCY=13, does not matter.

**Do NOT edit _defines.h_!**

The design top-level is _openAES_128e_

## Simulation

Folder [debug](https://github.com/fortify-iq/fiq-openaes-128e/blob/master/debug) contains a sample testbench and Makefile. You may modify the sample testbench, or replace it with your own, while making the appropriate changes in Makefile.

To run a simulation, use these goals:
- `make vsim_run` - to run Modelsim/Questasim in command line
- `make vsim_rung` - to run Modelsim/Questasim with GUI
- `make xcelium_run` - to run Xcelium in command line
- `make xcelium_rung` - to run Xcelium with GUI
- `make clean` - to clean footprints

## Synthesis

Folder [syn](https://github.com/fortify-iq/fiq-openaes-128e/blob/master/syn) contains the only script for the open-source synthesizer `yosys`. For synthesis we used the [Nangate open cell library](https://github.com/mflowgen/freepdk-45nm/tree/master). You may replace it with any other cell library by changing the variable _LIBRARY_PATH_ in _synthesize.sh_ script. The script is an example only, and you may arbitrarily change it.

To run the synthesis for a chosen configuration type, use the command line `./synthesize.sh`