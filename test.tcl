set DLL_BASE winico
set WINICO_VERSION  0.4
set PROJECT_DLL winico04.dll

console show
wm withdraw .
set dir [pwd]
package require -exact Winico $WINICO_VERSION
if ![catch {winico load exclamation} msg] {
  puts "1st Exclamation Test passed."
  console eval "wm geometry . 50x25+0+0"
  wm deiconify .;
  raise .;
  update
  wm geometry . +400+0
  update
  winico setwindow . [set msg]
  puts "you should see a exclamation icon in ."
  update
  after 4000
  set l [winico load leo $PROJECT_DLL]
  winico setwindow . [set l]
  puts "you should see a leo icon in ."
  update
  after 4000
  source testico.tcl
  puts "you should see a red smiley in ."
  puts "and a yellow smiley in the Task-List"
  puts "now go to the taskbar status area"
  puts "and move the mouse over the smiley"
  after 20000 "exit 0"
} else {
  puts "[set msg]:Winico failed to load and run"
  after 5000 "exit 1"
}

