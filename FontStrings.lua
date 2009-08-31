local addon,SM = DXE,DXE.SM

local gbl
local function RefreshProfile(db) gbl = db.global end
addon:AddToRefreshProfile(RefreshProfile)

local registry = {}
function addon:RegisterFontString(fontstring,size,flag1,flag2,flag3)
	--@debug@
	assert(fontstring.IsObjectType and fontstring:IsObjectType("FontString"))
	assert(type(size) == "number")
	--@end-debug@
	registry[fontstring] = true
	fontstring:SetFont(SM:Fetch("font",gbl.Font),size,flag1,flag2,flag3)
end

function addon:NotifyFontChanged()
	for fontstring in pairs(registry) do 
		local _,size,flag1,flag2,flag3 = fontstring:GetFont()
		fontstring:SetFont(SM:Fetch("font",gbl.Font),size,flag1,flag2,flag3)
	end
end
