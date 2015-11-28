class NegaposiController < ApplicationController
  def examine
    urls = params[:urls]

    # はてブAPI
    res_hatena = HatenaBookmarkApi.request(urls[0])

    # コメント正規化する

    # ネガポジ判定

    # レスポンス作る

    # とりあえず決め打ちの値
    comments_num = res_hatena['count'] / 2
    nega_comments_num = res_hatena['count'] / 4
    posi_comments_num = res_hatena['count'] / 4
    nega_posi_words_num = 5
    nega_words_num = 3
    posi_words_num = 2
    nega_words = ['あきらめる', 'いたたまれない', 'しょんぼり']
    posi_words = ['勝つ', '自信がある', '惚れる']

    response = {
      pages: {
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
    }

    render json: response, callback: callback_param
  end

  private

  def negaposi_params
    params.permit(:urls)
  end
end
