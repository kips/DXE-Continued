#!/usr/bin/ruby

# place in <project>/scripts

require 'uri'
require 'net/http'
require File.join(File.dirname(__FILE__),'..','..','api_key') # for API_KEY

raise "Missing API_KEY" unless API_KEY
puts "API_KEY: #{API_KEY}"

def validate_response(response)
	body = response.class == String ? response : response.body
	raise "API_KEY is invalid" if body =~ /www\.wowace\.com\/home\/login/
	true
end

slug = "deus-vox-encounters"
locale_uri = URI.parse "http://www.wowace.com/addons/#{slug}/localization/import/"
locale_uri_api_key = URI.parse "#{locale_uri.to_s}/?api-key=#{API_KEY}"
locale_regex = /L(?:\.(\w+?))?\["(.+?)"\]/

# map namespace names to namespace values
namespace_values = Hash.new
select_regex = /<select.*?namespace.*>.*?<\/select>/
option_regex = /<option.*?value="(\d+)">(\w+)<\/option>/

begin
	response = Net::HTTP.get(locale_uri_api_key)
	validate_response(response)
	response.match(select_regex)[0].scan(option_regex) { |value, name| namespace_values[name] = value }
rescue StandardError => e
	puts "error: unable to grab namespace values - #{e.message}"
	exit
end

blacklist = {
	"Template.lua"          => true,
	"Debug.lua"             => true,
	"LibDataBroker-1.1.lua" => true,
	"Tests.lua"             => true,
	"Locales.lua"           => true,
}

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
	puts "   #{filename.match(/#{File.join('scripts','..','(.+)')}/i)[1].ljust(60)} #{"DONE".rjust(10)}"
end

locales.each_pair do |namespace, phrases|
	if namespace_values[namespace]
		uniq_phrases = phrases.uniq
		content = uniq_phrases.collect { |p| "L[\"#{p}\"] = true" }.join("\n")
		begin
			response = Net::HTTP.post_form(locale_uri,{
				"api-key"           => API_KEY,
				"delete_unimported" => "y",
				"format"            => "lua_additive_table",
				"language" 			  => "1",
				"text"              => content,
				"namespace"         => namespace_values[namespace],
			})
			puts "successfully sent #{uniq_phrases.size.to_s.ljust(4)} phrases for namespace '#{namespace}'" if validate_response(response)
		rescue StandardError => e
			puts "error: unable to send phrases for namespace '#{namespace}' - #{e.message}"
		end
	else
		puts "error: namespace '#{namespace}' doesn't exist on the localization app"
	end
end
