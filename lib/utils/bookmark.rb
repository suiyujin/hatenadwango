class Utils::Bookmark
  attr_reader :timestamp, :comment, :user, :tags, :normalize_comment

  def initialize(timestamp: '', comment: '', user: '', tags: [])
    @timestamp = timestamp
    @comment = comment
    @user = user
    @tags = tags

    parser = CaboCha::Parser.new
    @tree = parser.parse(comment)
  end

  def make_base_array
    @tree.chunks.map(&:tokens).flatten.map(&:to_base)
  end

  private

  def normalize_comment
  end
end
