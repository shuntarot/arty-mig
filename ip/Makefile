output := output

default: build

$(output):
	@if [ ! -d $(output) ]; then mkdir $(output); fi

build: $(output)
	vivado -mode batch -source arty.tcl

clean:
	-rm -rf *.log *.jou $(output) *.cache *.hw *.ip_user_files *.xpr *.os

