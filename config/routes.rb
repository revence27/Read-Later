Readlater::Application.routes.draw do
  root :to => 'readlater#index', :as => 'home'
  match 'blog/:id', :to => 'readlater#blog', :as => 'blog'
  match 'article/:blog/:id', :to => 'readlater#article', :as => 'article'
  match 'image/:blog/:id/:image', :to => 'readlater#image', :as => 'image'
  match 'fetch', :to => 'readlater#fetch', :as => 'fetch'
  match 'read/:blog/:id', :to => 'readlater#read', :as => 'read_post', :via => :post

  match 'delete_blog/:blog', :to => 'readlater#delete_blog', :as => 'delete_blog', :via => :post
  match 'delete_entries/:blog', :to => 'readlater#delete_entries', :as => 'delete_entries', :via => :post
end
