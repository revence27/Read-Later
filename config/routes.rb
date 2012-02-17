Readlater::Application.routes.draw do
  root :to => 'readlater#index', :as => 'home'
  match 'blog/:id', :to => 'readlater#blog', :as => 'blog'
  match 'article/:blog/:id', :to => 'readlater#article', :as => 'article'
  match 'read/:blog/:id', :to => 'readlater#read', :as => 'read_post', :via => :post
end
