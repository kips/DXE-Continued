Dir.chdir(File.join(File.dirname(__FILE__),'..','Encounters'))

class Combiner
	@@sep = File::SEPARATOR

	def process_enc_files(dir,enc_files)
		contents = []
		contents << "local L,SN,ST = DXE.L,DXE.SN,DXE.ST"
		contents << ""
		enc_files.each do |filename|
			contents << "---------------------------------"
			contents << "-- #{filename.match(/^([^\.]+)/)[1].gsub("_"," ").upcase}"
			contents << "---------------------------------"
			contents << ""
			enc_content = File.open(File.join(dir,filename),"r").read
			enc_content.gsub!(/.*?local L,SN,ST = DXE\.L,DXE\.SN,DXE\.ST.*?\n/,"")
			contents << enc_content
		end

		File.open(File.join(dir,"Encounters.lua"),"w") do |file|
			file.puts contents.join("\n")
		end
	end

	def process_toc(toc_filename)
		dir = toc_filename.match(/([^#{@@sep}]+)#{@@sep}[^#{@@sep}]+/)[1]
		File.open(toc_filename,"r+") do |file|
			enc_files = []
			lines = []
			file.each_line do |line|
				if line =~ /^(?!Locales|Encounters)[-\w']+\.lua/
					enc_files << line.chomp
				end
			end

			process_enc_files(dir,enc_files)
		end
	end

	def run
		Dir['*/**/*.toc'].each do |toc_filename|
			process_toc(toc_filename)
		end
	end
end

#Combiner.new.run
