class CommentsController < ApplicationController
  before_action :authorize_request
  before_action :set_post
  before_action :set_comment, only: [:update, :destroy]
  before_action :authorize_comment_owner, only: [:update, :destroy]

  
  def create
    comment = @post.comments.build(comment_params.merge(user: @current_user))
    if comment.save
      render json: comment, status: :created
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def index
    comments = @post.comments.includes(:user)
    render json: comments.as_json(include: { user: { only: [:id, :name, :email] } })
    end
  
  def update
    if @comment.update(comment_params)
      render json: @comment
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  
  def destroy
    @comment.destroy
    head :no_content
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Post not found" }, status: :not_found
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Comment not found" }, status: :not_found
  end

  def comment_params
    params.require(:comment).permit(:body)
  end

  def authorize_comment_owner
    unless @comment.user == @current_user
      render json: { error: "You can only edit or delete your own comments" }, status: :unauthorized
    end
  end
end
