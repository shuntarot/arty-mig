if {[catch {set gui  $env(GUI) }]} {set gui  "off"}
if {[catch {set dump $env(DUMP)}]} {set dump "off"}

if { [string match "on" $gui ] } {
    start_gui
} else {
    switch $dump {
	"vcd"   { open_vcd out.vcd; log_vcd -level 0 "/tb" }
	"wdb"   { log_wave -r "/tb" }
    }
    run -all
    quit
}

