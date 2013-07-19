# coding: utf-8

require 'rubygems'
require 'bundler'


Bundler.require

set :public_folder, File.dirname(__FILE__) + '/static'

Mongoid.load! './mongoid.yml', :development

require './post.rb'

get '/' do
  @chains = Chain.all
  slim :index
end

post '/' do

  @text = RedCloth.new(params['text']).to_html

  if (failname = params['failname']) && failname[:type] == 'image/jpeg'
    src = failname[:tempfile].path
    dst = "#{Time.now.to_i}.jpg"
    FileUtils.cp(src, "#{settings.public_folder}/#{dst}")
  end

  @chain_id = params['chain_id'] || Chain.create.id
  @post = Post.create(text: @text, image: dst, chain_id:@chain_id)

  redirect "/chain/#{@chain_id}##{@post.id}"
end

get '/chain/:id' do |id|
  @chain=Chain.find(id)
  slim :chain
end
  
helpers do
  def post_settings
    if defined? @chain
      "<input type='hidden' name='chain_id' value='#{@chain.id}'>"
    end
  end
end