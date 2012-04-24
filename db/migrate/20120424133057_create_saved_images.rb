class CreateSavedImages < ActiveRecord::Migration
  def change
    create_table :saved_images do |t|
      t.text        :resource_b64
      t.text        :content_type
      t.text        :original
      t.text        :suggested_name
      t.integer     :saved_post_id
      t.timestamps
    end
  end
end
