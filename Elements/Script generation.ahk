﻿
;Insert in the auto execution section
ScriptGenerationHeader=
(
	#noenv
	#SingleInstance force
)
if a_iscompiled
	ScriptGenerationHeader.= " `n#NoTrayIcon`n"

;Insert in the auto execution section. Afterwards call function ScriptGenerationReplaceImportantVars()
ScriptGenerationIportantVars=
(
	►ParentFlowName=_flowname_
	►CurrentManagerHiddenWindowID=_CurrentManagerHiddenWindowID_
	►ParentElementID=_ElementID_
	►ParentInstanceID=_InstanceID_
	►ParentThreadID=_ThreadID_
	►ParentElementIDInInstance=_ElementIDInInstance_
	
	
)
;Call before writing the content of generated script.
ScriptGenerationReplaceImportantVars(byref generatedScript,temptitle,ElementID,InstanceID="",ThreadID="",ElementIDInInstance="")
{
	global
	stringreplace,generatedScript,generatedScript,_title_,%tempTitle%,all
	stringreplace,generatedScript,generatedScript,_flowname_,% flowSettings.Name,all
	stringreplace,generatedScript,generatedScript,_CurrentManagerHiddenWindowID_,%CurrentManagerHiddenWindowID%,all
	stringreplace,generatedScript,generatedScript,_ElementID_,%ElementID%,all
	stringreplace,generatedScript,generatedScript,_InstanceID_,%InstanceID%,all
	stringreplace,generatedScript,generatedScript,_ThreadID_,%ThreadID%,all
	stringreplace,generatedScript,generatedScript,_ElementIDInInstance_,%ElementIDInInstance%,all
}


;Insert in the auto execution section
ScriptGenerationCommunicationPart1=
(
	;open a window so the main program can stop it

	gui,►GUI:new,,_title_§_CurrentManagerHiddenWindowID_§
	gui,►GUI:add,edit,vCommandWindowRecieve gCommandForTrigger
	;~ gui,►GUI:show,w800
)

;Insert on the bottom. No autoexecution! Part 3 must be inserted right after part 2 and optionally some other command evaluation
ScriptGenerationCommunicationPart2=
(
	;Receive command
	CommandForTrigger:
	gui,submit,NoHide
	ReceivedCommandsBuffer=`%CommandWindowRecieve`%█▬►
	
	
	Loop
	{
		StringGetPos,tempCommandLength,ReceivedCommandsBuffer,█▬►
		if (errorlevel)
			break
		
		StringLeft,tempCommand,ReceivedCommandsBuffer,tempCommandLength
		StringTrimLeft,ReceivedCommandsBuffer,ReceivedCommandsBuffer,tempCommandLength+3
		
		;Read command and fill an object with informations
		
		tempNewReceivedCommand:=strobj(tempCommand)
)
;Part 3 must be inserted right after part 2 and optionally some other command evaluation
ScriptGenerationCommunicationPart3=
(
		if (tempNewReceivedCommand["Function"]="exit")
		{
			
			FileDelete,`%A_ScriptFullPath`%
			exitapp
			
		}
	}
	return
	
	►GUIguiclose:
	FileDelete,`%A_ScriptFullPath`%
	exitapp
	return
)

;Insert in the auto execution section
ScriptGenerationEndWhenFlowClosesPart1=
(
	settimer,endWhenFlowCloses,1000
)

;Insert on the bottom. No autoexecution!
ScriptGenerationEndWhenFlowClosesPart2=
(
	endWhenFlowCloses:
	DetectHiddenWindows on
	DetectHiddentext on
	settitlematchmode,1
	ifwinnotexist,CommandWindowOfEditor,`% "Ѻ" ►ParentFlowName "Ѻ"
	{
		FileDelete,`%A_ScriptFullPath`%
		exitapp
	}
	
	return

)

ScriptGenerationFunctionSendCommand=
(
	com_SendCommand(CommandObject,WhichCommandWindow,ToFlowName="")
	{
		global ►CurrentManagerHiddenWindowID
		commandstring:=strobj(CommandObject)
		
		DetectHiddenWindows on
		DetectHiddentext on
		settitlematchmode,1
		ifinstring,WhichCommandWindow,editor
		{
			ControlSetText,edit1,`%commandstring`% ,CommandWindowOfEditor,`% "Ѻ" ToFlowName "Ѻ§" ►CurrentManagerHiddenWindowID "§"
		}
		else ifinstring,WhichCommandWindow,custom
		{
			ControlSetText,edit1,`%commandstring`%,`%ToFlowName`%
		}
		else
		{
			ControlSetText,edit1,`%commandstring`%,CommandWindowOfManager, "§" ►CurrentManagerHiddenWindowID "§"
		}
		return errorlevel
	}

)


ScriptGenerationFunctionStrObj=
(

Class StrObj {		; String-object-file (data structures in YAML-like style). By Learning one
	static Version := 1.01, Author := "Learning one", WebSite := "http://www.autohotkey.com/board/topic/104854-string-object-file-data-structures-in-yaml-like-style/"

	static Indent := "``t"
	static EscapedIndent := "````t"			; when converting object to string 
	static NewLine := "``n"					; when parsing a string (reading)
	static EscapedNewLine := "````n"			; when converting object to string 

	static NewLineInOutputString := "``r``n"	; when writing to a string
	static Omit := "``r"						; omitted when parsing a string (reading) 
	static Equal := ":"						; Equal is a sign which delimits key from its value; key: value
	static DerefValues := 1
	static SmartIndentTrim := 1				; useful in [indented continuation sections] and [overindented text in .txt files] which contain YAML-like string
	static FileAppendEncoding := "UTF-8"

	Auto(Input,SaveToFileFullPath="") {						; Automatically concludes what user wants to do. Called by StrObj() function
		Att := FileExist(Input)
		if (Att != "" and InStr(Att, "D") = 0) {			; Input is FILE - user wants to read that file, construct object from its contents (string) and return object
			FileRead, FileContents, `% Input
			ReturnValue := this.StrToObj(FileContents)		; returns object
			if (SaveToFileFullPath != "") 					; user actually wants to save String (FileContents) to a file
				ToSave := RTrim(FileContents, " ``t``n``r"), SaveToFile := 1
		}
		else if (IsObject(Input) = 1) {						; Input is OBJECT - user wants to convert it to string and return that string
			ReturnValue := this.ObjToStr(Input)				; returns string
			if (SaveToFileFullPath != "")					; user actually wants to save String (ReturnValue) to a file
				ToSave := ReturnValue, SaveToFile := 1	
		}
		else {												; Input is STRING - user wants to construct object from that string and return that object
			ReturnValue := this.StrToObj(Input)				; returns object
			if (SaveToFileFullPath != "")					; user actually wants to save String (Input) to a file
				ToSave := RTrim(Input, " ``t``n``r"), SaveToFile := 1
		}
		
		if (SaveToFile = 1) {								; Return value:  0 = no problems (Successful). Anything else = problems (failure). 
			if (FileExist(SaveToFileFullPath) != "") {		; SaveToFileFullPath already exists - delete it first
				FileDelete, `% SaveToFileFullPath
				if (ErrorLevel > 0)							; ErrorLevel is set to the number of files that failed to be deleted (if any) or 0 otherwise.
					return ErrorLevel
			}
			FileAppend, `% ToSave, `% SaveToFileFullPath, `% this.FileAppendEncoding
			return ErrorLevel 								; ErrorLevel is set to 1 if there was a problem or 0 otherwise.
		}
		
		return ReturnValue									; if user was not saving to a file, function will return him object or string
	}

	StrToObj(String) {		; Creates object from YAML-like string.
		
		;=== Preparation ===
		Indent := this.Indent
		NewLine := this.NewLine
		Omit := this.Omit
		Equal := this.Equal
		DerefValues := this.DerefValues
		SmartIndentTrim := this.SmartIndentTrim
		obj := [], KeyNames := [], Items := [], LastDepth := 0, CurNum := [0,0,0,0,0,0,0,0,0,0], IndentLen := StrLen(Indent)
		
		;=== SmartIndentTrim ===
		if (SmartIndentTrim = 1) {	; useful in [indented continuation sections] and [overindented text in .txt files] which contain YAML-like string
			Counter := 0, IntentsToTrim := 100000	; IntentsToTrim can be any arbitrary big number... It's unlikely user will have so many tabs  at the left (indentation)
			
			;=== See how many indents at the left have to be trimmed and store it in IntentsToTrim variable ===
			; If you are using indented continuation sections, always use expression assignment. More info here; http://www.autohotkey.com/board/topic/104735-continuation-sections-left-tabs-in-the-first-line/
			; Count only left tabs in the first not-blank line (not in all lines) because first not-blank line must always be at the highest level...
			Loop, parse, String, `% NewLine , `% Omit
			{
				if A_LoopField is space	; ignore
					continue
				Field := A_LoopField, IndentsInThisLine := 0, FirstLineDetected := 1
				While (SubStr(Field,1,IndentLen) = Indent) {
					Field := SubStr(Field, IndentLen+1)	; removes first `%IndentLen`% characters
					IndentsInThisLine += 1
				}
				if (IndentsInThisLine < IntentsToTrim)
					IntentsToTrim := IndentsInThisLine
				if (FirstLineDetected = 1)
					break
			}
			
			;=== If there are extra indents in this string to trim at the left ===
			if (IntentsToTrim < 100000 and IntentsToTrim > 0) {		; there are extra indents in this string to trim at the left
				NewString := ""
				Loop, parse, String, `% NewLine , `% Omit
				{
					Field := SubStr(A_LoopField, IntentsToTrim+1)	; removes first `%IntentsToTrim`% characters
					NewString .= Field NewLine
				}
				String := SubStr(NewString,1, StrLen(NewString)-StrLen(NewLine))	; overwrite String with NewString, which hasn't got extra indents at the left
			}
		}
		
		;=== Extract data from string ===
		Loop, parse, String, `% NewLine , `% Omit
		{
			CurDepth := 1, IsPreviousItemValueObject := 0
			if A_LoopField is space
				continue
			Field := RTrim(A_LoopField, " ``t``r")
			While (SubStr(Field,1,IndentLen) = Indent) {
				Field := SubStr(Field, IndentLen+1)	; removes first `%IndentLen`% characters
				CurDepth += 1
			}
			
			if (CurDepth != LastDepth) {	; Indent change
				if (CurDepth < LastDepth)	; <--- Decreased indent
					CurNum[LastDepth] := 0	; 		restart numbering for LastDepth
				if (CurDepth > LastDepth) {	; ---> Increased indent
					CurNum[CurDepth] := 0	; 		restart numbering for CurDepth
					if (CurDepth > 1)
						IsPreviousItemValueObject := 1
				}
				LastDepth := CurDepth
			}
			
			if (SubStr(Field,1,1) = "-") {		; if FirstChar is "-"
				CurNum[CurDepth] += 1
				NewItem := CurNum[CurDepth]  ": " Trim(SubStr(Field,2), " ``t``r")	; Exa: "- Joe" --> "2: Joe"
			}
			else
				NewItem := Field	; Exa: "FirstName: John"
			
			EqualPos := InStr(NewItem, Equal)
			k := SubStr(NewItem, 1, EqualPos-1), v := SubStr(NewItem, EqualPos+1)
			k := Trim(k, " ``t``r"), v := Trim(v, " ``t``r")	; k=key, v=value
			
			if (DerefValues = 1)
				Transform, v, Deref, `% v
			
			KeyNames[CurDepth] := k
			
			DepthNames := []
			Loop, `% CurDepth
				DepthNames.Insert(KeyNames[A_Index])	; DepthNames exa: ["PhoneNumbers", "1", "Type"]
			
			Items.Insert([DepthNames,v])				; Items structure: DepthNames,value
			if (IsPreviousItemValueObject = 1) {
				PreviousItemNum := Items.MaxIndex() - 1
				Items[PreviousItemNum].2 := []			; value becomes object
			}		
		}
		
		;=== Construct object ===
		For k,v in Items	; Items structure: DepthNames,value
		{
			n := v.1			; n = DepthNames. Exa: ["PhoneNumbers", "1", "Type"]
			value := v.2		; values. Exa: "Joe"
			
			if value is Integer
				value := value*1	;  assigns a pure number instead of string - important for some COM methods
			
			CurLevel := n.MaxIndex()
			if (CurLevel = 1)
				obj[n.1] := value
			else if (CurLevel = 2)
				obj[n.1][n.2] := value
			else if (CurLevel = 3)
				obj[n.1][n.2][n.3] := value
			else if (CurLevel = 4)
				obj[n.1][n.2][n.3][n.4] := value
			else if (CurLevel = 5)
				obj[n.1][n.2][n.3][n.4][n.5] := value
			else if (CurLevel = 6)
				obj[n.1][n.2][n.3][n.4][n.5][n.6] := value
			else if (CurLevel = 7)
				obj[n.1][n.2][n.3][n.4][n.5][n.6][n.7] := value
			else if (CurLevel = 8)
				obj[n.1][n.2][n.3][n.4][n.5][n.6][n.7][n.8] := value
			else if (CurLevel = 9)
				obj[n.1][n.2][n.3][n.4][n.5][n.6][n.7][n.8][n.9] := value	; etc
		}
		return obj
	}
	
	ObjToStr(Obj, Depth=9, CurIndent="") {	; Converts object to YAML-like string.
		For k,v in Obj
		{
			if (IsObject(v) = 1 and Depth>1 ) {
				middlepart := this.NewLineInOutputString StrObj.ObjToStr(v, Depth-1, CurIndent this.Indent)
				if k is Integer
					ToReturn .= CurIndent "-" A_Space middlepart
				else {
					StringReplace, k, k, `% this.Indent, `% this.EscapedIndent, all
					StringReplace, k, k, `% this.NewLine, `% this.EscapedNewLine, all										
					ToReturn .= CurIndent k this.Equal A_Space middlepart
				}				
			}
			else {
				StringReplace, v, v, `% this.Indent, `% this.EscapedIndent, all
				StringReplace, v, v, `% this.NewLine, `% this.EscapedNewLine, all
				
				if k is Integer
					ToReturn .= CurIndent "-" A_Space v this.NewLineInOutputString
				else {
					StringReplace, k, k, `% this.Indent, `% this.EscapedIndent, all
					StringReplace, k, k, `% this.NewLine, `% this.EscapedNewLine, all										
					ToReturn .= CurIndent k this.Equal A_Space v this.NewLineInOutputString
				}
			}
		}
		return RTrim(ToReturn, NewLineInOutputString)
	}	; http://www.autohotkey.com/forum/post-426623.html#426623	
}

StrObj(Input,SaveToFileFullPath="") {					; Part of [Class StrObj]
	return StrObj.Auto(Input,SaveToFileFullPath)
}

)
;~ FileDelete,test.ahk
;~ FileAppend,%ScriptGenerationFunctionStrObj%,test.ahk



