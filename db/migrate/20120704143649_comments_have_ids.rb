class CommentsHaveIds < ActiveRecord::Migration
  def up
    add_column :saved_comments, :commentid, :text
  end

  def down
    remove_column :saved_comments, :commentid
  end
end
