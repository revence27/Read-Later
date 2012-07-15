class CachedCommentCount < ActiveRecord::Migration
  def up
    add_column :saved_posts, :comment_count, :integer, :default => 0
  end

  def down
    remove_column :saved_posts, :comment_count
  end
end
