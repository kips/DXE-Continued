If you're using this addon out of the repo you need to make links with whatever
link system your OS provides (ln -s, mlink, ...) from the repo to your WoW install.

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

