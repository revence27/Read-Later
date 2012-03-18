class ReadlaterController < ApplicationController
  def index
    @blogs  = SavedBlog.order 'name ASC'
  end

  def blog
    @blog   = SavedBlog.find_by_id request[:id]
    @posts  = @blog.saved_posts.unread.order '"when" ASC'
    @read   = @blog.saved_posts.where('seen').order '"when" DESC'
  end

  def article
    @blog = SavedBlog.find_by_id request[:blog]
    @post = SavedPost.find_by_id request[:id]
  end

  def read
    @blog = SavedBlog.find_by_id request[:blog]
    @post = @blog.saved_posts.unread.find_by_id(request[:id])
    if @post then
      @post.seen = true
      @post.save
    end
    redirect_to blog_path(:id => @blog.id)
  end
end
