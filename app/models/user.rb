class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :username, uniqueness: true, allow_nil: true

  has_many :posts, dependent: :destroy
  has_many :notifications, dependent: :destroy


  after_initialize :set_default_role, if: :new_record?

  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "email", "id", "updated_at", "username" ]
  end

  def admin?
    has_role?(:admin)
  end

  private

  def set_default_role
    self.add_role(:basic) if self.roles.blank?
  end
end
