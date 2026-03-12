![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# Morse Code to Hex Translator

A TinyTapeout design that lets you enter Morse code sequences using two buttons and displays the decoded hexadecimal digit (0–F) on a 7-segment display.

- [Read the full project documentation](docs/info.md)

## How it works

Enter dots and dashes using `ui_in[0]` (dot) and `ui_in[1]` (dash). Press `ui_in[2]` (confirm) to decode the current sequence and display it on the 7-segment output (`uo_out[6:0]`). Press `ui_in[3]` (clear) to reset and start a new sequence.

If the entered sequence does not match any valid Morse code for 0–F, the error LED (`uo_out[7]`) lights up.

All 16 hex digits are supported using standard International Morse Code:

| Digit | Morse | Digit | Morse |
| ----- | ----- | ----- | ----- |
| 0 | `-----` | 8 | `---..` |
| 1 | `.----` | 9 | `----.` |
| 2 | `..---` | A | `.-` |
| 3 | `...--` | B | `-...` |
| 4 | `....-` | C | `-.-.` |
| 5 | `.....` | D | `-..` |
| 6 | `-....` | E | `.` |
| 7 | `--...` | F | `..-.` |

## External hardware

- 7-segment display on `uo_out[6:0]` (active-high, 1 = segment on)
- 4 pushbuttons on `ui_in[3:0]` (dot, dash, confirm, clear)
- Optional error LED on `uo_out[7]`

## What is Tiny Tapeout?

Tiny Tapeout is an educational project that makes it easier and cheaper than ever to get your digital designs manufactured on a real chip. To learn more, visit [tinytapeout.com](https://tinytapeout.com).

## Resources

- [FAQ](https://tinytapeout.com/faq/)
- [Digital design lessons](https://tinytapeout.com/digital_design/)
- [Join the community](https://tinytapeout.com/discord)
