﻿global_EditorThreadIDCounter = 1
global_AllThreads := CriticalObject()

global_elementInclusions := "`n"
loop, files, %A_WorkingDir%\source_Elements\*.ahk, FR
{
	global_elementInclusions .= "#include " A_LoopFileFullPath "`n"
}

Thread_StartManager()
{
	global
	local ExecutionThreadCode
	local threadID
	
	threadID := "Manager"
	FileRead,ExecutionThreadCode,% A_WorkingDir "\Source_Manager\Manager.ahk"
	;~ MsgBox %ExecutionThreadCode%
	AhkThread%threadID% := AhkThread("CriticalSection_Flows := CriticalSection("CriticalSection_Flows ")`n _flows := CriticalObject(" (&_flows) ") `n _settings := CriticalObject(" (&_settings) ") `n _execution := CriticalObject(" (&_execution) ") `n _GlobalVars := CriticalObject(" (&_GlobalVars) ") `n _share := CriticalObject(" (&_share) ")`n _language := CriticalObject(" (&_language) ") `n Global_ThisThreadID = " threadID "`n" ExecutionThreadCode)
	
	global_AllThreads[threadID] := {permanent: true, type: "Manager"}
}


Thread_StoppAll()
{
	global
	local threadsCopy
	threadsCopy := global_Allthreads.clone()
	for threadID, threadpars in threadsCopy
	{
		global_Allthreads.delete(threadID)
		if (AhkThread%threadID%.ahkReady())
			AhkThread%threadID%.ahkterminate(-1)
	}
}

Thread_StartEditor(par_FlowID)
{
	global
	local ExecutionThreadCode
	local threadID
	threadID := "Editor" global_EditorThreadIDCounter++
	FileRead,ExecutionThreadCode,% A_WorkingDir "\Source_Editor\Editor.ahk"
	;~ MsgBox %ExecutionThreadCode%
	AhkThread%threadID% := AhkThread("CriticalSection_Flows := CriticalSection("CriticalSection_Flows ")`n _flows := CriticalObject(" (&_flows) ") `n _settings := CriticalObject(" (&_settings) ") `n _execution := CriticalObject(" (&_execution) ") `n _GlobalVars := CriticalObject(" (&_GlobalVars) ") `n _share := CriticalObject(" (&_share) ")`n _language := CriticalObject(" (&_language) ") `n Global_ThisThreadID = " threadID "`n FlowID = " par_FlowID "`n" global_elementInclusions "`n" ExecutionThreadCode)
	
	global_AllThreads[threadID] := {permanent: false, type: "Editor", flowID: par_FlowID}
}

Thread_StartDraw()
{
	global
	local ExecutionThreadCode
	local threadID
	threadID := "Draw"
	FileRead,ExecutionThreadCode,% A_WorkingDir "\Source_Draw\Draw.ahk"
	;~ MsgBox %ExecutionThreadCode%
	AhkThread%threadID% := AhkThread("CriticalSection_Flows := CriticalSection("CriticalSection_Flows ")`n _flows := CriticalObject(" (&_flows) ") `n _settings := CriticalObject(" (&_settings) ") `n _execution := CriticalObject(" (&_execution) ") `n _GlobalVars := CriticalObject(" (&_GlobalVars) ") `n _share := CriticalObject(" (&_share) ")`n _language := CriticalObject(" (&_language) ") `n Global_ThisThreadID = " threadID "`n" ExecutionThreadCode)
	
	global_AllThreads[threadID] := {permanent: true, type: "Draw"}
}

Thread_Stopped(par_ThreadID)
{
	global
	global_Allthreads.delete(par_ThreadID)
	;~ d(global_Allthreads, "thread " par_ThreadID " beendet")
}