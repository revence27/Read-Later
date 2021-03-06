class SavedPost < ActiveRecord::Base
  belongs_to :saved_blog
  has_many   :saved_images
  has_many   :saved_comments
  scope :unread, where(:seen => false)
end
