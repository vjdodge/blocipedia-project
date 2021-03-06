class WikisController < ApplicationController
  before_action :require_sign_in, except: [:public, :show]
  before_action :authorized, only: [:show, :edit, :update]
  before_action :authorize_user, only: [:destroy]

  def index
    user = current_user
    @wikis = []
    all_wikis = policy_scope(Wiki)
    all_wikis.each do |wiki|
      if wiki.creator == user || wiki.collaborators.include?(user)
        @wikis << wiki # only show wikis they created, or private wikis they are a collaborator on
      end
    end
  end

  def public
    @wikis = policy_scope(Wiki)
  end

  def show
    @user = current_user
    @wiki = Wiki.find(params[:id])
  end

  def new
    @wiki = Wiki.new
  end

  def create
    @wiki = Wiki.new
    @wiki.assign_attributes(wiki_params)
    @wiki.creator = current_user
    collaborator = User.find_by_email(params[:collaborator_email])

    if @wiki.save
      if collaborator
        @wiki.collaborators << collaborator
      end
      flash[:notice] = "\"#{@wiki.title}\" was created successfully."
      redirect_to @wiki
    else
      flash.now[:alert] = "There was an error creating the wiki. Please try again."
      render :new
    end
  end

  def edit
    @wiki = Wiki.find(params[:id])
  end

  def update
    @wiki = Wiki.find(params[:id])
    @wiki.assign_attributes(wiki_params)
    collaborator = User.find_by_email(params[:collaborator_email])

    if @wiki.save
      if collaborator && !@wiki.collaborators.include?(collaborator)
        @wiki.collaborators << collaborator
      end
      flash[:notice] = "\"#{@wiki.title}\" was updated successfully."
    else
      flash.now[:alert] = "There was an error updating the wiki."
    end
    render :edit
  end

  def destroy
    @wiki = Wiki.find(params[:id])
    if @wiki.destroy
          flash[:notice] = "\"#{@wiki.title}\" was deleted successfully."
          redirect_to wikis_path
    else
          flash.now[:alert] = "There was an error deleting the wiki."
          render :show
    end
  end

  private

  def wiki_params
      params.require(:wiki).permit(:title, :body, :private)
  end

end
