class Utils::InsertDicIntoRedis
  def self.run
    nega = []
    posi = []
    data_dir = "#{Rails.root}/db/data/"

    File.open("#{data_dir}wago.121808.pn", 'r') do |f|
      f.each_line do |line|
        case line[0, 2]
        when 'ネガ' then
          nega << line.sub(/^[^\t]+\t/, '').sub(/\n$/, '')
        when 'ポジ' then
          posi << line.sub(/^[^\t]+\t/, '').sub(/\n$/, '')
        end
      end
    end

    File.open("#{data_dir}pn.csv.m3.120408.trim", 'r') do |f|
      f.each_line do |line|
        case line.sub(/^[^\t]+\t/, '').sub(/\t[^\t]+$/, '')
        when 'n' then
          nega << line.sub(/\t\w{1}\t.+\n$/, '')
        when 'p' then
          posi << line.sub(/\t\w{1}\t.+\n$/, '')
        end
      end
    end

    nega.delete_if(&:blank?)
    posi.delete_if(&:blank?)

    redis = Redis.new(load_config_file['hiredis'])
    redis.mset(*nega.map { |n| [n, -1] }.flatten)
    redis.mset(*posi.map { |p| [p, 1] }.flatten)
  end

  private

  def self.load_config_file
    YAML.load_file("#{Rails.root}/config/redis.yml")
  end
end
