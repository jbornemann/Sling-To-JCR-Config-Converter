
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
						$propertyobj = processConfigProperty(property)
						$properties.push($propertyobj)
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
				puts "\e[31mInvalid/missing file(s)\e[0m"
			end
		end

		def processConfigProperty(property)
			#Get name and type values.  Can be empty
			$namevalue = property.elements['name'].has_text? ? property.elements['name'].get_text.value : ""
			$typevalue = property.elements['type'].has_text? ? property.elements['type'].get_text.value : ""
			#build initial Property object
			$propertyobj = Property.new($namevalue, $typevalue)
			#some properties have multiple values
			$valueelement = property.elements['value']
			$valueselement = property.elements['values']

			if(!$valueelement.nil?)
				$valuetext = $valueelement.has_text? ? $valueelement.get_text.value : ""
				$propertyobj.value = $valuetext
			elsif(!$valueselement.nil?)
				$propertyobj.values = Array.new
				$valueselement.elements.each("value") { |value| 
					$valuetext = value.has_text? ? value.get_text.value : ""
					$propertyobj.values.push($valuetext)
				}
			else
				puts "\e[31mSkipping #{property.get_text.value} because it has not value or values\e[0m" 
			end
			return $propertyobj
		end

		def execute(folderinpath, folderoutpath)
			if !folderinpath.nil? && !folderoutpath.nil? &&Dir.exists?(folderinpath) && Dir.exists?(folderoutpath)
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