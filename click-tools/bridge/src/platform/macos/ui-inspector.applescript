-- Diagnostic tool (not part of the CapCutController contract).
--
-- Dumps CapCut's native menu bar (top-level menus + their items) so we can
-- read the REAL names of menu entries (e.g. is there a File > Import?)
-- instead of guessing them. This is the input for building Strategy C
-- (accessibility-driven menu automation) if Strategy A (clipboard paste)
-- doesn't work.
--
-- Kept deliberately simple: no deep UI-element tree walk. Electron/Qt apps
-- like CapCut can have huge, slow accessibility trees, and a menu bar dump
-- is usually enough to find the Import entry.
--
-- Usage: osascript ui-inspector.applescript > capcut-ui-dump.txt

property capcutAppName : "CapCut"

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
				on error errText
					log "  (could not read items: " & errText & ")"
				end try
			end repeat
		on error errText
			log "Could not read menu bar: " & errText
		end try

		log "===== WINDOW INFO ====="
		try
			set winCount to count of windows
			log "Window count: " & winCount
			if winCount > 0 then
				log "Window 1 name: " & (name of window 1 as string)
				try
					set btnNames to name of every button of window 1
					log "Buttons in window 1: " & btnNames
				on error errText
					log "Could not list buttons: " & errText
				end try
			end if
		on error errText
			log "Could not read window info: " & errText
		end try
	end tell
end tell
