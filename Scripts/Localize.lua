local fmt = string.format

local temp = {}
local tempFile = "Localize.temp"
local out = "Localize_output.lua"

local work = {}

local ptnstr = "L%[\"(.-)\"%]"
local fmtstr = "L[\"%s\"]"
local seperator = "----------------------------"

local ignores = {
	["Algalon the Observer"] = true,
}

-- Run through main files

local file = io.open(out, "w")

os.execute(fmt("ls ../ | grep 'lua' > %s",tempFile))
io.input(tempFile)
local files = {}
for line in io.lines() do
	files[#files+1] = line
end
os.execute(fmt("rm %s",tempFile))

local function addsep()
	file:write(seperator,"\n")
end

local function writeheader(str)
	addsep()
	file:write(fmt("--- %s",str),"\n")
	addsep()
end

local function writefilename(str)
	file:write("\n")
	local filename = string.match(str,"(.+)%.lua")
	file:write(fmt("-- %s",filename),"\n")
end

writeheader("MAIN")
for _,filename in ipairs(files) do
	local strings = {}
	io.input("../"..filename)
	local text = io.read("*all")
	for match in string.gmatch(text,ptnstr) do
		strings[#strings+1] = match
	end
	table.sort(strings)
	if (#strings > 0) then
		writefilename(filename)
	end
	for _,v in ipairs(strings) do
		if not ignores[v] then
			file:write(fmt(fmtstr.." = true",v),"\n")
		end
	end
end
file:write("\n")

file:close()
