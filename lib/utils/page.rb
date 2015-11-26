class Utils::Page
  attr_accessor :url, :bookmarks

  def initialize(url: )
    @url = url
  end
end
