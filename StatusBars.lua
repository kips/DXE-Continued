local addon,SM = DXE,DXE.SM

local gbl
local function RefreshProfile(db) gbl = db.global end
addon:AddToRefreshProfile(RefreshProfile)

local registry = {}
function addon:RegisterStatusBar(statusbar)
	--@debug@
	assert(statusbar.IsObjectType and statusbar:IsObjectType("StatusBar"))
	--@end-debug@
	registry[statusbar] = true
	statusbar:SetStatusBarTexture(SM:Fetch("statusbar",gbl.BarTexture))
end

function addon:NotifyBarTextureChanged()
	local texture = SM:Fetch("statusbar",gbl.BarTexture)
	for statusbar in pairs(registry) do statusbar:SetStatusBarTexture(texture) end
end
