class Dictionary
  attr_reader :redis

  def initialize
    @redis = Redis.new(load_config_file['hiredis'])
  end

  def search
  end

  private

  def load_config_file
    YAML.load_file("#{Rails.root}/config/redis.yml")
  end
end
