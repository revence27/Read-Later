class ContextualPosts < ActiveRecord::Migration
  def up
    change_table :saved_posts do |t|
      t.text      :original
      t.text      :picture
    end
  end

  def down
    remove_columns :original, :picture
  end
end
