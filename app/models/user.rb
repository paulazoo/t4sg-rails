class User < ApplicationRecord
  has_secure_password :password, validations: false # use bcrypt

  validates :email, uniqueness: true, presence: true

end
