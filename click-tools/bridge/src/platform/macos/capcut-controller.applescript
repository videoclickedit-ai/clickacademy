-- CapCutController (macOS adapter)
-- Implements the contract described in /shared/types/capcut-controller.d.ts
-- Zero external dependencies: pure AppleScript + System Events (built into macOS).
--
-- Requires: System Settings > Privacy & Security > Accessibility must allow
-- "Terminal" (or whatever app runs osascript) to control your computer.
-- macOS will prompt for this automatically on first run.
--
-- ===== FASE 1 findings (documented, not guessed) =====
-- - CapCut's native macOS menu bar IS scriptable (confirmed via
--   ui-inspector.applescript): Archivo/File > Importar/Import exists as a
--   real menu item, with keyboard shortcut Cmd+I.
-- - Cmd+I opens CapCut's OWN "Archivos multimedia" browser screen (a custom
--   view listing already-imported project media), NOT the OS file picker
--   directly.
-- - That screen's inner "Importar" button, and CapCut's window content in
--   general, is NOT exposed to macOS Accessibility (confirmed empty
--   results scanning window children with System Events) — CapCut renders
--   its own UI with a custom toolkit that doesn't implement NSAccessibility
--   for internal widgets. We cannot click that button by name, and we
--   deliberately do NOT blind-click at guessed pixel coordinates inside the
--   user's real, live project — the risk of misclicking something else in
--   their actual work is not worth it for an unverified shortcut.
-- - The native macOS "Selecciona un recurso multimedia" Open panel that the
--   inner Importar button opens IS a standard, fully accessible NSOpenPanel
--   (system-provided, not custom-rendered), confirmed reachable and
--   scriptable with Cmd+Shift+G ("Go to Folder") to jump straight to an
--   exact file path.
--
-- ===== Resulting design =====
-- Fully automated except ONE safe, visible manual click (the user clicking
-- CapCut's own "Importar" button, which they can see and trust). Everything
-- before and after that click is automated: detecting CapCut, focusing it,
-- opening the import screen (Cmd+I), waiting for the native panel to
-- appear, then navigating straight to the exact file and confirming — so
-- the user never has to search for the downloaded file themselves.

use AppleScript version "2.4"
use scripting additions

property capcutAppName : "CapCut"
property nativeDialogTitleCandidates : {"Selecciona un recurso multimedia", "Select Media", "Select a media resource"}
property maxWaitSeconds : 25

-- ---------- Contract: isCapCutRunning() ----------
on isCapCutRunning()
	tell application "System Events"
		return (exists (processes where name is capcutAppName))
	end tell
end isCapCutRunning

-- ---------- Contract: focusCapCut() ----------
on focusCapCut()
	if not isCapCutRunning() then return false
	tell application capcutAppName to activate
	delay 0.8
	tell application "System Events"
		return (frontmost of process capcutAppName)
	end tell
end focusCapCut

on countCapCutWindows()
	tell application "System Events"
		tell process capcutAppName
			return (count of windows)
		end tell
	end tell
end countCapCutWindows

on openImportScreen()
	tell application "System Events"
		tell process capcutAppName
			set frontmost to true
			delay 0.3
			keystroke "i" using command down
		end tell
	end tell
end openImportScreen

-- Polls for the native Open panel to appear (it does once the user clicks
-- CapCut's own "Importar" button — a manual step we ask for via notification
-- since that button isn't accessibility-scriptable).
on waitForNativeOpenPanel(baselineWindowCount)
	set waited to 0
	repeat while waited < maxWaitSeconds
		tell application "System Events"
			tell process capcutAppName
				repeat with t in nativeDialogTitleCandidates
					if exists window t then
						try
							perform action "AXRaise" of window t
						end try
						delay 1.2 -- let the panel finish animating in and become key window
						return true
					end if
				end repeat
				if (count of windows) > baselineWindowCount then
					delay 1.2
					return true
				end if
			end tell
		end tell
		delay 1
		set waited to waited + 1
	end repeat
	return false
end waitForNativeOpenPanel

-- Once the native Open panel is confirmed open, jump straight to the exact
-- file via "Go to Folder" instead of navigating folders by hand.
on navigateAndSelect(filePath)
	tell application "System Events"
		try
			delay 0.4
			keystroke "G" using {command down, shift down}
			delay 0.8
			keystroke filePath
			delay 0.4
			key code 36 -- Return: navigate to / select the file
			delay 0.8
			key code 36 -- Return: confirm the Importar/Open button
		on error errText
			log "[CapCut] Native panel automation failed: " & errText
			return false
		end try
	end tell
	return true
end navigateAndSelect

-- ---------- Fallback ----------
-- Reveals the file in Finder so the user has zero searching to do if
-- everything else fails.
on revealInFinder(filePath)
	tell application "Finder"
		activate
		reveal (POSIX file filePath)
	end tell
	return true
end revealInFinder

-- ---------- Entry point for the FASE 1 spike ----------
-- Usage: osascript capcut-controller.applescript /absolute/path/to/test.png
on run argv
	if (count of argv) is 0 then
		log "[FAILED] No file path provided"
		error "Usage: osascript capcut-controller.applescript <absolute-path-to-image>"
	end if
	set filePath to item 1 of argv

	log "[Click Tools] Image detected: " & filePath

	if not isCapCutRunning() then
		log "[CapCut] Application NOT detected"
		log "[FAILED] CapCut is not running. Open CapCut with a project and try again."
		revealInFinder(filePath)
		return
	end if
	log "[CapCut] Application detected"
	log "[CAPCUT_DETECTED]"

	set didFocus to focusCapCut()
	if didFocus then
		log "[CapCut] Focused"
	else
		log "[CapCut] Could not confirm focus (continuing anyway)"
	end if

	set baseline to countCapCutWindows()
	openImportScreen()
	log "[CapCut] Import screen opened (Cmd+I)."
	log "[Click Tools] Waiting for you to click the 'Importar' button inside CapCut..."
	try
		display notification "Hacé clic en 'Importar' dentro de CapCut para continuar" with title "Click Tools" subtitle "Esperando tu clic..."
	end try

	set panelAppeared to waitForNativeOpenPanel(baseline)

	if not panelAppeared then
		log "[FAILED] Timed out waiting for the native file picker. Did you click Importar inside CapCut?"
		revealInFinder(filePath)
		return
	end if

	log "[CapCut] Native file picker detected."
	log "[IMPORT_ATTEMPTED strategy=accessibility-ui]"
	set navigated to navigateAndSelect(filePath)

	if navigated then
		log "[Click Tools] Navigated to the file and confirmed selection."
		log "[Click Tools] MANUAL CHECK REQUIRED: look at CapCut now — did the image land in Archivos multimedia?"
		log "[Click Tools] Report back: YES it appeared -> this whole flow is our FASE 2 import path."
		log "[Click Tools] Report back: NO / something else happened -> tell me exactly what you saw."
	else
		log "[FAILED] Could not navigate the native picker."
		revealInFinder(filePath)
	end if
end run
