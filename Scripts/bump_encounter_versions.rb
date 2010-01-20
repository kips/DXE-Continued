Dir.chdir(File.join(File.dirname(__FILE__),'..'))
Dir[File.join('Encounters','**','*.lua')].each do |filename|
	unless filename.match(/([^#{File::SEPARATOR}]+$)/)[1] == "Locales.lua"
		File.open(filename,"r+") do |file|
			begin
				while line = file.readline
					if m = line.match(/version = (\d+)/)
						file.seek -line.length, IO::SEEK_CUR
						file.write line.gsub /\d+/, "#{m[1].to_i + 1}"
						puts "#{filename}: bumped encounter version to #{m[1]}"
						next
					end
				end
			rescue EOFError
				next
			end
		end
	end
end
