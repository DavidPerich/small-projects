class CommentsController < ApplicationController
  before_action :set_post
  before_action :require_user


  def create
    @comment = @post.comments.build(params.require(:comment).permit(:body))
    @comment.user_id = current_user.id

    if @comment.save
      flash[:notice] = "Your comment was added"
      redirect_to post_path(@post)
    else
      render "posts/show"
    end
  end


  def vote
    comment = @post.comments.find_by(id: params[:comment_id])
    Vote.create(voteable: comment, user: current_user, vote: params[:vote])
    flash[:notice]  = "Your vote was counted"
    redirect_back(fallback_location: root_path)
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end



end