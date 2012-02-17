class SavedPost < ActiveRecord::Base
  belongs_to :saved_blog
  scope :unread, where('NOT seen')
end
