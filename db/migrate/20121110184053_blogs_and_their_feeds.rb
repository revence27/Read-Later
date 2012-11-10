class BlogsAndTheirFeeds < ActiveRecord::Migration
  def up
    add_column :saved_blogs, :feed_url, :text, :null => true
  end

  def down
    remove_column :saved_blogs, :feed_url
  end
end
