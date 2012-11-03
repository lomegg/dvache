# coding: utf-8

require 'rubygems'
require 'bundler'

Bundler.require

set :public_folder, File.dirname(__FILE__) + '/static'

Mongoid.load! './mongoid.yml', :development

class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  field :text, type: String
  field :image, type: String

  default_scope desc(:created_at)
  scope :empty_posts, where(text: "", image: nil)

  validate :ok

  def ok
    errors.add(:nooo, "Text and image are both empty!") if text.empty? && image.nil?
  end
end

Post.all.empty_posts.delete_all

get '/' do
  @posts = Post.all

  haml :index
end

post '/' do
  @text = RedCloth.new(params['text']).to_html

  if (failname = params['failname']) && failname[:type] == 'image/jpeg'
    src = failname[:tempfile].path
    dst = "#{Time.now.to_i}.jpg"
    FileUtils.cp(src, "#{settings.public_folder}/#{dst}")
  end

  @post = Post.create(text: @text, image: dst)

  redirect '/'
end

get '/post/:num' do |n|
  post = Post.find(n)
  haml :post, locals: {post: post}
end

__END__
@@ layout
%html
  %head
    %link{href: "http://twitter.github.com/bootstrap/assets/css/bootstrap.css", rel: "stylesheet"}
    %title Недвач совсем

    :css
      @import url(http://fonts.googleapis.com/css?family=PT+Sans+Narrow:400,700&subset=latin,cyrillic);
      body, p, h1, h2, h3, h4, h5, h6 {
        font-family: 'PT Sans Narrow', 'Helvetica Neue', 'Arial', sans-serif;
      }

      .thumbnail.post img {
        -ms-transform:rotate(2deg); /* IE 9 */
        -moz-transform:rotate(2deg); /* Firefox */
        -webkit-transform:rotate(2deg); /* Safari and Chrome */
        -o-transform:rotate(2deg); /* Opera */
        transform:rotate(2deg);
      }
      
      .thumbnail.post img {
        box-shadow:2px 2px 3px #000;
      }
    
  %body
    .container
      .row
        .span12
          %h1
            %a{href: '/'}
              Недвач
              %small Всего постов: #{Post.count}

        .span5
          = erb :form
        .span7
          = yield
          %h6
            using
            %a{href: "http://en.wikipedia.org/wiki/Textile_%28markup_language%29"} textile

@@ index
- @posts.each do |post|
  = haml :post, locals: {post: post}

@@ form
<form action="" method=post enctype="multipart/form-data" class="well form-inline">
  <input type=file accept="image/jpeg" name=failname class="span6"><br/><br/>
  <textarea name=text class="span4" placeholder="Выразите свои мысли, чувства, вот это все. Еще можно картинку прикрепить!" rows=10></textarea><br/><br/>
  <input type=submit class="btn btn-success btn-large" value="Сообщить">
</form>

@@ post
%ul.thumbnails
  %li.span7
    .thumbnail.post
      - if post.image
        %img{src: "/#{post.image}"}

      .caption
        %h5
          %a{href: "post/#{post.id}"}= post.created_at
        - if post.text
          %p= post.text

  
  
