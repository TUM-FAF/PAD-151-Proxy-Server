require 'nokogiri'

module XMLValidator

    def self.validate(xml)
        xsd = Nokogiri::XML::Schema(File.read("post_joke.xsd"))
        doc = Nokogiri::XML(xml)

        errors = []
        
        xsd.validate(doc).each do |error|
            errors.push(error.message)
        end

        return true if errors == []
        errors
    end
end

puts XMLValidator.validate(File.read('joke.xml'))