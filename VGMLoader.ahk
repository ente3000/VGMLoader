; Prompt for VGM album URL
InputBox, VGMSITE, VGMLoader v1.2, Please enter an album URL., , 500, 125, , , , , https://downloads.khinsider.com/game-soundtracks/album/

; If not cancelled
If !ErrorLevel {

	; If URL is valid
	If RegExMatch(VGMSITE, "downloads\.khinsider\.com\/game-soundtracks\/album\/[^/]+", VGMSITE) {
		Progress, 0, Preparing..., Please wait..., VGMLoader v1.2

		; Get site from URL
		VGMSITE = https://%VGMSITE%
		UrlDownloadToFile, %VGMSITE%, VGMLoader.html
		FileRead, VGMSITE, VGMLoader.html
		FileDelete, VGMLoader.html

		; Get album title
		RegExMatch(VGMSITE, "<h2>.+</h2>", VGMALBUM)
		StringTrimLeft, VGMALBUM, VGMALBUM, 4
		StringTrimRight, VGMALBUM, VGMALBUM, 5

		; If album not found
		IfEqual, VGMALBUM, Ooops!
		Goto, VGMINVALID

		; Prompt for output directory
		Progress, OFF
		FileSelectFolder, VGMDIR, *%A_WorkingDir%, , Please select the destination folder.

		; If not cancelled
		If !Errorlevel {

			; Switch to output directory
			SetWorkingDir, %VGMDIR%

			; Prompt for album subfolder
			MsgBox, 3, VGMLoader v1.2, Create a new subfolder with the album's title (%VGMALBUM%)?

			; Create album subfolder on demand
			IfMsgBox, Yes
				FileCreateDir, %VGMALBUM%
				SetWorkingDir, %VGMALBUM%

			; Exit on demand
			IfMsgBox, Cancel
				Exit

			; Prompt for download method
			Progress, 0, Preparing..., Please wait..., VGMLoader v1.2
			Gui, Add, Text, , VGMLoader found the following supported tools.`rPlease choose your preferred download program.
			VGM1PATH := RegExReplace(ComObjCreate("WScript.Shell").Exec("cmd.exe /c where aria2c.exe").StdOut.ReadAll(), "\n.*")
			VGM3PATH := RegExReplace(ComObjCreate("WScript.Shell").Exec("cmd.exe /c where curl.exe").StdOut.ReadAll(), "\n.*")
			VGM4PATH := RegExReplace(ComObjCreate("WScript.Shell").Exec("cmd.exe /c where http.exe").StdOut.ReadAll(), "\n.*")
			VGM5PATH := RegExReplace(ComObjCreate("WScript.Shell").Exec("cmd.exe /c where powershell.exe").StdOut.ReadAll(), "\n.*")
			VGM6PATH := RegExReplace(ComObjCreate("WScript.Shell").Exec("cmd.exe /c where wget.exe").StdOut.ReadAll(), "\n.*")
			If (VGM1PATH)
				Gui, Add, Radio, vVGM1CHOICE gVGMDLOAD, aria2
			Gui, Add, Radio, vVGM2CHOICE gVGMDLOAD, AutoHotkey
			If (VGM3PATH)
				Gui, Add, Radio, vVGM3CHOICE gVGMDLOAD, cURL
			If (VGM4PATH)
				Gui, Add, Radio, vVGM4CHOICE gVGMDLOAD, HTTPie
			If (VGM5PATH)
				Gui, Add, Radio, vVGM5CHOICE gVGMDLOAD, PowerShell
			If (VGM6PATH)
				Gui, Add, Radio, vVGM6CHOICE gVGMDLOAD, Wget
			Progress, OFF
			Gui, Show, , VGMLoader v1.2
			Return
			VGMDLOAD:
				Gui, Submit

			; Get number of files
			Progress, 0, Preparing..., Please wait..., VGMLoader v1.2
			RegExMatch(VGMSITE, "Number of Files: <b>.+<\/b><br>", VGMAMOUNT)
			StringTrimLeft, VGMAMOUNT, VGMAMOUNT, 20
			StringTrimRight, VGMAMOUNT, VGMAMOUNT, 8

			; Get track URLs
			VGMLOOP = 1
			VGMCURRENT = 0
			While VGMLOOP := RegExMatch(VGMSITE,"<td class=""clickable-row""><a href="".+"">", VGMTRACK, VGMLOOP + StrLen(VGMTRACK)) {

				; Download track site
				VGMCURRENT += 1
				VGMPROGRESS := (VGMCURRENT - 1) / VGMAMOUNT * 100
				Progress, %VGMPROGRESS%, Downloading track %VGMCURRENT% of %VGMAMOUNT%..., Downloading %VGMALBUM%...
				StringTrimLeft, VGMTRACK, VGMTRACK, 35
				StringTrimRight, VGMTRACK, VGMTRACK, 2
				VGMTRACK = https://downloads.khinsider.com%VGMTRACK%
				If VGM1CHOICE
					RunWait, aria2c %VGMTRACK% -o VGMLoader.html, , Hide
				If VGM2CHOICE
					UrlDownloadToFile, %VGMTRACK%, VGMLoader.html
				If VGM3CHOICE
					RunWait, curl -k %VGMTRACK% -o VGMLoader.html, , Hide
				If VGM4CHOICE
					RunWait, http %VGMTRACK% > VGMLoader.html, , Hide
				If VGM5CHOICE
					RunWait, powershell iwr %VGMTRACK% -outf VGMLoader.html, , Hide
				If VGM6CHOICE
					RunWait, wget %VGMTRACK% -O VGMLoader.html, , Hide
				FileRead, VGMTRACK, VGMLoader.html
				FileDelete, VGMLoader.html

				; Download track itself
				RegExMatch(VGMTRACK, "<a style=""color: #21363f;"" href="".+"">Click here to download as MP3<\/a>", VGMTRACK)
				StringTrimLeft, VGMTRACK, VGMTRACK, 33
				StringTrimRight, VGMTRACK, VGMTRACK, 35
				SplitPath, VGMTRACK, VGMFILE

				; Decode URL characters
				Loop
					If RegExMatch(VGMFILE, "i)(?<=%)[\da-f]{1,2}", VGMHEX)
						StringReplace, VGMFILE, VGMFILE, `%%VGMHEX%, % Chr("0x" . VGMHEX), All
					Else
						Break
				If VGM1CHOICE
					RunWait, aria2c %VGMTRACK% -o "%VGMFILE%", , Hide
				If VGM2CHOICE
					UrlDownloadToFile, %VGMTRACK%, "%VGMFILE%"
				If VGM3CHOICE
					RunWait, curl -k %VGMTRACK% -o "%VGMFILE%", , Hide
				If VGM4CHOICE
					RunWait, http %VGMTRACK% > "%VGMFILE%", , Hide
				If VGM5CHOICE
					RunWait, powershell iwr %VGMTRACK% -outf '%VGMFILE%', , Hide
				If VGM6CHOICE
					RunWait, wget %VGMTRACK% -O "%VGMFILE%", , Hide
			}

			; Finished message popup
			Progress, OFF
			MsgBox, , VGMLoader v1.2, Success: %VGMALBUM% has been downloaded.
		}
	} Else {

		; If URL is invalid
		Goto, VGMINVALID
	}
}
Exit

; If URL invalid or album not found
VGMINVALID:
Progress, OFF
MsgBox, , VGMLoader, Error: Entered URL does not appear to be a valid VGM album URL.
Exit
