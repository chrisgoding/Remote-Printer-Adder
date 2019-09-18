# Remote-Printer-Adder

version 1.3
made updating all the print servers automatic. Only one powershell file is needed now and it is created during first run.

version 1.2
checks for dependencies, creates them if they're missing
If printservers.txt is missing, it automatically updates the list of printservers
added readme option to main menu!

version 1.1
added back buttons to all menus

chrisgoding@polk-county.net

requirements:
Create a directory to place this batch file into
Use the U option to update the list of print servers and printers.

Requires RSAT Active directory features, because there is powershell that reads AD.
The Update option reads AD for servers that have a shared print queue.
Some desktops may appear in the list if they are sharing printers.

Overview and usage:
Guided script for globally adding printers from a print server to a remote PC. It can also list globally added printers on a remote PC, as well as delete them. 

On first run, it will grab a list of all print servers from active directory.
This will also create lists of printers attached to each print server.

Once you have printer lists, you can start adding printers to PC's with the add feature. It asks for the name of the target PC. If your PC cannot ping the target PC, it will let you know, then return you to the main menu. It then asks which print server the desired printer is on, and displays a list of print servers.
Finally, it displays the list of printers on that print server, and asks which you would like to add to the target PC.

The list function lists the globally added printers on a remote PC.

The delete function removes globally added printers from a remote PC.
