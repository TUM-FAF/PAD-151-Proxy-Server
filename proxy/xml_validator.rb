require 'nokogiri'

module XMLValidator

    def self.validate(xml)
        xsd = Nokogiri::XML::Schema(File.read("post_joke.xsd"))
        doc = Nokogiri::XML(xml)

        xsd.validate(doc).each do |error|
            puts error.message
        end
    end
end

XMLValidator.validate(File.read('joke.xml'))