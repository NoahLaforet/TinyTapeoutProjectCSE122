import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

async def reset_dut(dut):
    dut.rst_n.value = 0
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    for _ in range(20):
        await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    for _ in range(5):
        await RisingEdge(dut.clk)

async def send_morse(dut, pattern):
    """Send a morse pattern (string of '.' and '-') then confirm"""
    dut.ui_in.value = 0b00001000  # assert clear first
    await RisingEdge(dut.clk)
    dut.ui_in.value = 0
    await RisingEdge(dut.clk)
    for sym in pattern:
        if sym == '.':
            dut.ui_in.value = 0b00000001  # dot
        else:
            dut.ui_in.value = 0b00000010  # dash
        await RisingEdge(dut.clk)
        dut.ui_in.value = 0
        await RisingEdge(dut.clk)
    # confirm
    dut.ui_in.value = 0b00000100
    await RisingEdge(dut.clk)
    dut.ui_in.value = 0
    await RisingEdge(dut.clk)

@cocotb.test()
async def test_morse(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    await reset_dut(dut)

    tests = [
        ("E",  ".",     0b1111001, 0),
        ("A",  ".-",    0b1110111, 0),
        ("D",  "-..",   0b1011110, 0),
        ("B",  "-...",  0b1111100, 0),
        ("C",  "-.-.",  0b0111001, 0),
        ("F",  "..-.",  0b1110001, 0),
        ("0",  "-----", 0b0111111, 0),
        ("1",  ".----", 0b0000110, 0),
        ("2",  "..---", 0b1011011, 0),
        ("3",  "...--", 0b1001111, 0),
        ("4",  "....-", 0b1100110, 0),
        ("5",  ".....", 0b1101101, 0),
        ("6",  "-....", 0b1111101, 0),
        ("7",  "--...", 0b0000111, 0),
        ("8",  "---..", 0b1111111, 0),
        ("9",  "----.", 0b1100111, 0),
        ("?",  "----",  0b0111111, 1),  # invalid, error LED high
    ]

    for char, pattern, expected_ssd, expected_err in tests:
        await send_morse(dut, pattern)
        ssd = int(dut.uo_out.value) & 0x7F
        err = (int(dut.uo_out.value) >> 7) & 1
        assert ssd == expected_ssd, f"FAIL {char}: ssd={bin(ssd)} expected={bin(expected_ssd)}"
        assert err == expected_err, f"FAIL {char}: err={err} expected={expected_err}"
        dut._log.info(f"PASS {char} | {pattern} | ssd={bin(ssd)[2:].zfill(7)}")