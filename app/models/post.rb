class Post < ApplicationRecord
  belongs_to :user

  validates :titulo, presence: true

  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "descricao", "id", "titulo", "updated_at", "user_id" ]
  end
end
