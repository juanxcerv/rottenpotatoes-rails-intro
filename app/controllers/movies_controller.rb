class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @movies = Movie.all
    @all_ratings = Movie.ratings

    if session[:ratings]
      @filtered_ratings = session[:ratings].keys
    else 
      session[:ratings] = Movie.hash_ratings
    end

    if session[:sort]
      @sort_by = session[:sort]
    else
      session[:sort] = ''
    end

    if params[:ratings]
      @filtered_ratings = params[:ratings].keys
      session[:ratings] = params[:ratings]
    else
      redirect_sort = session[:sort]
      if params[:sort]
        redirect_sort = params[:sort]
      end
      flash.keep
      redirect_to movies_path(:ratings => session[:ratings], :sort => redirect_sort)
    end

    if params[:sort]
      @sort_by = params[:sort]
      session[:sort] = @sort_by
    end
    @movies = Movie.with_ratings(@filtered_ratings)
    @movies = @movies.sort_by{|title| title[@sort_by]}
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

end
