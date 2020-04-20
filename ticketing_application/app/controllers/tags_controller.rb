class TagsController < ApplicationController
  before_action :set_tag, only: [:edit, :update, :destroy]
  # before_action :require_same_user, except: [:index, :show]
  before_action :require_user, except: [:index, :show]



  def index
    @tags = Tag.all
  end

  def show

  end

  def new
    @tag = Tag.new
  end

  def create
    @tag = Tag.new(tag_params)

    if @tag.save
      flash[:notice] = "Your tag was created"
      redirect_to tags_path
    else
      flash.now[:error] = "Something went wrong"
      render :new
    end
  end

  def edit; end

  def update
    if @tag.update(tag_params)
      flash[:notice] = "Your tag was updated"
      redirect_to tags_path
    else
      flash.now[:error] = "Something went wrong"
      render :edit
    end
  end

  def destroy
    if @tag.destroy
      flash[:notice] = "Your tag was deleted"
      redirect_to tags_path
    else
      flash.now[:error] = "Tag unable to be deleted"
      render :show
    end
  end

  private

  def set_tag
    @tag = Tag.find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:name)
  end
end