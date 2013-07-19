class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :chain


  field :text, type: String
  field :image, type: String

  default_scope desc(:created_at)

  validate :ok

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
    posts.first
  end


end