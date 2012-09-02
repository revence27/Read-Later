require 'open-uri'
require 'hpricot'
require 'pathname'

class ReadlaterController < ApplicationController
  def index
    @blogs  = SavedBlog.order 'name ASC'
  end

  def blog
    @blog   = SavedBlog.find_by_id request[:id]
    @posts  = @blog.saved_posts.unread.order '"when" ASC'
    @read   = @blog.saved_posts.where(:seen => true).order '"when" DESC'
  end

  def article
    @blog = SavedBlog.find_by_id request[:blog]
    @post = SavedPost.find_by_id request[:id]
  end

  def read
    @blog = SavedBlog.find_by_id request[:blog]
    @post = @blog.saved_posts.unread.find_by_id(request[:id])
    if @post then
      @post.seen = true
      @post.save
    end
    redirect_to blog_path(:id => @blog.id)
  end

  def image
    @blog = SavedBlog.find_by_id request[:blog]
    @post = SavedPost.find_by_id request[:id]
    @img  = SavedImage.find_by_id request[:image]
    response.headers['Content-Type'] = @img.content_type
    render :text => @img.resource_b64.unpack('m').first
  end

  def fetch
    feed  = request[:feed]
    return unless feed and feed.length > 7
    source  = URI.parse feed
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
        post  = SavedPost.where(:title => title, :saved_blog_id  => blog.id, :when => Time.mktime(*(entry / 'published').inner_html.split('.').first.split(/\D/))).first
        unless post then
          post  = SavedPost.create :title  => title, :saved_blog_id  => blog.id, :seen => false
        end
        post.title    = %[##{post.id}] unless post.title.length > 0
        post.when     = Time.mktime(*(entry / 'published').inner_html.split('.').first.split(/\D/))
        post.picture  = (entry / 'gd:image').first['src']
        post.original = (entry / 'link').select {|x| x['rel'] == 'alternate' and x['type'] == 'text/html'}.first['href']
        tracker = ('(%s) %s' % [post.when.strftime('%Y/%m/%d'), post.title.chomp])
        $stderr.write((tracker + ' ... ' + (' ' * 80))[0, 79]) if $stderr.tty?
        post.title    = (entry / 'title').inner_html
        post.html     =
          begin
            rez = ''
            cnd = (entry / 'content')
            txt = if cnd.empty? then (entry / 'summary') else cnd end.inner_html
            reg = /src=("|'|&quot;|&apos;)([^"'&]+)("|'|&apos;|&quot;)/
            mtc = txt.match reg
            while mtc
              pth = URI.parse(mtc[2])
              if pth.scheme == 'data' then
                ctp, dat = pth.opaque.split(';', 2)
                pthid    = Digest::SHA1.new << pth.opaque
                img = SavedImage.create :saved_post_id => post.id, :original => pthid.to_s, :suggested_name => pthid.to_s, :content_type => ctp, :resource_b64 => dat.split('base64,', 2).last
                $stderr.write "\r" if $stderr.tty?
                $stderr.flush if $stderr.tty?
                $stderr.write((tracker + " [recorded an embedded #{ctp}] ... " + (' ' * 80))[0, 79]) if $stderr.tty?
                $stderr.flush if $stderr.tty?
              else
                pn  = Pathname.new pth.path
                nom = pn.basename.to_s
                unless pth.absolute then
                  pth.host    = source.host
                  pth.scheme  = source.scheme
                end
                # img = SavedImage.where(:saved_post_id  => post.id, :suggested_name => nom.to_s, :original => pth.to_s).first
                img = SavedImage.where(:original => pth.to_s).first
                $stderr.write "\r" if $stderr.tty?
                $stderr.flush if $stderr.tty?
                unless img then
                  $stderr.write((tracker + " [fetching #{nom}] ... " + (' ' * 80))[0, 79]) if $stderr.tty?
                  $stderr.flush if $stderr.tty?
                  ctp, dat  =
                    begin
                      open pth.to_s do |fch|
                        [fch.content_type, fch.read]
                      end
                    rescue Exception => e
                      ['application/octet-stream', pth.to_s]
                    end
                  img = SavedImage.create :saved_post_id => post.id, :original => pth.to_s, :suggested_name => nom.to_s, :content_type => ctp, :resource_b64 => [dat].pack('m')
                  $stderr.write "\r" if $stderr.tty?
                  $stderr.flush if $stderr.tty?
                  $stderr.write((tracker + " [fetched #{nom}] ... " + (' ' * 80))[0, 79]) if $stderr.tty?
                  $stderr.flush if $stderr.tty?
                else
                  $stderr.write((tracker + " [already fetched #{nom}] ... " + (' ' * 80))[0, 79]) if $stderr.tty?
                  $stderr.flush if $stderr.tty?
                end
              end
              # rez = %[#{rez}#{mtc.pre_match}src=#{mtc[1]}/image/#{blog.id}/#{post.id}/#{img.id}#{mtc[3]}]
              rez = %[#{rez}#{mtc.pre_match}src=#{mtc[1]}#{image_path(:blog => blog.id, :id => post.id, :image => img.id)}#{mtc[3]}]
              txt = mtc.post_match
              mtc = txt.match reg
              $stderr.write "\r" if $stderr.tty?
              $stderr.flush if $stderr.tty?
            end
            rez + txt
          end
        post.save
        blogid, postid = (entry / 'id').inner_html.split(':').last.split('.').map {|x| x.split('-').last}
        comsource = source.clone
        comsource.path  = %[/feeds/%s/comments/default] % [postid]
        comsource.query = %[max-results=100000]
        open(comsource.to_s) do |comfile|
          hp  = Hpricot::XML(comfile.read)
          cc  = 0
          (hp / 'feed/entry').each do |centry|
            comid = (centry / 'link').select {|x| x['rel'] == 'self' }.first['href']
            unless SavedComment.find_by_commentid(comid) then
              cmt = SavedComment.new
              cmt.author        = (centry / 'author/name').first.inner_html
              $stderr.write "\r" if $stderr.tty?
              $stderr.flush if $stderr.tty?
              $stderr.write((tracker + " [saving comment ##{cc + 1} by #{cmt.author}] ... " + (' ' * 80))[0, 79]) if $stderr.tty?
              $stderr.flush if $stderr.tty?
              cmt.commentid     = comid
              cmt.author_url    = ((centry / 'author/uri').first.inner_html rescue '')
              cmt.published_at  = Time.mktime(* (centry / 'published').first.inner_html.split(/\D+/)[0 ... 7])
              cmt.content       = (centry / 'content').first
              cmt.content       = (centry / 'summary').first unless cmt.content
              cmt.content       = cmt.content.inner_html
              cmt.saved_post_id = post.id
              cmt.save
            end
            cc  = cc + 1
          end
          post.comment_count  = cc
          post.save
        end
        $stderr.write "\r" if $stderr.tty?
        $stderr.flush if $stderr.tty?
      end
      $stderr.puts if $stderr.tty?
    end
    redirect_to home_path
  end
end
