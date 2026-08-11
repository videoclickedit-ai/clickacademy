-- Diagnostic tool (not part of the CapCutController contract).
--
-- Dumps CapCut's accessibility tree (menu bar + a depth-limited walk of the
-- frontmost window) so we can read the REAL names of buttons/menu items
-- instead of guessing them. Only needed if Strategy A (clipboard paste)
-- turns out not to work reliably and we need to build Strategy C
-- (accessibility-driven Import menu automation).
--
-- Depth is capped at 4 levels because "entire contents" on a modern
-- Electron/Qt app like CapCut can recurse into thousands of nodes and hang.
--
-- Usage: osascript ui-inspector.applescript > capcut-ui-dump.txt

property capcutAppName : "CapCut"
property maxDepth : 4

on describeElement(el, depth, indent)
	if depth > maxDepth then return
	try
		set r to role of el as string
	on error
		set r to "?"
	end try
	try
		set n to name of el as string
	on error
		set n to ""
	end try
	log indent & r & " | " & n
	try
		set kids to UI elements of el
		repeat with k in kids
			describeElement(k, depth + 1, indent & "  ")
		end repeat
	end try
end describeElement

tell application "System Events"
	if not (exists process capcutAppName) then
		log "[FAILED] CapCut is not running"
		return
	end if
	tell process capcutAppName
		set frontmost to true
		delay 0.5

		log "===== MENU BAR ====="
		try
			set menuNames to name of every menu bar item of menu bar 1
			repeat with m in menuNames
				log "Menu: " & m
				try
					set itemNames to name of every menu item of menu 1 of menu bar item m of menu bar 1
					repeat with i in itemNames
						log "  - " & i
					end repeat
				end try
			end repeat
		on error errText
			log "Could not read menu bar: " & errText
		end try

		log "===== FRONTMOST WINDOW (depth-limited walk, max " & maxDepth & ") ====="
		try
			set winCount to count of windows
			log "Window count: " & winCount
			if winCount > 0 then
				my describeElement(window 1, 0, "")
			end if
		on error errText
			log "Could not read window elements: " & errText
		end try
	end tell
end tell
