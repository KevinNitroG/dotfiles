#Include "komorebic.lib.ahk"

; TODO: Working on this later
/*
previous_workspace := 0

QueryCurrentWorkspace() {
  command := "komorebic.exe query focused-workspace-index"
  shell := ComObject("WScript.Shell")
  ; Execute a single command via cmd.exe
  exec := shell.Exec(A_ComSpec " /C " command)
  ; Read and return the command's output
  return exec.StdOut.ReadAll()
}

ToggleSecretWorkspace(){
  global previous_workspace
  current := QueryCurrentWorkspace()
  msgbox current previous_workspace
  if (current == "10") {
    FocusWorkspace(previous_workspace)
  }
  else {
    FocusWorkspace(10) 
    previous_workspace := current
  }
}
*/

; #^o::ReloadConfiguration()
#^!r::RestoreWindows()
#^+r:: {
  try RunWait("komorebic.exe stop", , "Hide")
  RunWait("komorebic.exe start", , "Hide")
}

#1::FocusNamedWorkspace("1")
#2::FocusNamedWorkspace("2")
#3::FocusNamedWorkspace("3")
#4::FocusNamedWorkspace("4")
#5::FocusNamedWorkspace("5")
#6::FocusNamedWorkspace("6")
#7::FocusNamedWorkspace("7")
#8::FocusNamedWorkspace("8")
#9::FocusNamedWorkspace("9")
#0::FocusNamedWorkspace("0")
#s::FocusNamedWorkspace("secret")

#[::CycleWorkspace("previous")
#]::CycleWorkspace("next")

#+1::MoveToNamedWorkspace("1")
#+2::MoveToNamedWorkspace("2")
#+3::MoveToNamedWorkspace("3")
#+4::MoveToNamedWorkspace("4")
#+5::MoveToNamedWorkspace("5")
#+6::MoveToNamedWorkspace("6")
#+7::MoveToNamedWorkspace("7")
#+8::MoveToNamedWorkspace("8")
#+9::MoveToNamedWorkspace("9")
#+0::MoveToNamedWorkspace("0")
#!s::MoveToNamedWorkspace("secret")

#+[::CycleMoveToWorkspace("previous")
#+]::CycleMoveToWorkspace("next")

#Left::Focus("left")
#Down::Focus("down")
#Up::Focus("up")
#Right::Focus("right")
^#+[::CycleFocus("previous")
^#+]::CycleFocus("next")

^#+Left::Move("left")
^#+Down::Move("down")
^#+Up::Move("up")
^#+Right::Move("right")
^#p::Promote()

#+Right::ResizeAxis("horizontal", "increase")
#+Left::ResizeAxis("horizontal", "decrease")
#+Up::ResizeAxis("vertical", "increase")
#+Down::ResizeAxis("vertical", "decrease")

#w::ToggleFloat()
^#m::Minimize()
#q::Close()
^#t::ToggleTiling() ; avoid with opening terminal
#m::ToggleMonocle()
; !Enter::F11 ; Toggle fullscreen
^#r::Retile()
^#+p::TogglePause()

^#h::Stack("left")
^#l::Stack("right")
^#k::Stack("up")
^#j::Stack("down")
^#;::Unstack()

#x::FlipLayout("horizontal")
#y::FlipLayout("vertical")

