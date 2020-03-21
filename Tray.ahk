;#NoTrayIcon
#Include %A_ScriptDir%\TrayIcon.ahk
#SingleInstance force
DetectHiddenWindows On

if not A_IsAdmin
{
   Run *RunAs "%A_ScriptFullPath%"  ; 需要 v1.0.92.01+
   ExitApp
}


AllTray()
{
	AllList := []
	for index, element in TrayIcon_GetInfo()
		AllList.Push([element.idcmd, element.tray, element.class, false, element.process])
	return AllList
}

HideTray(Exes)
{
	HideList := []
	for index, hideexe in Exes
		for index, exe in TrayIcon_GetInfo(hideexe)
			HideList.Push([exe.idcmd, exe.tray, exe.class, true, exe.process])
	return HideList
}

AllList := AllTray()

HideExes := []
Loop
{
    FileReadLine, line, %A_ScriptDir%\Tray.txt, %A_Index%
    if ErrorLevel
        break
    HideExes.Push(line)
}

HideList := HideTray(HideExes)

for index, element in AllList
	for num, exe in HideList
		if element[1] == exe[1]{
			element[2] := exe[2]
			element[3] := exe[3]
			element[4] := exe[4]
			element[5] := exe[5]
			break
		}
	


for index, pa in AllList
	TrayIcon_Hide(pa[1], pa[2], pa[4])


F2::
Gui, TrayIcon:New, AlwaysOnTop, Saryta -  Tray Icon Hide
for index, pa in AllList
{
	ClassName := pa[3]
	HideSelect := pa[4]
	ExeHide := pa[5]
	Gui, Add, Checkbox, Checked%HideSelect% vChange%index% gChange, %ExeHide%：
	Gui, Add, Text, , ClassName： %ClassName%
	
}

Gui, Add, Button, w80 gFileWrite, OK

Gui, show, AutoSize 

Return


Change:
	Gui, Submit, NoHide
	for index, pa in AllList
	{
		If pa[4] != Change%index%{
			pa[4] := Change%index%
			TrayIcon_Hide(pa[1], pa[2], pa[4])
		}
	}
Return

FileWrite:
File := FileOpen("Tray.txt", "w")
for index, pa in AllList
	If pa[4]
		File.Write(pa[5]"`n")
File.Close()
Gui, Destroy
Reload
Return
