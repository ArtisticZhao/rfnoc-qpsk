# gr-qpsk

Integrating UHD and fpga files into one directory

Based on copy block - Bypassing input into output

## Intro

This repo genrate from UHD-RFNOC toolchains. This RFNOC block is create to demodulate QPSK signals to rawdata in FPGA in order to speed up QPSK bitrate. 

The UHD-RFNOC toolchains use the **ersion 3.14**. There are some bugs in the build scripts for the E31x series USRP(the others not test).

## Source tree

The most things is generated by toolchains automatically. The most important folders will list:

- rfnoc/fpga-src
- sim

The tested bitrate is 1.6Mbps. But the block require a higher SNR and have a high error rate. Maybe this caused by `bit_sync`.

The src located at `rfnoc/fpga-src/`

## More information

- [simulation readme](./sim_qpsk_data_gen/README.md)
- [fpga source readme](./rfnoc/fpga-src/README.md)
