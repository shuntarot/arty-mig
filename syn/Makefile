# export BOARD_FILES = $(realpath ../../../board_files)
output := output

default: build

$(output):
	@if [ ! -d $(output) ]; then mkdir $(output); fi

build: ip $(output)
	vivado -mode batch -source arty.tcl

ip: ../ip/output
../ip/output:
	$(MAKE) -C ../ip build

program:
	vivado -mode tcl -source program.tcl -notrace

clean:
	-rm -rf *.log *.jou $(output) *.cache *.hw *.ip_user_files *.xpr *.html *.xml

