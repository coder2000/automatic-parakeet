module Recommendations
  class DiscoRecommender
    # Builds or fetches a cached Disco recommender based on followings.
    # Data model: implicit feedback "follow" only.
    #
    # API:
    # - recommendations_for(user_id, limit: 10) => [game_id,...]
    # - similar_games(game_id, limit: 10) => [game_id,...]
    # - warm? => whether we have enough data to recommend
    CACHE_KEY = "disco_recommender:v1"
    CACHE_TTL = 30.minutes

    def initialize(cache: Rails.cache)
      @cache = cache
    end

    def recommendations_for(user_id, limit: 6)
      model = model()
      return [] unless model

      ids = model.recommend(user_id, count: limit)
      # Filter to existing games and keep ordering
      game_ids = Game.where(id: ids).pluck(:id)
      ids & game_ids
    rescue => e
      Rails.logger.error("Disco recommend error: #{e.class}: #{e.message}")
      []
    end

    def similar_games(game_id, limit: 6)
      model = model()
      return [] unless model

      ids = model.similar_items(game_id, count: limit)
      game_ids = Game.where(id: ids).pluck(:id)
      ids & game_ids
    rescue => e
      Rails.logger.error("Disco similar_items error: #{e.class}: #{e.message}")
      []
    end

    def warm?
      @cache.fetch("#{CACHE_KEY}:warm", expires_in: CACHE_TTL) do
        Following.count >= 20 && User.joins(:followings).distinct.count >= 5
      end
    end

    def rebuild!
      data = Following.select(:user_id, :game_id).find_each(batch_size: 5_000).map { |f| [f.user_id, f.game_id, 1.0] }
      return nil if data.empty?
      begin
        require "disco"
      rescue LoadError
        Rails.logger.warn("Disco gem not available; skipping recommender build")
        return nil
      end
      model = Disco::Recommender.new
      model.fit(data)
      # Serialize the model for cache
      blob = Marshal.dump(model)
      @cache.write(CACHE_KEY, blob, expires_in: CACHE_TTL)
      @cache.write("#{CACHE_KEY}:warm", true, expires_in: CACHE_TTL)
      model
    end

    def model
      blob = @cache.read(CACHE_KEY)
      return Marshal.load(blob) if blob

      # Build lazily; keep it fast
      rebuild!
    rescue => e
      Rails.logger.error("Disco model load error: #{e.class}: #{e.message}")
      nil
    end
  end
end
