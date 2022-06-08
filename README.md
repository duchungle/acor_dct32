# Adaptive CORDIC-based 32-point DCT

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
### Introduction

The flexible 32-point DCT architecture was developed based on the Adaptic CORDIC (ACor) algorithm. Six different versions were implemented based on the number of DCT-point, i.e., 8-point (8p), 16-point (16p), and 32-point (32p), and the number of ACor stages, i.e., 2-Stage (2S) and 3-Stage (3S). The designs were written in Verilog HDL and were built on an FPGA. The advantages of ACor-based DCT  are employing CORDIC and Twisted-Adder (TA), and TA was proved to have the minimum adder-delay while providing good accuracy outcomes. Therefore, it can achieve higher speed, low latency, and lower logic resources. The DCT core is open-source and free. This core can be applied in DSP systems, robotics, communication systems, video compression and decompression with H.265 standard. It was successully implemented on FPGA.

### This is implementaion results on Stratix IV FPGA
[![Implemetaion results](http://www.imm.dtu.dk/~masca/cover-small-vi.jpg)]

### The demo of compression and compression of Video RGB on FPGA

Compression and decompession standard: H.265/HEVC
Format: RGB565, 16-bit color depth 
Resolution: 800x480p
Speed: 30fps
### The layout of this core on Skywater 130nm
