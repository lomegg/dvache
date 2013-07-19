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


  slim :index
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
  slim :post, locals: {post: post}
end

#get '/hello/:name' do
  # matches "GET /hello/foo" and "GET /hello/bar"
  # params[:name] is 'foo' or 'bar'
#  "Hello #{params[:name]}!"
#end






__END__

  
  
