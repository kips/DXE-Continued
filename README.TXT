If you're using this addon out of the repo you need to make links with whatever
link system your OS provides (ln -s, mklink, ...) from the repo to your WoW install.

The links you need to make will be as follows assuming that the repo is in the
AddOns folder:

DXE_Citadel -> ../DXE/Encounters/Citadel/
DXE_Coliseum -> ../DXE/Encounters/Coliseum/
DXE_Kalimdor -> ../DXE/Encounters/Kalimdor/
DXE_Loader -> ../DXE/Loader/
DXE_Naxxramas -> ../DXE/Encounters/Naxxramas/
DXE_Northrend -> ../DXE/Encounters/Northrend/
DXE_Options -> ../DXE/Options/
DXE_Ulduar -> ../DXE/Encounters/Ulduar/

Alternatively, you can uncomment the lines commented out in Encounters.xml and the
Options\Options.lua line in the DXE.toc file.  However, making the links will allow
you to use the addon in a load on demand fashion.

Windows instructions:
1. Clone git repository to Interface\AddOns\DXE
2. Open Windows command line and change directory to Interface\AddOns\DXE
3. Type the following commands to create the necessary links

	mklink /D ..\DXE_Loader DXE\Loader
	mklink /D ..\DXE_Options DXE\Options
	mklink /D ..\DXE_Citadel DXE\Encounters\Citadel
	mklink /D ..\DXE_Coliseum DXE\Encounters\Coliseum
	mklink /D ..\DXE_Kalimdor DXE\Encounters\Kalimdor
	mklink /D ..\DXE_Naxxramas DXE\Encounters\Naxxramas
	mklink /D ..\DXE_Northrend DXE\Encounters\Northrend
	mklink /D ..\DXE_Ulduar DXE\Encounters\Ulduar
