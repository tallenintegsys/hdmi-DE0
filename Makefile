#INTEL=$(HOME)/intelFPGA_lite/20.1/quartus/bin/
INTEL=$(HOME)/intelFPGA_lite/23.1std/quartus/bin/
MAP=$(INTEL)quartus_map
FIT=$(INTEL)quartus_fit
ASM=$(INTEL)quartus_asm
STA=$(INTEL)quartus_sta
EDA=$(INTEL)quartus_eda
PGM=$(INTEL)quartus_pgm

VFLAGS= -Wall -g2012

all: syn
run: syn pgm

.PHONY: syn pgm clean distclean run
syn:
	$(MAP) --read_settings_files=on --write_settings_files=off hdmi-DE0 -c hdmi-DE0
	$(FIT) --read_settings_files=off --write_settings_files=off hdmi-DE0 -c hdmi-DE0
	$(ASM) --read_settings_files=off --write_settings_files=off hdmi-DE0 -c hdmi-DE0
#	$(STA) hdmi-DE0 -c hdmi-DE0
	$(EDA) --read_settings_files=off --write_settings_files=off hdmi-DE0 -c hdmi-DE0

pgm:
	$(PGM) -c 1 --mode=JTAG -o 'p;hdmi-DE0.sof'

clean:
	rm -f *.vcd a.out

distclean:
	rm -rf *.vcd a.out db incremental_db output_files simulation *.rpt *.sof *. *.summary *.jdi *.sld *.smsg *.pin
