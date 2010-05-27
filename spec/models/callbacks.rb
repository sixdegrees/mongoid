class Artist
  include Mongoid::Document
  field :name
  embeds_many :songs

  before_create :before_create_stub
  after_create :create_songs

  protected
  def before_create_stub
    true
  end

  def create_songs
    2.times { |n| songs.create!(:title => "#{n}") }
  end
end

class Song
  include Mongoid::Document
  field :title
  embedded_in :artist, :inverse_of => :songs
end

class ValidationCallback
  include Mongoid::Document
  field :history, :type => Array, :default => []
  validate do
    self.history << :validate
  end

  before_validation { self.history << :before_validation }
  after_validation { self.history << :after_validation }
end
