class CreateSavedComments < ActiveRecord::Migration
  def change
    create_table :saved_comments do |t|
      t.text          :author
      t.text          :author_url
      t.timestamp     :published_at
      t.text          :content
      t.integer       :saved_post_id
      t.timestamps
    end
  end
end
