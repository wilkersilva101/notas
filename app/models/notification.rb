class Notification < ApplicationRecord
  belongs_to :user

  after_initialize :set_default_read, if: :new_record?

  private

  def set_default_read
    self.read = false if self.read.nil?
  end
end
