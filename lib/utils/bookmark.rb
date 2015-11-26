class Utils::Bookmark
  attr_reader :timestamp, :comment, :user, :tags, :normalize_comment

  def initialize(timestamp: '', comment: '', user: '', tags: [])
    @timestamp = timestamp
    @comment = comment
    @user = user
    @tags = tags
  end

  private

  def normalize_comment
  end
end
