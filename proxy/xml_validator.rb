require 'nokogiri'

module XMLValidator

  def self.validate(xml, xsd_schema)
    xsd = Nokogiri::XML::Schema(xsd_schema)
    doc = Nokogiri::XML(xml)

    errors = []
    
    xsd.validate(doc).each do |error|
      errors.push(error.message)
    end

    return [errors.empty?, errors]
  end
end
