
require 'erb'
require 'rexml/document'
require './property'

module ConfigConvert

	class Convert

		def executeOnFile(xmlfilepath, jcrfilepath)
			
			$properties = Array.new
			$origfile, $jcrfile, $templatefile = nil, nil, nil

			if File.exists?(xmlfilepath)
				begin 
					#file that holds original config
					$origfile = File.open(xmlfilepath)
					#file to hold jcr config
					$jcrfile = File.new(jcrfilepath, "w+")
					#ingest template
					$templateFile = File.open("jcrerb.erb")
					#Create document
					$xmldocument = REXML::Document.new $origfile
					#for each property node add each element node to a new Property object
					$xmldocument.elements.each("node/property") { |property|
						$properties.push(Property.new(property.elements['name'].get_text.value, property.elements['value'].get_text.value, property.elements['type'].get_text.value))
					}
					$templateText = $templateFile.read
					#render
					$renderer = ERB.new($templateText, nil, ">")

					$jcrfile.write($renderer.result.to_s)
					ensure
						$jcrfile.close
						$origfile.close
						$templateFile.close
				end
			else
				puts "Invalid/missing file(s)"
			end
		end

		def execute(folderinpath, folderoutpath)
			if Dir.exists?(folderinpath) && Dir.exists?(folderoutpath)
				begin
					$infolder = Dir.open(folderinpath)
					$outfolder = Dir.open(folderoutpath)
					$folderinpath = $infolder.to_path
					$folderoutpath = $outfolder.to_path
					Dir.foreach($folderinpath) { |item|
						if(File.extname("#{$folderinpath}/#{item}") == ".xml")
							puts "\e[32mExecuting convert of \e[44m#{item}\e[0m"
							executeOnFile("#{$folderinpath}/#{item}", "#{$folderoutpath}/#{item}")
						else
							puts "\e[31mSkipping #{item} as it is not an xml file\e[0m"
						end
					}
					ensure
						$infolder.close
						$outfolder.close
				end
			else
				puts "\e[31mInvalid input or output directory.  Usage is convert *inputconfigdirectory* *outputconfigdirectory*\e[0m"
			end	

		end

	end

end

ConfigConvert::Convert.new.execute(ARGV[0], ARGV[1])