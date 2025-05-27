class PostsController < ApplicationController
  before_action :set_post, only: [:show, :update, :destroy]
  before_action :check_owner, only: [:update, :destroy]

  
  def index
  posts = Post.includes(:user, comments: :user).all
  render json: posts.as_json(include: {
    user: { only: [:id, :name, :email] },
    comments: {
      include: { user: { only: [:id, :name, :email] } },
      only: [:id, :body, :created_at]
    }
  })
  end


  
  def show
  render json: @post.as_json(include: {
    user: { only: [:id, :name, :email] },
    comments: {
      include: { user: { only: [:id, :name, :email] } },
      only: [:id, :body, :created_at]
    }
  })
  end


  
 

  def create
    @post = @current_user.posts.build(title: params[:post][:title], body: params[:post][:body])

   
    tag_names = params[:post][:tag_names]
    if tag_names.blank?
      return render json: { errors: ["Tags can't be blank"] }, status: :unprocessable_entity
    end

    tags = tag_names.map { |name| Tag.find_or_create_by(name: name.downcase.strip) }
    @post.tags = tags

    if @post.save
      DeletePostJob.set(wait: 24.hours).perform_later(@post.id)
      render json: @post, status: :created
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  


  def update
    tag_names = params[:post][:tag_names]
    if tag_names.blank?
      return render json: { errors: ["Tags can't be blank"] }, status: :unprocessable_entity
    end

    tags = tag_names.map { |name| Tag.find_or_create_by(name: name.downcase.strip) }

    if @post.update(title: params[:post][:title], body: params[:post][:body])
      @post.tags = tags
      render json: @post
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  
  def destroy
    @post.destroy
    head :no_content
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  
  def check_owner
    unless @post.user == current_user
      render json: { errors: ['You can only edit or delete your own posts'] }, status: :forbidden
    end
  end

  def post_params
    params.require(:post).permit(:title, :body, tag_names: [])
  end

  

  def attach_tags(post, tag_names)
    return unless tag_names.present?

    tags = tag_names.map { |name| Tag.find_or_create_by(name: name.downcase.strip) }
    post.tags = tags
  end
end
