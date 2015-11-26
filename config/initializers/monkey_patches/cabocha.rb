module CaboCha
  class Token
    # 名詞？
    def noun?
      feature_list(0) == '名詞'
    end
    # 名詞接続? (「お星様」の「お」など)
    def meishi_setsuzoku?
      feature_list(0) == '接頭詞' &&
        feature_list(1) == '名詞接続'
    end
    # 動詞？
    def verb?
      feature_list(0) == '動詞'
    end
    # 形容詞？
    def adjective?
      feature_list(0) == '形容詞'
    end
    # 名詞サ変接続？
    def sahen_setsuzoku?
      feature_list(0) == '名詞' &&
        feature_list(1) == 'サ変接続'
    end
    # サ変する？
    def sahen_suru?
      feature_list(4) == 'サ変・スル'
    end

    # 基本形へ
    def to_base
      if (feature_list_size > 6 && feature_list(6) != "*")
        feature_list(6)
      else
        to_s
      end
    end

    # 動詞の活用

    ## 一段命令形の形 (0:食べよ 1:食べれ 2:食べろ)
    V_ICHIDAN_MEIREI = ['よ', 'れ', 'ろ']
    V_ICHIDAN_MEIREI_TYPE = 2

    def v_godan?
      @v_godan ||= (feature_list(4) =~ /^五段/)
    end
    def v_rahen?
      @v_rahen ||= (feature_list(4) =~ /^ラ変/)
    end
    def v_ichidan?
      @v_ichidan ||= (feature_list(4) =~ /^一段/)
    end
    def v_yodan?
      @v_yodan ||= (feature_list(4) =~ /^四段/)
    end
    def v_kahen?
      @v_kahen ||= (feature_list(4) =~ /^カ変/)
    end
    def v_sahen?
      @v_sahen ||= (feature_list(4) =~ /^サ変/)
    end
    def v_kami_nidan?
      @v_kami_nidan ||= (feature_list(4) =~ /^上二/)
    end

    ## 活用
    def v_inflect(type)
      if (v_godan?)
        base = to_base
        v_type = feature_list(4)
        case (v_type)
        when /カ行/
          base.gsub(/[ぁ-ん]$/, '') + %w(か き く く け け)[type]
        when /ガ行/
          base.gsub(/[ぁ-ん]$/, '') + %w(が ぎ ぐ ぐ げ げ)[type]
        when /サ行/
          base.gsub(/[ぁ-ん]$/, '') + %w(さ し す す せ せ)[type]
        when /タ行/
          base.gsub(/[ぁ-ん]$/, '') + %w(た ち つ つ て て)[type]
        when /ナ行/
          base.gsub(/[ぁ-ん]$/, '') + %w(な に ぬ ぬ ね ね)[type]
        when /バ行/
          base.gsub(/[ぁ-ん]$/, '') + %w(ば び ぶ ぶ べ べ)[type]
        when /マ行/
          base.gsub(/[ぁ-ん]$/, '') + %w(ま み む む め め)[type]
        when /ラ行/
          base.gsub(/[ぁ-ん]$/, '') + %w(ら り る る れ れ)[type]
        when /ワ行/
          base.gsub(/[ぁ-ん]$/, '') + %w(わ い う う え え)[type]
        else
          raise "unknown feature_list(4) #{feature_list(4)}"
        end
      elsif (v_sahen?)
        v_type = feature_list(4)
        case v_type
        when /スル/
          %w(し し する する すれ しろ)[type]
        when /ズル/
          to_base.gsub(/[ぁ-ん]$/, '') + %w(ぜ ず ずる ずる ずれ ぜよ)[type]
        else
          raise "unknown feature_list(4) #{feature_list(4)}"
        end
      elsif (v_ichidan?)
        to_base.gsub(/[ぁ-ん]$/, '') +
          ['', '', 'る', 'る', 'れ', V_ICHIDAN_MEIREI[V_ICHIDAN_MEIREI_TYPE]][type]
      elsif (v_rahen?)
        to_base.gsub(/[ぁ-ん]$/,'') + %w(ら り り る れ れ)[type]
      elsif (v_yodan?)
        v_type = feature_list(4)
        case v_type
        when /カ行/
          to_base.gsub(/[ぁ-ん]$/,'') + %w(か き く く け け)[type]
        when /ガ行/
          to_base.gsub(/[ぁ-ん]$/,'') + %w(が ぎ ぐ ぐ げ げ)[type]
        when /サ行/
          to_base.gsub(/[ぁ-ん]$/,'') + %w(さ し す す せ せ)[type]
        when /タ行/
          to_base.gsub(/[ぁ-ん]$/,'') + %w(た ち つ つ て て)[type]
        when /ハ行/
          to_base.gsub(/[ぁ-ん]$/,'') + %w(は ひ ふ ふ へ へ)[type]
        when /バ行/
          to_base.gsub(/[ぁ-ん]$/,'') + %w(ば び ぶ ぶ べ べ)[type]
        when /マ行/
          to_base.gsub(/[ぁ-ん]$/,'') + %w(ま み む む め め)[type]
        when /ラ行/
          to_base.gsub(/[ぁ-ん]$/,'') + %w(ら り る る れ れ)[type]
        else
          raise "unknown feature_list(4) #{feature_list(4)}"
        end
      elsif (v_kahen?)
        v_type = feature_list(4)
        if (v_type == 'カ変・クル' || v_type == 'カ変・来ル')
          %w(来 来 来る 来る 来れ 来い)[type]
        end
      elsif (v_kami_nidan?)
        v_type = feature_list(4)
        case v_type
        when /カ行/
          to_base.gsub(/[ぁ-ん]$/,'') + %w(き き く くる くれ きよ)[type]
        when /ガ行/
          to_base.gsub(/[ぁ-ん]$/,'') + %w(ぎ ぎ ぐ ぐる ぐれ ぎよ)[type]
        when /タ行/
          to_base.gsub(/[ぁ-ん]$/,'') + %w(ち ち つ つる つれ ちよ)[type]
        when /ダ行/
          to_base.gsub(/[ぁ-ん]$/,'') + %w(ぢ ぢ づ づる づれ ぢよ)[type]
        when /ハ行/
          to_base.gsub(/[ぁ-ん]$/,'') + %w(ひ ひ ふ ふる ふれ ひよ)[type]
        when /バ行/
          to_base.gsub(/[ぁ-ん]$/,'') + %w(び び ぶ ぶる ぶれ びよ)[type]
        when /マ行/
          to_base.gsub(/[ぁ-ん]$/,'') + %w(み み む むる むれ みよ)[type]
        when /ヤ行/
          to_base.gsub(/[ぁ-ん]$/,'') + %w(い い ゆ ゆる ゆれ いよ)[type]
        when /ラ行/
          to_base.gsub(/[ぁ-ん]$/,'') + %w(り り る るる るれ りよ)[type]
        else
          raise "unknown feature_list(4) #{feature_list(4)}"
        end
      else
        raise "unknown feature_list(4) #{feature_list(4)}"
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

    # 活用
    def v_inflect(type)
      if (verb_sahen?)
        tokens[0].to_base + tokens[1].v_inflect(type)
      else
        tokens[0].v_inflect(type)
      end
    end
    # 未然形
    def to_mizen
      @to_mizen ||= v_inflect(0)
    end
    # 連用形
    def to_renyo
      @to_renyo ||= v_inflect(1)
    end
    # 終止形
    def to_syushi
      @to_syushi ||= v_inflect(2)
    end
    # 連体形
    def to_rentai
      @to_rentai ||= v_inflect(3)
    end
    # 仮定形
    def to_katei
      @to_katei ||= v_inflect(4)
    end
    # 命令形
    def to_meirei
      @to_meirei ||= v_inflect(5)
    end
    # 否定形
    def to_negative
      @to_negative ||=
      if (noun?)
        to_base + 'じゃない'
      elsif (adjective?)
        if (to_base == "ない" || to_base == "無い")
          "ある"
        else
          to_base.gsub(/[ぁ-ん]$/,'') + 'くない'
        end
      elsif (verb?)
        if (to_base == 'ある')
          "ない"
        else
          to_mizen + "ない"
        end
      else
        to_base
      end
    end
    def to_noun
      @to_noun ||=
      if (noun?)
        to_base
      elsif (verb?)
        # 飛ぶの, 泳ぐの
        to_base + 'の'
      elsif (adjective?)
        # かわいいの, 大きいの
        to_base + 'の'
      else
        to_base
      end
    end

    # 動詞？
    def verb?
      tokens[0].verb? || verb_sahen?
    end
    # 名詞サ変接続+スル 動詞 (掃除する 洗濯する など)
    def verb_sahen?
      (tokens.length > 1 &&
       tokens[0].sahen_setsuzoku? && tokens[1].sahen_suru?)
    end
    # 名詞？
    def noun?
      (!verb_sahen? && (tokens[0].noun? || tokens[0].meishi_setsuzoku?))
    end
    # 形容詞？
    def adjective?
      tokens[0].adjective?
    end
    # 主語っぽい？
    def subject?
      (((noun? && %w(は って も が).include?(tokens[-1].to_s)) ||
        (adjective? && %w(は って も が).include?(tokens[-1].to_s)) ||
        (verb? && %w(は って も が).include?(tokens[-1].to_s))))
    end
    # 基本形へ
    def to_base
      @to_base ||=
      if (noun?)
        # 連続する名詞、・_や名詞接続をくっつける
        base = ""
        tokens.each do |token|
          if (token.meishi_setsuzoku?)
            base += token.to_base
          elsif (token.noun?)
            base += token.to_base
          elsif (["_","・"].include?(token.to_s))
            base += token.to_base
          elsif (base.length > 0)
            break
          end
        end
        base
      elsif (verb_sahen?)
        tokens[0].to_base + tokens[1].to_base
      elsif (verb?)
        tokens[0].to_base
      elsif (adjective?)
        tokens[0].to_base
      else
        to_s
      end
    end

    def tokens
      @tokens ||= (0 ... token_size).map{|i| tree.token(token_pos + i) }
    end
    def next_chunk
      @next_chunk ||= (link >= 0) ? tree.chunk(link) : nil
    end
    def prev_chunks
      @prev_chunks ||= tree.chunks.select{|chunk| chunk.link == self_index }
    end
    def to_s
      @to_s ||= tokens.map{|t| t.to_s }.join
    end
    def self_index
      @self_index ||= tree.chunks.reduce([nil, 0]) do |argv, chunk|
        if (chunk.token_pos == self.token_pos)
          argv[0] = argv[1]
        else
          argv[1] += 1
        end
        argv
      end.shift
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
