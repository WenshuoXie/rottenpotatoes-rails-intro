class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    #@movies = Movie.all
    @all_ratings = Movie.all_ratings
    # @order = params[:target]
    if params.has_key?(:ratings)
      @ratings_to_show = params[:ratings].keys
      session[:ratings] = @ratings_to_show
    elsif session.key?(:ratings)
      params[:ratings] = session[:ratings]
      @ratings_to_show = params[:ratings]
      redirect = true
    else
      @ratings_to_show = @all_ratings
    end

    if params.has_key?(:target)
      @target = params[:target]
      session[:target] = @target
    elsif session.key?(:target)
      params[:target] = session[:target]
      redirect = true
    end
    @ratings_to_show_hash = Hash[@ratings_to_show.map {|r| [r,1]}]
    if redirect
      redirect_to movies_path(:ratings => @ratings_to_show_hash, :target => session[:target]) and return
    end
    # if params[:ratings].nil?
	  #   @ratings_to_show = []
    # else
    # 	@ratings_to_show = params[:ratings].keys
    #   @ratings_to_show_hash = Hash[@ratings_to_show.map {|r| [r,1]}]
    # end
    @movies = Movie.with_ratings(@ratings_to_show)
    if params[:target] != nil
      if params[:target] == 'title'
        @title_header = 'hilite bg-warning'
      end
      if params[:target] == 'release_date'
        @release_date_header = 'hilite bg-warning'
      end
      @movies = @movies.order(params[:target])
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
