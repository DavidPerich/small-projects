class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :vote]
  before_action :require_user, except: [:show, :index]
  before_action :require_same_user, only: [:edit, :update]

  def index
    @posts = Post.all.sort_by{|post| post.total_votes}.reverse
  end

  def show
    @comment = Comment.new
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    @post.user = current_user

    if @post.save
      flash[:notice] = "Your post was created"
      redirect_to posts_path
    else
      render :new
    end
  end

  def edit;

  end

  def update
    if @post.update(post_params)
      flash[:notice]  = "The post was updated"
      redirect_to post_path(@post)
    else
      render :edit
    end
  end

  def vote
    newVote = Vote.create(voteable: @post, user: current_user, vote: params[:vote])

    if newVote.valid?
      flash[:notice]  = "Your vote was counted"
    else
      flash[:error] = "You can only vote once"
    end
    redirect_back(fallback_location: root_path)
  end

  private

  def post_params
    params.require(:post).permit(:title,:url, :description, category_ids: [])
  end

  def set_post
    @post = Post.find(params[:id])
  end

  private

  def require_same_user
    if current_user != @post.user
      flash[:error] = "You are not allowed to do that"
      redirect_to root_path
    end
  end
end
