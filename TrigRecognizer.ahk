#SingleInstance force 			; Only one instance of this script may run at a time!
#NoEnv  						; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  						; Enable warnings to assist with detecting common errors.
#LTrim						; Omits spaces and tabs at the beginning of each line. This is primarily used to allow the continuation section to be indented. Also, this option may be turned on for multiple continuation sections by specifying #LTrim on a line by itself. #LTrim is positional: it affects all continuation sections physically beneath it.
SendMode Input  				; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%		; Ensures a consistent starting directory.
FileEncoding, UTF-16			; Sets the default encoding for FileRead, FileReadLine, Loop Read, FileAppend, and FileOpen(). Unicode UTF-16, little endian byte order (BMP of ISO 10646). Useful for .ini files which by default are coded as UTF-16. https://docs.microsoft.com/pl-pl/windows/win32/intl/code-page-identifiers?redirectedfrom=MSDN

; Section of global variables
EndKeys		:= {	1: "-"	;"/" is missing from "standard" set Hotstring function "Ending Characters" on purpose; this character is applied as trigger for many of my definitions
			,	2: "("
			, 	3: ")"
			, 	4: "["
			, 	5: "]"
			, 	6: "{"
			, 	7: "}"
			, 	8: "'"
			, 	9: ":"
			, 	10: ";"
			, 	11: """"
			, 	12: "\"
			, 	13: ","
			, 	14: "."
			, 	15: "?"
			, 	16: "!"
			, 	17: "`n"
			, 	18: " "
			, 	19: "`t"}
, index := 0, value := "", EndKeys := ""

EndChars 		:= "-()[]{}':;""\,.?!`n `t"	;"/" is missing on purpose; this character is applied as trigger for many of my definitions
; for index, value in EndChars
	; EndKeys .= value	;EndKeys are used for InputHook definitions

Hotstring2("cat/", "*", "🐈")
Hotstring2("dog", "", "🐕")
; Hotstring2("Btw", "C", "by The way")
Hotstring2("ęe", "C*?", "ee")
Hotstring2("ee", "C?*D", "ę")
; Hotstring2("konkwi", "*B0", "stador")
; Hotstring2("`nt", "C*?", "`nT")
; Hotstring2("`nt", "C*?", "`nrabant")
; Hotstring2("tn", "", "Thanks")	;problem: po wywolaniu kazde wcisniecie Enter wywoluje ten ciag
; :T:tn::Thanks     ;mikeyww challenge: https://jacks-autohotkey-blog.com/2020/03/09/auto-capitalize-the-first-letter-of-sentences/
; :C*?:`nt::`nT
; :C*?:`nt::`nrabant
; Hotstring2(". a", "*C?D", ". A")	;*C?‖. a‖SI‖En‖. A‖
; Hotstring2("api", "", "API")

F2:: 
	Hotstring2("cat/", "*", "🐈", "Off")
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Hotstring2(triggerstring, options, hotstring, params*)
{
	global	;asssume global-mode of operation
	local	ihoptions := "", ihobject := {}, Reason := "", BoolVar := false, ExcludedEndKeys := ""
			, index := 0, value := ""
	static	WhatIsCreated := {}

	Switch params[1]	;OnOffToggle
	{
		Default:
			WhatIsCreated[triggerstring] := F_Hon(options, triggerstring, hotstring)
		Case "On":
			WhatIsCreated[triggerstring] := F_Hon(options, triggerstring, hotstring)
		Case "Off":
			ihobject 		:= WhatIsCreated[triggerstring]
,			ihobject.OnEnd := ""
			ihobject.Stop()
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_InputHookOnEnd(ih, triggerstring, options, hotstring)
{
	global	;assume-global mode of operation
	local 	KeyName := ih.EndKey, Reason := ih.EndReason, vFirstLetter1 := "", vRestOfLetters := "", fFirstLetterCap := false, fRestOfLettersCap := false, vFirstLetter2 := "", HowManyInputHooks := 0, IHidentifier := "", key := 0
	static	MatchHit := false, MatchHotstring := "", MatchTriggerstring := ""

	Critical, On
	; OutputDebug, % "A_ThisFunc:" . A_Space . A_ThisFunc . A_Space . "Reason:" . A_Space . Reason . A_Tab . "ih.Input:" . A_Space . ih.Input . A_Space . "triggerstring:" . A_Space . triggerstring . A_Space . "options:" . options . A_Space . "hotstring:" . A_Space . hotstring . "`n"
     OutputDebug, % "Reason:" . A_Space . Reason . A_Space . "input:" A_Space . ih.Input . A_Space . "triggerstring:" . triggerstring . A_Space . "hotstring:" . A_Space . hotstring . "`n"
     ; OutputDebug, % "MatchHit:" . A_Space . MatchHit . A_Space . "MatchTriggerstring:" A_Space . MatchTriggerstring . "`n"
	if (Reason = "Match")
	{
		if (!InStr(options, "C"))
		{
			vFirstLetter1 		:= SubStr(ih.Input, 1, 1)
,			vRestOfLetters 	:= SubStr(ih.Input, 2)
			if vFirstLetter1 is upper
				fFirstLetterCap 	:= true
			if (RegExMatch(ih.Input, "^[[:punct:][:digit:][:upper:][:space:]]*$"))
				fRestOfLettersCap 	:= true

			if (fFirstLetterCap and fRestOfLettersCap)
				StringUpper, MatchHotstring, hotstring

			if (fFirstLetterCap and !fRestOfLettersCap)
			{
				vFirstLetter2 := SubStr(hotstring, 1, 1)
				StringUpper, vFirstLetter2, vFirstLetter2
				MatchHotstring := vFirstLetter2 . SubStr(hotstring, 2)
			}
			if (!fFirstLetterCap)
				MatchHotstring := hotstring
		}
		else
		{
			MatchHotstring := hotstring
		}
		MatchTriggerstring	:= triggerstring
		; OutputDebug, % "Reason:" . A_Space . Reason . A_Space . "MatchTriggerstring:" . A_Space . MatchTriggerstring . A_Tab . "MatchHotstring:" . A_Space . MatchHotstring . A_Tab . "ih.Input:" . A_Space . ih.Input . "`n"

		if (InStr(options, "C1"))
		{
			MatchTriggerstring	:= triggerstring
,			MatchHotstring 	:= hotstring
		}

		if InStr(options, "*")
			{
				; OutputDebug, % "*:" . "`n"
				; OutputDebug, % "Reason:" . A_Space . Reason . A_Tab . "MatchHit:" . A_Space . MatchHit . A_Tab . "MatchTriggerstring:" . A_Space . MatchTriggerstring . A_Tab . "MatchHotstring:" . A_Space . MatchHotstring . A_Tab . "ih.Input:" . A_Space . ih.Input . "`n"
				OutputDebug, % "triggerstring:" . A_Space . triggerstring . A_Tab . "options:" . options . A_Tab . "hotstring:" . A_Space . hotstring . "`n"
				if (InStr(options, "D"))
				{
					if (InStr(options, "B0"))
					{
						SendLevel, 2
						SendEvent, % MatchHotstring
						SendLevel, 0
					}
					else
					{
						SendLevel, 2
						SendEvent, % "{BS" . A_Space . StrLen(triggerstring) . "}" . MatchHotstring
						SendLevel, 0
						OutputDebug, % "SendLevel2" . "`n"
					}
					MatchTriggerstring 	:= ""
,					MatchHotstring 	:= ""
					ih.Start()
					return
				}

				if (InStr(options, "B0"))
					SendInput, % MatchHotstring
				else
					SendInput, % "{BS" . A_Space . StrLen(triggerstring) . "}" . MatchHotstring
				MatchTriggerstring 	:= ""
,				MatchHotstring 	:= ""
				ih.Start()
				return
			}
		else
		{
			ih.Start()
			return
		}
	}

	; OutputDebug, % "MatchTriggerstring:" . A_Space . MatchTriggerstring . A_Space . "triggerstring:" . A_Space . triggerstring . "`n"
	if (Reason = "EndKey") and (triggerstring = MatchTriggerstring) and (ih.Input = "") ;plain (no *) 
	{
		OutputDebug, % "EndKey:" A_Space . ih.EndKey . "|" . "`n"
		; OutputDebug, % "triggerstring:" . A_Space . triggerstring . A_Tab . "options:" . options . A_Tab . "hotstring:" . A_Space . hotstring . "`n"
		if (InStr(options, "D"))
		{
			if (InStr(options, "B0"))
			{
				SendLevel, 2
				SendEvent, % MatchHotstring . "{" . ih.EndKey . "}"
				SendLevel, 0
			}
			else
			{
				SendLevel, 2
				SendEvent, % "{BS" . A_Space . StrLen(MatchTriggerstring) + 1 . "}" . MatchHotstring . "{" . ih.EndKey . "}"
				SendLevel, 0
			}
			; MatchTriggerstring := ""
			; ih.Start()
			; return
		}
		if (InStr(options, "B0"))
			SendInput, % MatchHotstring . "{" . ih.EndKey . "}"
		else
			SendInput, % "{BS" . A_Space . StrLen(MatchTriggerstring) + 1 . "}" . MatchHotstring . "{" . ih.EndKey . "}"
		MatchTriggerstring := ""
		ih.Start()
		return
	}
	else
	{
		OutputDebug, % "EndKey:" . ih.EndKey . "|" . "`n"
		; OutputDebug, % "triggerstring:" . A_Space . triggerstring . A_Space . "hotstring:" . A_Space . hotstring . "`n"
		ih.Start()
		OutputDebug, % "Restart" . "`n"
		return
	}
     ; OutputDebug, % "NoRestart:" . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Hon(options, triggerstring, hotstring)
{
	global	;asssume global-mode of operation: EndChars, EndKeys
	local	ihoptions := "", ihobject := {}, Reason := "", BoolVar := false, ExcludedEndKeys := ""
			, index := 0, value := ""
	static	WhatIsCreated := {}

	if (InStr(options, "?"))
	{
		ihoptions .= "*"
		options 	:= StrReplace(options, "?", "")
	}

	if (InStr(options, "C")) and (!InStr(options, "C1"))
	{
		ihoptions .= "C"
		options	:= StrReplace(options, "C", "")
	}

	if (InStr(options, "D"))	;case sensitive comparison
		options .= "D"

	; for index in EndChars	;Temporarily exclude EndChars for time of definition creation.
	; 	if (InStr(triggerstring, EndChars[index]))
	; 	{
	; 		ExcludedEndKeys .= EndChars[index]
	; 		EndKeys := StrReplace(EndKeys, EndChars[index], "")
	; 	}
	
	ihobject		:= InputHook("V I1" . ihoptions, EndChars, triggerstring)	;I1 by default; L = 1023 by default
	; EndKeys		.= ExcludedEndKeys
	; OutputDebug, % "ihobject:" . A_Space . ihobject . "`n"
	ihobject.OnEnd	:= Func("F_InputHookOnEnd").bind(ihobject, triggerstring, options, hotstring)
	ihobject.Start()
	return ihobject
}