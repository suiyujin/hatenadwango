module CaboCha
  class Token
    # 名詞？
    def noun?
      feature_list(0) == '名詞'
    end
    # 動詞自立？
    def verb_jiritsu?
      feature_list(0) == '動詞' &&
        feature_list(1) == '自立'
    end
    # 形容詞自立？
    def adjective_jiritsu?
      feature_list(0) == '形容詞' &&
        feature_list(1) == '自立'
    end

    # 基本形へ
    def to_base
      if (feature_list_size > 6 && feature_list(6) != "*")
        feature_list(6)
      else
        to_s
      end
    end

    def to_s
      @to_s ||=
      if ("".respond_to?("force_encoding"))
        normalized_surface.force_encoding("utf-8")
      else
        normalized_surface # 本当はsurface
      end
    end

    alias :feature_list_org :feature_list
    def feature_list(i)
      if (@feature_list)
        @feature_list[i]
      else
        if ("".respond_to?("force_encoding"))
          @feature_list ||= (0 ... feature_list_size).map do |j|
            feature = feature_list_org(j)
            feature.force_encoding("utf-8")
          end
          @feature_list[i]
        else
          @feature_list ||= (0 ... feature_list_size).map{|j| feature_list_org(j) }
          @feature_list[i]
        end
      end
    end
  end
  class Chunk
    attr_accessor :tree

    def tokens
      @tokens ||= (0 ... token_size).map{|i| tree.token(token_pos + i) }
    end
  end
  class Tree
    alias :chunk_org :chunk
    def chunk(i)
      if (@chunks)
        @chunks[i]
      else
        chunk = chunk_org(i)
        chunk.tree = self
        chunk
      end
    end
    def chunks
      @chunks ||= (0 ... chunk_size).map {|i| chunk(i)}
    end
  end
end
