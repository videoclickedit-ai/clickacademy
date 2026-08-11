-- Diagnostic tool (throwaway, not part of the CapCutController contract).
--
-- Clicks File > Import (already proven to work) to land on CapCut's own
-- "Importar" screen, then does a shallow (2-level) scan of window 1's UI
-- elements to check whether the inner "Importar" button (the one that
-- opens the real native macOS Open panel) is exposed to Accessibility.
--
-- Usage: osascript peek-import-screen.applescript

property capcutAppName : "CapCut"
property fileMenuNames : {"Archivo", "File"}
property importItemNames : {"Importar", "Import"}

on dumpChildren(parentEl, label)
	tell application "System Events"
		try
			set kids to UI elements of parentEl
		on error errText
			log label & ": could not read children (" & errText & ")"
			return
		end try
		repeat with k in kids
			try
				set r to role of k as string
			on error
				set r to "?"
			end try
			try
				set n to name of k as string
			on error
				set n to ""
			end try
			log label & " > " & r & " | " & n
		end repeat
	end tell
end dumpChildren

tell application "System Events"
	if not (exists process capcutAppName) then
		log "[FAILED] CapCut not running"
		return
	end if
	tell process capcutAppName
		set frontmost to true
		delay 0.3
		repeat with fName in fileMenuNames
			if exists menu bar item fName of menu bar 1 then
				try
					click menu bar item fName of menu bar 1
					delay 0.3
					repeat with iName in importItemNames
						if exists menu item iName of menu 1 of menu bar item fName of menu bar 1 then
							click menu item iName of menu 1 of menu bar item fName of menu bar 1
							exit repeat
						end if
					end repeat
				end try
			end if
		end repeat
	end tell
end tell

delay 1.5

log "===== TOP-LEVEL ELEMENTS OF WINDOW 1 (on Import screen) ====="
set topKids to {}
tell application "System Events"
	tell process capcutAppName
		try
			set topKids to UI elements of window 1
		on error errText
			log "Could not read window 1 children: " & errText
		end try
	end tell
end tell

set i to 0
repeat with k in topKids
	set i to i + 1
	set r to "?"
	set n to ""
	tell application "System Events"
		try
			set r to role of k as string
		end try
		try
			set n to name of k as string
		end try
	end tell
	log "Child " & i & ": " & r & " | " & n
	my dumpChildren(k, "  Child " & i)
end repeat
