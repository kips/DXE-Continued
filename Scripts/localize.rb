#!/usr/bin/ruby

# place in <project>/scripts
 
require 'uri'
require 'net/http'
require File.join(File.dirname(__FILE__),'..','..','api_key') # for API_KEY

SLUG = "deus-vox-encounters"
LANGUAGE_TYPE = 1
FORMAT_TYPE = "lua_additive_table"
LOCALE_URI = "http://www.wowace.com/addons/#{SLUG}/localization/import/"
LOCALE_REGEX = /L\["(.+?)"\]/

dirs_to_namespace = {
	['.','Alerts','Windows'] => '293',
	['Loader']               => '396',
	['Options']              => '395',
}

dirs_to_namespace.each_pair do |dirs, namespace_value|
	phrases = []
	dirs.each { |dir|
		Dir[File.join(File.dirname(__FILE__),'..',dir,'*.lua')].each do |filename|
			File.open(filename,'r') { |file| phrases << file.read.scan(LOCALE_REGEX) }
		end
	}
	content = phrases.flatten.uniq.sort.collect {|p| %(L["#{p}"] = true) }.join("\n")

	params = {
		"api-key"           => API_KEY,
		"delete_unimported" => "y",
		"format"            => "lua_additive_table",
		"language" 			  => "1",
		"text"              => content,
		"namespace"         => namespace_value,
	}

	Net::HTTP.post_form(URI.parse(LOCALE_URI), params)
end

=begin
Dir['**/Locales.lua'].each do |filename|
	if filename != "Locales.lua"
		lines = []
		File.open(filename,"r") do |file|
			file.each_line do |line|
				if line =~ /--@localization/
					namespace = line.match(/namespace="(\w+)"/)[1]
					proper_name = namespace.gsub(/_/," ").gsub(/\w+/) { |word| word.capitalize }.gsub(/Npc/,"NPC")
					locale = line.match(/locale="([A-Za-z]+)"/)[1]
					new_line = "local #{namespace} = AL:NewLocale(\"DXE #{proper_name}\", \"#{locale}\")\n"
					get_line = "AL:GetLocale(\"DXE\").#{namespace} = AL:GetLocale(\"DXE #{proper_name}\")\n"
					lines << new_line
					lines << line
					lines << get_line
				else
					lines << line
				end
			end
		end
		File.open(filename,"w") do |file|
			file.puts lines.join
		end
	end
end
=end
