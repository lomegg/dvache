class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :chain

  field :text, type: String
  field :image, type: String

  default_scope asc(:created_at)

  validate :ok

  attr_accessor :counter

  def ok
    errors.add(:nooo, "Text and image are both empty!") if text.empty? && image.nil?
  end
end

class Chain
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :posts

  default_scope desc(:updated_at)


  def first_post
    self.posts.first
  end

 end