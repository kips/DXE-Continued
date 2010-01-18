#!/usr/bin/ruby

# place in <project>/scripts
 
require 'uri'
require 'net/http'
require File.join(File.dirname(__FILE__),'..','..','api_key') # for API_KEY

raise "Missing API_KEY" unless API_KEY
puts "API_KEY: #{API_KEY}"

slug = "deus-vox-encounters"
locale_uri = "http://www.wowace.com/addons/#{slug}/localization/import/"
locale_uri_api_key = "#{locale_uri}/?api-key=#{API_KEY}"
locale_regex = /L(?:\.(\w+?))?\["(.+?)"\]/

# map namespace names to namespace values
namespace_values = Hash.new
select_regex = /<select.*?namespace.*>.*?<\/select>/
option_regex = /<option.*?value="(\d+)">(\w+)<\/option>/
Net::HTTP.get(URI.parse(locale_uri_api_key)).match(select_regex)[0].scan(option_regex) { |value, name| namespace_values[name] = value }

blacklist = {
	"Template.lua"          => true,
	"Debug.lua"             => true,
	"LibDataBroker-1.1.lua" => true,
	"Tests.lua"             => true,
}

spacing = "   "
locales = Hash.new
# find all phrases and namespace contexts
puts "Scanning for localization phrases"
Dir[File.join(File.dirname(__FILE__),'..','**','*.lua')].each do |filename|
	next if blacklist[filename.match(/([^#{File::SEPARATOR}]+)$/)[1]]
	File.open(filename) do |file|
		file.read.scan(locale_regex) do |namespace, phrase|
			locales[namespace || 'main'] ||= []
			locales[namespace || 'main'] << phrase
		end	
	end
	puts "#{spacing}#{filename.match(/scripts#{File::SEPARATOR}\.\.#{File::SEPARATOR}(.+)/)[1].ljust(60)} #{"DONE".rjust(10)}"
end

locales.each_pair do |namespace, phrases|
	if namespace_values[namespace]
		content = phrases.uniq.collect { |p| "L[\"#{p}\"] = true" }.join("\n")
		puts "sending phrases for namespace '#{namespace}'"
		Net::HTTP.post_form(URI.parse(locale_uri),{
			"api-key"           => API_KEY,
			"delete_unimported" => "y",
			"format"            => "lua_additive_table",
			"language" 			  => "1",
			"text"              => content,
			"namespace"         => namespace_values[namespace],
		})
	else
		puts "error: namespace '#{namespace}' doesn't exist on the localization app"
	end
end
