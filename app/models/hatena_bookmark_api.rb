class HatenaBookmarkApi < WebApi
  def self.request(url)
    super(
      site: 'http://b.hatena.ne.jp',
      path: '/entry/jsonlite/',
      params:
      {
        url: 'http://jkmorning.com/lp/'
      }
    )
  end
end
