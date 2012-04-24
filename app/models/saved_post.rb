class SavedPost < ActiveRecord::Base
  belongs_to :saved_blog
  has_many   :saved_images
  scope :unread, where('NOT seen')
end
