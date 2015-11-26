require 'addressable/uri'

class WebApi < ActiveRecord::Base
  def self.request(site:, path:, params:)
    uri = Addressable::URI.parse(URI.escape("#{site}#{path}"))
    uri.query_values = params

    http = Net::HTTP.new(uri.host, uri.port)
    res = http.start { http.get(uri.request_uri) }

    JSON.parse(res.body)
  end
end
