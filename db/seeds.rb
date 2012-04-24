require 'open-uri'
require 'hpricot'
require 'pathname'

unless ENV['ATOM_FEED'] then
  $stderr.puts %[User ATOM_FEED to point at the feed.]
  exit 1
end

source  = URI.parse(ENV['ATOM_FEED'])

open(source.to_s) do |fch|
  doc   = Hpricot::XML(fch)
  title = (doc / 'feed/title').first.inner_html rescue (doc / 'title').first.inner_html
  blog  = SavedBlog.find_by_name title
  unless blog then
    blog  = SavedBlog.new :name => title
  end
  blog.name = (doc / 'feed/title').first.inner_html rescue (doc / 'title').first.inner_html
  blog.by   = (doc / 'feed/author/name').first.inner_html
  blog.save
  (doc / 'feed/entry').reverse.each do |entry|
    title = (entry / 'title').inner_html
    post  = SavedPost.where(:title => title, :saved_blog_id  => blog.id).first
    unless post then
      post  = SavedPost.create :title  => title, :saved_blog_id  => blog.id, :seen => false
    end
    tracker = ('(%s) %s' % [post.when.strftime('%Y/%m/%d'), post.title.chomp])
    $stdout.write((tracker + ' ... ' + (' ' * 80))[0, 79])
    post.title    = (entry / 'title').inner_html
    post.html     =
      begin
        rez = ''
        txt = (entry / 'content').inner_html
        reg = /src=("|'|&quot;|&apos;)([^"'&]+)("|'|&apos;|&quot;)/
        mtc = txt.match reg
        while mtc
          pth = URI.parse(mtc[2])
          pn  = Pathname.new pth.path
          nom = pn.basename.to_s
          unless pth.absolute then
            pth.host    = source.host
            pth.scheme  = source.scheme
          end
          # img = SavedImage.where(:saved_post_id  => post.id, :suggested_name => nom.to_s, :original => pth.to_s).first
          img = SavedImage.where(:original => pth.to_s).first
          $stdout.write "\r"
          $stdout.flush
          unless img then
            $stdout.write((tracker + " [fetching #{nom}] ... " + (' ' * 80))[0, 79])
            $stdout.flush
            ctp, dat  = open pth.to_s do |fch|
              [fch.content_type, fch.read]
            end
            img = SavedImage.create :saved_post_id => post.id, :original => pth.to_s, :suggested_name => nom.to_s, :content_type => ctp, :resource_b64 => [dat].pack('m')
            $stdout.write "\r"
            $stdout.flush
            $stdout.write((tracker + " [fetched #{nom}] ... " + (' ' * 80))[0, 79])
            $stdout.flush
          else
            $stdout.write((tracker + " [already fetched #{nom}] ... " + (' ' * 80))[0, 79])
            $stdout.flush
          end
          rez = %[#{rez}#{mtc.pre_match}src=#{mtc[1]}/image/#{blog.id}/#{post.id}/#{img.id}#{mtc[3]}]
          txt = mtc.post_match
          mtc = txt.match reg
          $stdout.write "\r"
          $stdout.flush
        end
        rez + txt
      end
    post.when     = Time.mktime(*(entry / 'published').inner_html.split('.').first.split(/\D/))
    post.picture  = (entry / 'gd:image').first['src']
    post.original = (entry / 'link').select {|x| x['rel'] == 'alternate' and x['type'] == 'text/html'}.first['href']
    post.save
    $stdout.write "\r"
    $stdout.flush
  end
  $stdout.puts
end
