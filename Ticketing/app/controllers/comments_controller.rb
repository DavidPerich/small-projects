class CommentsController < ApplicationController
  before_action :set_ticket, only: [:create, :edit, :update, :destroy]
  before_action :set_comment, only:  [:edit, :update, :destroy]
  before_action :require_same_user, only: [:edit, :update, :destroy]

  def create
    @comment = @ticket.comments.build(comment_params.merge(creator: current_user))

    if @comment.save
      if params[:ticket_status].present?
        @ticket.update_attribute(:status, params[:ticket_status])
      end
      flash[:notice] = "Your comment was added"
      redirect_to ticket_path(@ticket)
    else
      render "tickets/show"
    end
  end

  def edit;   end

  def update
    if @comment.update(comment_params)
      flash[:notice] = "Comment updated"
      redirect_to ticket_path(@ticket)
    else
      render :edit
    end
  end

  def destroy
    @comment.destroy
    redirect_to @ticket, notice: 'Comment was successfully destroyed.'
  end
  private

  def set_comment
    @comment = @ticket.comments.find(params[:id])
  end

  def set_ticket
    @ticket = Ticket.find(params[:ticket_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end

  def require_same_user
    if current_user != @comment.creator
      flash[:error] = "You are not allowed to do that"
        redirect_back(fallback_location: root_path)
    end
  end
end