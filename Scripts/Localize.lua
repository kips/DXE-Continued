local fmt = string.format

local temp = {}
local tempFile = "Localize.temp"
local out = "Localize_output.lua"

local work = {}

local ptnstr = "L%[\"(.-)\"%]"
local fmtstr = "L[\"%s\"]"

local file = io.open(out, "w")
local files = {}

local directories = {"","Modules"}

for _,directory in pairs(directories) do
	os.execute(fmt("ls ../"..directory.." | grep 'lua' > %s",tempFile))
	io.input(tempFile)
	for line in io.lines() do
		files[#files+1] = directory..(directory ~= "" and "/" or "")..line
	end
	os.execute(fmt("rm %s",tempFile))
	io.close()
end

local function writefilename(str)
	file:write("\n")
	local filename = string.match(str,"(.+)%.lua")
	file:write(fmt("-- %s",filename),"\n")
end

for _,filename in ipairs(files) do
	local strings = {}
	io.input("../"..filename)
	local text = io.read("*all")
	for match in string.gmatch(text,ptnstr) do
		strings[match] = true
	end
	local work = {}
	for str in pairs(strings) do
		work[#work+1] = str
	end
	table.sort(work)
	if (#work > 0) then
		writefilename(filename)
		for _,v in ipairs(work) do
			file:write(fmt(fmtstr.." = true",v),"\n")
		end
	end
end

file:close()
