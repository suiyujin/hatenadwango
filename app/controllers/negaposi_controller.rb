class NegaposiController < ApplicationController
  def examine
    urls = params[:urls]

    dictionary = Dictionary.new

    response = { pages: [] }

    urls.each do |url|
      # はてブAPI
      res_hatena = HatenaBookmarkApi.request(url)

      page = Utils::Page.new(url: res_hatena['url'])
      page.bookmarks = res_hatena['bookmarks'].map do |bookmark|
        bookmark = Utils::Bookmark.new(
          timestamp: bookmark['timestamp'],
          comment: bookmark['comment'],
          user: bookmark['user'],
          tags: bookmark['tags']
                           )
      end

      # コメントのあるブックマーク一覧
      bookmarks_exist_comment = page.bookmarks.select { |bookmark| bookmark.comment.present? }

      # ネガポジ判定
      bookmarks_exist_comment.each do |bookmark_exist_comment|
        bookmark_exist_comment.parse

        chunks = bookmark_exist_comment.tree.chunks
        tokens_nva = chunks.map(&:tokens).flatten.select { |token| token.noun? || token.verb_jiritsu? || token.adjective_jiritsu? }

        tokens_nva.each do |token_nva|
          match_words = dictionary.redis.keys("#{token_nva.to_base}")
          if match_words.present?
            score = dictionary.redis.get(match_words[0]).to_i
            case score
            when -1 then
              bookmark_exist_comment.nega_words << match_words[0]
            when 1 then
              bookmark_exist_comment.posi_words << match_words[0]
            end
          end
        end
      end

      # レスポンス作る
      comments_num = bookmarks_exist_comment.size

      bookmarks_exist_nega_words = bookmarks_exist_comment.select do |bookmark|
        bookmark.nega_words.present?
      end
      bookmarks_exist_posi_words = bookmarks_exist_comment.select do |bookmark|
        bookmark.posi_words.present?
      end

      nega_comments_num = bookmarks_exist_nega_words.size
      posi_comments_num = bookmarks_exist_posi_words.size
      # とりあえず決め打ちの値
      #nega_comments_num = bookmarks_exist_comment.inject(0) do |sum, bookmark|
      #  sum + bookmark.nega_words.size
      #end
      #posi_comments_num = bookmarks_exist_comment.inject(0) do |sum, bookmark|
      #  sum + bookmark.posi_words.size
      #end

      nega_words = bookmarks_exist_nega_words.map(&:nega_words).flatten
      posi_words = bookmarks_exist_posi_words.map(&:posi_words).flatten
      nega_words_num = nega_words.size
      posi_words_num = posi_words.size
      nega_posi_words_num = nega_words_num + posi_words_num

      response[:pages] << {
        entry_id: res_hatena['eid'].to_s,
        url: res_hatena['url'],
        bookmarks_num: res_hatena['count'],
        comments_num: comments_num,
        nega_comments_num: nega_comments_num,
        posi_comments_num: posi_comments_num,
        nega_posi_words_num: nega_posi_words_num,
        nega_words_num: nega_words_num,
        posi_words_num: posi_words_num,
        nega_posi_words: nega_words + posi_words,
        nega_words: nega_words,
        posi_words: posi_words,
        scores: {
          sum: posi_words_num - nega_words_num,
          average: (posi_words_num - nega_words_num).to_f / nega_posi_words_num.to_f,
          nega_rate: nega_words_num.to_f / nega_posi_words_num.to_f,
          posi_rate: posi_words_num.to_f / nega_posi_words_num.to_f
        }
      }
    end

    render json: response, callback: callback_param
  end

  private

  def negaposi_params
    params.permit(:urls)
  end
end
