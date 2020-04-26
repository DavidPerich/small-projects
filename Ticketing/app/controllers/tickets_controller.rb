class TicketsController < ApplicationController
  before_action :set_ticket, only: [:show, :edit, :update, :destroy]
  # before_action :require_same_user
  before_action :require_user, except: [:index, :show]


  def index
    # binding.pry
    if  params[:tag_id].present?
      @tickets = Ticket.where(filter_params).select {|ticket| ticket_include_tags(ticket, params["tag_id"])}
    elsif params[:filter].present?
      @tickets = Ticket.where(filter_params)
    else
      @tickets = Ticket.all
    end
  end

  def show
    @comment = Comment.new
  end

  def new
    @ticket = Ticket.new
  end

  def create
    @ticket = Ticket.new(ticket_params)
    @ticket.creator = current_user
    if @ticket.save
      flash[:notice] = "Your ticket was created"
      redirect_to tickets_path
    else
      flash[:error] = "Something went wrong"
      render :new
    end
  end

  def edit
  end

  def update
    if @ticket.update(ticket_params)
      flash[:notice] = "Your ticket was updated"
      redirect_to ticket_path(@ticket)
    else
      flash.now[:error] = "Something went wrong"
      render :edit
    end
  end

  def destroy
    if @ticket.destroy
      flash[:notice] = "Your ticket was deleted"
      @tickets = Ticket.all
      redirect_back(fallback_location: root_path)
    else
      flash.now[:error] = "Somethign went wrong"
      render :edit
    end
  end

  private

  def ticket_params
    binding.pry
    params.require(:ticket).permit(:name, :body, :status, :assignee_id, :project_id, tag_ids: [])
  end

  def set_ticket
    @ticket = Ticket.find(params[:id])
  end

  def filter_params
    params.require(:filter).permit(:project_id, :status).select {|k, v| v.present?}
  end

  def ticket_include_tags(ticket, search_tag_id)
    tag = Tag.find(search_tag_id)
    ticket.tags.include?(tag)
  end


end