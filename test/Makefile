SRC_DIR = $(PWD)/../src

SOURCES = \
	$(SRC_DIR)/tt_um_morse_to_hex.v \
	$(SRC_DIR)/morseToHex.v \
	$(SRC_DIR)/hexto7seg.v \
	$(PWD)/tb.v

.PHONY: all clean

all: sim
	vvp sim

sim: $(SOURCES)
	iverilog -g2001 -o sim $(SOURCES)

clean:
	rm -f sim tb.fst
