class StaticController < ApplicationController
  def about
    render layout: "application"
  end

  def developers
    render layout: "application"
  end

  def faq
    render layout: "application"
  end
end
