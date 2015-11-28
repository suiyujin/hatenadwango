class NegaposiController < ApplicationController
  def examine
    urls = params[:urls]

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

      # レスポンス作る
      comments_num = bookmarks_exist_comment.size

      # とりあえず決め打ちの値
      nega_comments_num = comments_num / 2 - 5
      posi_comments_num = comments_num / 2 + 5

      nega_words = ['あきらめる', 'いたたまれない', 'しょんぼり']
      posi_words = ['勝つ', '自信がある']
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
