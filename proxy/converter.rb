require 'json'
require 'crack'
require 'gyoku'

module Converter
  def convert_to_xml (hash, root = 'joke')
    Gyoku.xml(hash)
  end

  def convert_to_json (hash)
    hash.to_json
  end

  def convert_from_xml (object)
    Crack::XML.parse(object)
  end

  def convert_from_json (object)
    Crack::JSON.parse(object)
  end
end