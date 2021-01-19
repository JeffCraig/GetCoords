
; Globals
global OSD_GuiTransparentColor := "EEAA99"
global OSD_WarningMessageToggle := 0

global Main_Buttons_VisibleToggle := 1
global Main_CollectCoords := 0

global Coords_Timestamp := A_NowUTC
global Coords_DataToReturn := 0

global Timer_IncrementCounter := 0


; Timers



; GUI MainWindow

Gui, Main:Default
Gui, Main:Color, 0066CC
WinSet, TransColor, 0066CC
Gui, Main:add, button,w180 vGetCoordsStart gGetCoordsStart, Start
Gui, Main:add, button,w180 vGetCoordsStop gGetCoordsStop Hidden, Stop
Gui, Main:show


; GUI OnScreenWindow

Gui, OSD_LocationRequest:New
Gui +LastFound +AlwaysOnTop -Caption +ToolWindow
Gui, OSD_LocationRequest:Color, %OSD_GuiTransparentColor%
Gui, OSD_LocationRequest:Font, s32
Gui, OSD_LocationRequest:Add, Text, vLocationRequestText cLime, Please press Insert to update your location.
WinSet, TransColor, %OSD_GuiTransparentColor% 150

Return


GetCoordsStart:

	If Main_Buttons_VisibleToggle = 1     
	{
		GuiControlShowHide("GetCoordsStart","hide")
		GuiControlShowHide("GetCoordsStop","show")

		Main_Buttons_VisibleToggle = 0
		Main_CollectCoords = 1

		OSD_WarningMessageToggle = 1

		SetTimer, RequestCoordsTimer, 10000
	}

	;While Main_CollectCoords = 1
	;{
	;}

Return


GetCoordsStop:

	If Main_Buttons_VisibleToggle = 0
	{
		GuiControlShowHide("GetCoordsStop","hide")  
		GuiControlShowHide("GetCoordsStart","show")     

		Main_Buttons_VisibleToggle = 1
		Main_CollectCoords = 0

		OSD_WarningMessageToggle = 0

		Gui, OSD_LocationRequest:Hide

		SetTimer, RequestCoordsTimer, OFF
	}

Return


GuiControlShowHide(controls,showhide="Hide"){

           Loop,Parse,controls,|

           GuiControl, %showhide%,%A_LoopField%
}

Return


Insert::
	If Main_CollectCoords = 1
	{
		WinWaitActive, Star Citizen
		BlockInput On
		Sleep, 20
		Send {enter}
		Sleep, 50
		SendRaw /showlocation
		Sleep, 100
		Send {enter}
		Sleep, 20
		DataToReturn = %clipboard% Time:%A_NowUTC%
		CollectCoordsSucceed = 1
		OSD_WarningMessageToggle = 1
		Timer_IncrementCounter = 0
		Gui, OSD_LocationRequest:Hide
		BlockInput Off
	}
Return


WarningToggle() {

	If OSD_WarningMessageToggle = 1
	{
		Gui, OSD_LocationRequest:Font, cLime
		GuiControl, OSD_LocationRequest:Font, LocationRequestText

		Gui, OSD_LocationRequest:Show, x400 y0 NoActivate
		OSD_WarningMessageToggle = 2
	}
	Else If OSD_WarningMessageToggle = 2
	{
		If Timer_IncrementCounter >= 10
		{
			Gui, OSD_LocationRequest:Font, cRed
			GuiControl, OSD_LocationRequest:Font, LocationRequestText

			OSD_WarningMessageToggle = 3
		}
	}
	Else If OSD_WarningMessageToggle = 3
	{

	}
	Else
	{
		Gui, OSD_LocationRequest:Font, cLime
		GuiControl, OSD_LocationRequest:Font, LocationRequestText

		Gui, OSD_LocationRequest:Hide
	}

Return
}


RequestCoordsTimer:

	Timer_IncrementCounter++

	If Timer_IncrementCounter >= 6
	{
		WarningToggle()
	}
	
Return


MainGuiClose:
ExitApp