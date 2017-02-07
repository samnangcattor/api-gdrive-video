class MoviesController < ApplicationController
  def index
  end

  def create
    url = params[:url]
    @links = GoogleDrive.list_link_videos url
    render :index
  end
end
