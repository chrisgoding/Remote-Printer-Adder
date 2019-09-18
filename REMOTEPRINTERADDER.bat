:readme
@echo off
cls
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo :: REMOTEPRINTERADDER.BAT
echo ::
echo :: version 1.3
echo :: made updating all the print servers automatic. Only one powershell file is needed now and 
echo :: it is created during first run.
echo :: 
echo :: version 1.2
echo ::	checks for dependencies, creates them if they're missing
echo ::	If printservers.txt is missing, it automatically updates the list of printservers
echo ::	added readme option to main menu!
echo ::
echo :: version 1.1
echo :: added back buttons to all menus
echo ::
echo :: chrisgoding@polk-county.net
echo :: 
echo :: requirements:
echo ::	Create a directory to place this batch file into
echo ::	Use the U option to update the list of print servers and printers.
echo ::
echo :: Requires RSAT Active directory features, because there is powershell that reads AD.
echo :: The Update option reads AD for servers that have a shared print queue.
echo :: Some desktops may appear in the list if they are sharing printers.
echo ::
echo :: Overview and usage:
echo ::	Guided script for globally adding printers from a print server to a remote PC. It 
echo ::	can also list globally added printers on a remote PC, as well as delete them. 
echo ::
echo ::	On first run, it will grab a list of all print servers from active directory.
echo :: This will also create lists of printers attached to each print server.
echo ::
echo ::	Once you have printer lists, you can start adding printers to PC's with the add
echo ::	feature. It asks for the name of the target PC. If your PC cannot ping the target 
echo ::	PC, it will let you know, then return you to the main menu. It then asks which 
echo ::	print server the desired printer is on, and displays a list of print servers.
echo ::	Finally, it displays the list of printers on that print server, and asks which you 
echo ::	would like to add to the target PC.
echo ::
echo ::	The list function lists the globally added printers on a remote PC.
echo ::
echo ::	The delete function removes globally added printers from a remote PC.
echo ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
timeout 1 >nul
@pause
pushd "%~dp0"
goto checkdependencies

:checkdependencies & :: creates powershell files by echoing text into them one line at a time. 
	if not exist UpdatePrinterList.ps1 IPCONFIG /ALL | find "Primary Dns Suffix" > dnssuffix.txt
	if not exist UpdatePrinterList.ps1 echo $b = Get-Content -Path dnssuffix.txt >> trimdnssuffix.ps1 && echo @(ForEach ($a in $b) {$a.Replace('   Primary Dns Suffix  . . . . . . . : ', '')}) ^> dnssuffix.txt >> trimdnssuffix.ps1 && echo $b = Get-Content -Path dnssuffix.txt >> trimdnssuffix.ps1 && echo @(ForEach ($a in $b) {$a.Replace('----------', '')}) ^> dnssuffix.txt >> trimdnssuffix.ps1 && echo (Get-Content dnssuffix.txt) ^| ? {$_.trim() -ne "" } ^| set-content dnssuffix.txt >> trimdnssuffix.ps1
	if not exist UpdatePrinterList.ps1 PowerShell.exe -ExecutionPolicy Bypass -File trimdnssuffix.ps1
	if not exist UpdatePrinterList.ps1 for /F "delims=" %%i in ('type dnssuffix.txt') do set DNSsuffix=%%i
	if not exist UpdatePrinterList.ps1 echo # https://social.technet.microsoft.com/Forums/windowsserver/en-US/f0ca6504-2643-4010-b53c-96696d7a401c/how-to-list-all-print-servers-in-a-domain?forum=winserverprint >> UpdatePrinterList.ps1 && echo Import-Module ActiveDirectory >> UpdatePrinterList.ps1 && echo Get-ADObject -LDAPFilter "(&(&(&(uncName=*)(objectCategory=printQueue))))" -properties *^|Sort-Object -Unique -Property servername ^|select servername ^| out-file printservers.txt >> UpdatePrinterList.ps1 && echo # trim spaces, domain, in resulting text file >> UpdatePrinterList.ps1 && echo # https://stackoverflow.com/a/36934720 >> UpdatePrinterList.ps1 && echo $b = Get-Content -Path printservers.txt >> UpdatePrinterList.ps1 && echo @(ForEach ($a in $b) {$a.Replace(' ', '')}) ^> printservers.txt >> UpdatePrinterList.ps1 && echo $b = Get-Content -Path printservers.txt >> UpdatePrinterList.ps1 && echo @(ForEach ($a in $b) {$a.Replace('.%DNSsuffix%', '')}) ^> printservers.txt >> UpdatePrinterList.ps1 && echo $b = Get-Content -Path printservers.txt >> UpdatePrinterList.ps1 && echo @(ForEach ($a in $b) {$a.Replace('servername', '')}) ^> printservers.txt >> UpdatePrinterList.ps1 && echo $b = Get-Content -Path printservers.txt >> UpdatePrinterList.ps1 && echo @(ForEach ($a in $b) {$a.Replace('----------', '')}) ^> printservers.txt >> UpdatePrinterList.ps1 && echo # remove blank lines from file >> UpdatePrinterList.ps1 && echo # https://stackoverflow.com/a/11002660 >> UpdatePrinterList.ps1 && echo (Get-Content printservers.txt) ^| ? {$_.trim() -ne "" } ^| set-content printservers.txt >> UpdatePrinterList.ps1 && echo # generate printer lists >> UpdatePrinterList.ps1 && echo foreach ($printserver in Get-Content printservers.txt) >> UpdatePrinterList.ps1 && echo {$pingresult = Test-Connection -ComputerName $printserver -Count 1 -ErrorAction SilentlyContinue >> UpdatePrinterList.ps1 && echo     if ( $pingresult -ne $NULL ) >> UpdatePrinterList.ps1 && echo    {Get-Printer -computername $printserver ^| Sort-Object ^| Format-table -Property Name ^| out-file "$printserver.txt"} >> UpdatePrinterList.ps1 && echo    } >> UpdatePrinterList.ps1
	del dnssuffix.txt /f /q && del trimdnssuffix.ps1 /f /q
	if not exist printservers.txt goto updateprinters

:mainmenu
	cls
	echo What would you like to do?
	echo Type A to add a printer
	echo Type L to list printers on a PC
	echo Type D to delete a printer
	echo Type U to update the list of print servers and printers on the print servers
	echo Type R to display the readme
	echo Type X to cancel the script when you're done
	setlocal
	set /p Action=
		if %Action%==a goto addprinter
		if %Action%==A goto addprinter
		if %Action%==l goto listprinter
		if %Action%==L goto listprinter
		if %Action%==d goto deleteprinter
		if %Action%==D goto deleteprinter
		if %Action%==R goto readme
		if %Action%==r goto readme
		if %Action%==u goto updateprinters
		if %Action%==U goto updateprinters
		if %Action%==x goto eof
		if %Action%==X goto eof
	echo Input not recognized. Press any key to start over.
	timeout 1 >nul
	@pause
	endlocal
	goto mainmenu

:addprinter
	setlocal
	cls
	echo Type the name of the computer you'd like to add a printer to, then press enter. Or, type X to go back.
	set /p PCName=
	if %PCName% == x goto mainmenu
	if %PCName% == X goto mainmenu
		ping %PCName% -n 1 | findstr "Reply"
			if %errorlevel%==1 goto unreachablepc
	cls
	:chooseprintserver
		type printservers.txt
		echo.
		echo.
		echo Type the name of the print server that the desired printer is on, then press enter. Or, type X to go back to the previous menu.
		set /p Printserver=
		if %Printserver% == x goto addprinter
		if %Printserver% == X goto addprinter
		ping %Printserver% -n 1 | findstr "Reply"
		if %errorlevel%==1 goto badprintserver
		cls
		type %Printserver%.txt
		if %errorlevel%==1 cls && echo Could not find %Printserver%.txt. You will now be redirected to the update section so that you can generate a list of printers on %Printserver%. && timeout 1 >nul && pause && goto updateprinters
		echo.
		echo.
		echo Type the name of the printer that you want to add, then press enter, or type x to go back to the previous menu.
		echo Even if the printer doesn't exist, it will add it. Be careful.
		set /p Printer=
		if %Printer% == x goto chooseprintserver
		if %Printer% == X goto chooseprintserver
		rundll32 printui.dll,PrintUIEntry /ga /c\\%PCName% /n"\\%Printserver%\%Printer%"
		Echo Done. Press any key to start over.
		timeout 1 >nul
		@pause
		endlocal
		goto mainmenu

		:badprintserver
			Echo.
			echo Print server unreachable. Press any key to start over.
			endlocal
			timeout 1 >nul
			@pause
			goto addprinter

:listprinter
	setlocal
	cls
	echo Type the name of the computer you'd like to list the printers on, then press enter, or type x to go back to the previous menu.
	set /p PCName=
	if %PCName% == x goto mainmenu
	if %PCName% == X goto mainmenu
		ping %PCName% -n 1 | findstr "Reply"
		if %errorlevel%==1 goto unreachablepc
	cls
	rundll32 printui.dll,PrintUIEntry /ge /c\\%PCName%
	Echo Done. Press any key to start over.
	timeout 1 >nul
	@pause
	endlocal
	goto mainmenu

:deleteprinter
	cls
	setlocal
	echo Type the name of the computer you'd like to delete a printer from, then press enter, or type x to go back to the previous menu.
	set /p PCName=
	if %PCName% == x goto mainmenu
	if %PCName% == X goto mainmenu
		ping %PCName% -n 1 | findstr "Reply"
			if %errorlevel%==1 goto unreachablepc
	:chooseprinterver2
		cls
		type printservers.txt
		echo Type the name of the print server that the printer you want to remove is on, then press enter. Or, type X to go back to the previous menu.
		set /p Printserver=
		if %Printserver% == x goto deleteprinter
		if %Printserver% == X goto deleteprinter
		ping %Printserver% -n 1 | findstr "Reply"
		if %errorlevel%==1 goto badprintserver2
		cls
		type %Printserver%.txt
		if %errorlevel%==1 cls && echo Could not find %Printserver%.txt. You will now be redirected to the update section so that you can generate a list of printers on %Printserver%. && timeout 1 >nul && pause && goto updateprinters
		echo.
		echo.
		echo Type the name of the printer that you want to add, then press enter, or type x to go back to the previous menu.
		echo Even if the printer doesn't exist, it will add it. Be careful.
		set /p Printer=
		if %Printer% == x goto chooseprintserver2
		if %Printer% == X goto chooseprintserver2
		rundll32 printui.dll,PrintUIEntry /gd /c\\%PCName% /n"\\%Printserver%\%Printer%"
		Echo Done. Press any key to start over.
		timeout 1 >nul
		@pause
		endlocal
		goto mainmenu

	:badprintserver2
		Echo.
		echo Print server unreachable. Press any key to start over.
		endlocal
		timeout 1 >nul
		@pause
		goto deleteprinter

:updateprinters
	cls
	echo.
	echo Creating list of print servers.
	echo For each print server that responds to pings, a text file is created with a list of printers in it.
	echo Depending on your environment, this can take a while.
	PowerShell.exe -ExecutionPolicy Bypass -File UpdatePrinterList.ps1
	echo.
	echo All done!
	timeout 3 >nul
	goto mainmenu

:unreachablepc
	echo Couldn't find that PC. Press any key to start over.
	timeout 1 >nul
	@pause
	goto mainmenu


:eof
	endlocal
	exit