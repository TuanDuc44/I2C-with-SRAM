# I2C-with-SRAM
# Overview
The Inter-Integrated Circuit (I2C) is a widely used serial communication protocol designed for short-distance communication between microcontrollers, sensors, memory devices, and other peripherals. It supports multiple master and multiple slave configurations, enabling efficient data exchange in embedded systems.
This repository contains the implementation of I2C bus system with a master and SRAM.
# Work Idea
# I2C Master
Controls the communication by generating the clock (SCL) and initiating read/write operations.
Supports start and stop conditions for bus arbitration.
Handles ACK/NACK responses to ensure successful communication.
Can perform both single-byte and multi-byte transactions.
# I2C Slave - SRAM
Acts as a storage unit where the master can read from or write data to specific memory locations.
Uses an internal register to store incoming address and data.
Implements sequential and random access read operations.

