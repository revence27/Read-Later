class CreateSavedPosts < ActiveRecord::Migration
  def change
    create_table :saved_posts do |t|
      t.text        :title
      t.text        :html
      t.timestamp   :when
      t.boolean     :seen
      t.integer     :saved_blog_id
      t.timestamps
    end
  end
end
