# Adaptive CORDIC-based 32-point DCT

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
### Introduction

The flexible 32-point DCT architecture was developed based on the Adaptic CORDIC (ACor) algorithm. Six different versions were implemented based on the number of DCT-point, i.e., 8-point (8p), 16-point (16p), and 32-point (32p), and the number of ACor stages, i.e., 2-Stage (2S) and 3-Stage (3S). The designs were written in Verilog HDL and were built on an FPGA. The advantages of ACor-based DCT  are employing CORDIC and Twisted-Adder (TA), and TA was proved to have the minimum adder-delay while providing good accuracy outcomes. Therefore, it can achieve higher speed, low latency, and lower logic resources. The DCT core is open-source and free. This core can be applied in DSP systems, robotics, communication systems, video compression and decompression with H.265 standard. It was successully implemented on FPGA.

### 32-point DCT architecture
[![Architecture](https://github.com/duchungle/acor_dct32/blob/main/img/dct32.png)](https://github.com/duchungle/acor_dct32/blob/main/img/dct32.png)

### Implementaion results on Stratix IV FPGA
[![Implemetaion results](https://github.com/duchungle/acor_dct32/blob/main/img/table-results.png)](https://github.com/duchungle/acor_dct32/blob/main/img/table-results.png)

### The demo of compression and compression of Video RGB on FPGA
[![Demo](https://github.com/duchungle/acor_dct32/blob/main/img/demo.png)](https://github.com/duchungle/acor_dct32/blob/main/img/demo.png)
[![Signal](https://github.com/duchungle/acor_dct32/blob/main/img/signaltap.png)](https://github.com/duchungle/acor_dct32/blob/main/img/signaltap.png)
Compression and decompession standard: H.265/HEVC
Format: RGB565, 16-bit color depth 
Resolution: 800x480p
Speed: 30fps

### The layout of this core on Skywater 130nm
[![Layout](https://github.com/duchungle/acor_dct32/blob/main/img/layout_dct.png)](https://github.com/duchungle/acor_dct32/blob/main/img/layout_dct.png)
