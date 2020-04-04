;#NoTrayIcon
#Include %A_ScriptDir%\TrayIcon.ahk
#SingleInstance force
;DetectHiddenWindows On


if not A_IsAdmin
{
   Run *RunAs "%A_ScriptFullPath%"  ; 需要 v1.0.92.01+
   ExitApp
}


AllTray()
{
	AllList := []
	for index, element in TrayIcon_GetInfo()
		AllList.Push([element.hicon, element.process, element.tooltip, element.tray, element.idcmd, element.class, False])
	return AllList
}

AllList := AllTray()

HideList := []
Loop
{
    FileReadLine, line, %A_ScriptDir%\Tray.txt, A_Index
    if ErrorLevel
        break
    HideList.Push(line)
}


for index, element in AllList
	for num, exe in HideList
		if element[2] == exe
        {
			element[7] := True
			break
		}
	

for index, pa in AllList
	TrayIcon_Hide(pa[5], pa[4], pa[7])


F2::
Gui, Add, Listview, Grid R30 W694 AltSubmit Checked BackgroundF4F8F4, Hide|Process|ToolTip|Tray|Id

ImageListID := IL_Create(10)	;创建新的初始为空的图像列表，并返回图像列表的唯一ID
LV_SetImageList(ImageListID)	;会直接关联到listview

for index, pa in AllList
{
	hicon := pa[1]
    Process := pa[2]
    Tooltip := pa[3]
	Tray := (pa[4] == "Shell_TrayWnd") ? "通知区域" : "溢出区域"
	Idcmd := pa[5]
	ExeHide := pa[7]
	IconNumber := DllCall("ImageList_ReplaceIcon", "ptr", ImageListID, "int", -1, "ptr", hIcon) + 1
	
	LV_Add((ExeHide ? "Check Icon" : "Icon") . IconNumber,, Process, Tooltip, Tray, Idcmd)
}

LV_ModifyCol()	;如果省略所有参数, 则调整所有列的宽度以适应行的内容
LV_ModifyCol(3, "AutoHdr")

Gui, Add, Button, w80 gFileWrite X610, OK

Gui, show, AutoSize, Saryta -  Tray Icon Hide

Return


GuiEscape:
GuiClose:
FileWrite:
	Rows := []
	RowNumber := 0
	Loop {
		RowNumber := LV_GetNext(RowNumber, "Checked")  ; 在前一次找到的位置后继续搜索.
		If !RowNumber
			break
		Rows.Push(RowNumber)
	}
	File := FileOpen("Tray.txt", "w")
	
	for index, pa in AllList
	{
		flag := False
		for number, row in Rows
			If (index == row){
				flag := True
				Break
			}
		pa[7] := flag
		TrayIcon_Hide(pa[5], pa[4], pa[7])
		If pa[7]
			File.Write(pa[2]"`n")
	}
	File.Close()
	Gui, Destroy
	Reload
Return

