# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
from cocotb.handle import SimHandleBase


BAUD_RATE = 115200
BIT_TIME_LENGTH = 1_000_000_000.0 / BAUD_RATE 
CLK_TOGGLE_RATE = 1_000_000_000.0 / 60019200 / 2 

async def send_uart_frame(dut: SimHandleBase, data: int):
    """Send a single UART frame (start bit, data bits, stop bit)"""
    dut.ui_in.value = dut.ui_in.value & ~0x08  

    # Send start bit (0)
    dut.ui_in.value = dut.ui_in.value & ~0x08
    await cocotb.triggers.Timer(BIT_TIME_LENGTH, units="ns")

    # Send data bits (LSB first)
    for i in range(8):
        bit_value = (data >> i) & 0x01
        dut.ui_in.value = (dut.ui_in.value & ~0x08) | (bit_value << 3)
        await cocotb.triggers.Timer(BIT_TIME_LENGTH, units="ns")

    # Send stop bit (1)
    dut.ui_in.value = dut.ui_in.value | 0x08
    await cocotb.triggers.Timer(BIT_TIME_LENGTH, units="ns")

@cocotb.test()
async def test_tt_um_ook_dds(dut):
    """Testbench for tt_um_ook_dds"""
    dut._log.info("Start")

    # Clock generation
    clock = Clock(dut.clk, CLK_TOGGLE_RATE, units="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.rst_n.value = 0
    dut.ui_in.value = 0x00
    dut.uio_in.value = 0x00
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Send UART frames to configure frequency")

    # Send the frequency register contents in 4 commands
    await send_uart_frame(dut, 0x08)
    await ClockCycles(dut.clk, 4)
    await send_uart_frame(dut, 0xFF)
    await ClockCycles(dut.clk, 4)
    await send_uart_frame(dut, 0xFF)
    await ClockCycles(dut.clk, 4)
    await send_uart_frame(dut, 0xFF)
    await ClockCycles(dut.clk, 4)

    # Test OOK
    dut._log.info("Toggle OOK data")
    dut.ui_in.value = dut.ui_in.value | 0x40 
    await ClockCycles(dut.clk, 5)
    dut.ui_in.value = dut.ui_in.value & ~0x40  
    await ClockCycles(dut.clk, 5)
    dut.ui_in.value = dut.ui_in.value | 0x40  
    await ClockCycles(dut.clk, 20)

    dut._log.info("Test completed")
