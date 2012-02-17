require 'open-uri'
require 'hpricot'

unless ENV['ATOM_FEED'] then
  $stderr.puts %[User ATOM_FEED to point at the feed.]
  exit 1
end

open(ENV['ATOM_FEED']) do |fch|
  doc   = Hpricot::XML(fch)
  blog  = SavedBlog.new
  blog.name = (doc / 'feed/title').first.inner_html rescue (doc / 'title').first.inner_html
  blog.by   = (doc / 'feed/author/name').first.inner_html
  blog.save
  (doc / 'feed/entry').reverse.each do |entry|
    post  = SavedPost.new
    post.title  = (entry / 'title').inner_html
    post.html   = (entry / 'content').inner_html
    post.when   = Time.mktime(*(entry / 'published').inner_html.split('.').first.split(/\D/))
    post.seen   = false
    post.picture        = (entry / 'gd:image').first['src']
    post.original       = (entry / 'link').select {|x| x['rel'] == 'alternate' and x['type'] == 'text/html'}.first['href']
    post.saved_blog_id  = blog.id
    post.save
    $stdout.write((('(%s) %s' % [post.when.strftime('%Y/%m/%d'), post.title.chomp]) + ' ... ' + (' ' * 80))[0, 79])
    $stdout.write "\r"
    $stdout.flush
  end
  $stdout.puts
end
