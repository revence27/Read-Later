class CreateSavedBlogs < ActiveRecord::Migration
  def change
    create_table :saved_blogs do |t|
      t.text        :name
      t.text        :by
      t.timestamps
    end
  end
end
