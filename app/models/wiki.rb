class Wiki < ActiveRecord::Base
  belongs_to :user
  has_many :collaborators
  has_many :users, through: :collaborators
  validates :title, length: { minimum: 5 }, presence: true
  validates :body, length: { minimum: 10 }, presence: true
  after_initialize { self.private ||= false}

  scope :visible_to, -> (user) { user.standard? ? where(private: false) : all }

  def make_public
    self.private = false
    save
  end

end
