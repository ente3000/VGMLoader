; Prompt for VGM album URL
InputBox, VGMSITE, VGMLoader v1.1, Please enter an album URL., , 500, 125, , , , , https://downloads.khinsider.com/game-soundtracks/album/

; If not cancelled
If !ErrorLevel {

	; If URL is valid
	If RegExMatch(VGMSITE, "https?:\/\/(www\.)?downloads\.khinsider\.com\/game-soundtracks\/album\/[^/]+", VGMSITE) {
		Progress, 0, Preparing..., Please wait..., VGMLoader v1.1

		; Get site from URL
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
			MsgBox, 3, VGMLoader v1.1, Create a new subfolder with the album's title (%VGMALBUM%)?

			; Create album subfolder on demand
			IfMsgBox, Yes
				FileCreateDir, %VGMALBUM%
				SetWorkingDir, %VGMALBUM%

			; Exit on demand
			IfMsgBox, Cancel
				Exit

			; Get number of files
			Progress, 0, Preparing..., Please wait..., VGMLoader v1.1
			RegExMatch(VGMSITE, "Number of Files: <b>.+<\/b><br>", VGMAMOUNT)
			StringTrimLeft, VGMAMOUNT, VGMAMOUNT, 20
			StringTrimRight, VGMAMOUNT, VGMAMOUNT, 8

			; Get track URLs
			VGMLOOP = 1
			VGMCURRENT = 0
			While VGMLOOP := RegExMatch(VGMSITE,"<td><a href="".+"">Download<\/a><\/td>", VGMTRACK, VGMLOOP + StrLen(VGMTRACK)) {

				; Download track site
				VGMCURRENT += 1
				VGMPROGRESS := (VGMCURRENT - 1) / VGMAMOUNT * 100
				Progress, %VGMPROGRESS%, Downloading track %VGMCURRENT% of %VGMAMOUNT%..., Downloading %VGMALBUM%...
				StringTrimLeft, VGMTRACK, VGMTRACK, 13
				StringTrimRight, VGMTRACK, VGMTRACK, 19
				UrlDownloadToFile, %VGMTRACK%, VGMLoader.html
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
				UrlDownloadToFile, %VGMTRACK%, %VGMFILE%
			}

			; Finished message popup
			Progress, OFF
			MsgBox, , VGMLoader v1.1, Success: %VGMALBUM% has been downloaded.
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
