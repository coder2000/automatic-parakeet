class HashtagsController < ApplicationController
  def show
    @hashtag = params[:hashtag]

    # Find all comments with this hashtag, including their games and users for display
    @comments = Comment.with_hashtag(@hashtag)
      .includes(:user, :game, :replies)
      .recent
      .limit(50)

    # Get some stats
    @comment_count = Comment.with_hashtag(@hashtag).count
    @games_count = Comment.with_hashtag(@hashtag).joins(:game).distinct.count("games.id")

    # Find other popular hashtags from the same comments
    hashtag_content = Comment.with_hashtag(@hashtag).pluck(:content).join(" ")
    all_hashtags = hashtag_content.scan(/(^|\s)#([a-zA-Z_][\w]*)/m).map { |match| match[1].downcase }.uniq
    @related_hashtags = all_hashtags.reject { |tag| tag == @hashtag.downcase }.take(10)
  end
end
