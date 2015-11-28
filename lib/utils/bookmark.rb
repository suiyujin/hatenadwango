class Utils::Bookmark
  attr_reader :timestamp, :comment, :user, :tags, :normalize_comment

  def initialize(timestamp: '', comment: '', user: '', tags: [])
    @timestamp = timestamp
    @comment = comment
    @user = user
    @tags = tags

    if comment.blank?
      @normalize_comment = ''
      @tree = nil
    else
      @normalize_comment = normalize_comment
      parser = CaboCha::Parser.new
      @tree = parser.parse(@normalize_comment)
    end
  end

  def make_base_array
    @tree.nil? ? nil : @tree.chunks.map(&:tokens).flatten.map(&:to_base)
  end

  private

  def normalize_comment
    comment = @comment
    comment.tr!("０-９Ａ-Ｚａ-ｚ", "0-9A-Za-z")
    comment = Moji.han_to_zen(comment, Moji::HAN_KATA)
    hypon_reg = /(?:˗|֊|‐|‑|‒|–|⁃|⁻|₋|−)/
    comment.gsub!(hypon_reg, "-")
    choon_reg = /(?:﹣|－|ｰ|—|―|─|━)/
    comment.gsub!(choon_reg, "ー")
    chil_reg = /(?:~|∼|∾|〜|〰|～)/
    comment.gsub!(chil_reg, '')
    comment.gsub!(/[ー]+/, "ー")
    comment.tr!(%q{!"#$%&'()*+,-.\/:;<=>?@[¥]^_`{|}~｡､･｢｣"}, %q{！”＃＄％＆’（）＊＋，−．／：；＜＝＞？＠［￥］＾＿｀｛｜｝〜。、・「」})
    comment.gsub!(/　/, " ")
    comment.gsub!(/ {1,}/, " ")
    comment.gsub!(/^[ ]+(.+?)$/, "\\1")
    comment.gsub!(/^(.+?)[ ]+$/, "\\1")
    while comment =~ %r{([\p{InCjkUnifiedIdeographs}\p{InHiragana}\p{InKatakana}\p{InHalfwidthAndFullwidthForms}\p{InCJKSymbolsAndPunctuation}]+?)[ ]{1}([\p{InCjkUnifiedIdeographs}\p{InHiragana}\p{InKatakana}\p{InHalfwidthAndFullwidthForms}\p{InCJKSymbolsAndPunctuation}]+?)}
      comment.gsub!( %r{([\p{InCJKUnifiedIdeographs}\p{InHiragana}\p{InKatakana}\p{InHalfwidthAndFullwidthForms}\p{InCJKSymbolsAndPunctuation}]+?)[ ]{1}([\p{InCJKUnifiedIdeographs}\p{InHiragana}\p{InKatakana}\p{InHalfwidthAndFullwidthForms}\p{InCJKSymbolsAndPunctuation}]+?)}, "\\1\\2")
    end
    while comment =~ %r{([\p{InBasicLatin}]+)[ ]{1}([\p{InCJKUnifiedIdeographs}\p{InHiragana}\p{InKatakana}\p{InHalfwidthAndFullwidthForms}\p{InCJKSymbolsAndPunctuation}]+)}
      comment.gsub!(%r{([\p{InBasicLatin}]+)[ ]{1}([\p{InCJKUnifiedIdeographs}\p{InHiragana}\p{InKatakana}\p{InHalfwidthAndFullwidthForms}\p{InCJKSymbolsAndPunctuation}]+)}, "\\1\\2")
    end
    while comment =~ %r{([\p{InCJKUnifiedIdeographs}\p{InHiragana}\p{InKatakana}\p{InHalfwidthAndFullwidthForms}\p{InCJKSymbolsAndPunctuation}]+)[ ]{1}([\p{InBasicLatin}]+)}
      comment.gsub!(%r{([\p{InCJKUnifiedIdeographs}\p{InHiragana}\p{InKatakana}\p{InHalfwidthAndFullwidthForms}\p{InCJKSymbolsAndPunctuation}]+)[ ]{1}([\p{InBasicLatin}]+)}, "\\1\\2")
    end
    comment.tr!(
      %q{！”＃＄％＆’（）＊＋，−．／：；＜＞？＠［￥］＾＿｀｛｜｝〜},
      %q{!"#$%&'()*+,-.\/:;<>?@[¥]^_`{|}~}
    )
    comment
  end
end
