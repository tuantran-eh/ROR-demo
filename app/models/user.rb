class User < ApplicationRecord
  # Add validations and associations as needed
  # Example: has_many :posts

  enum :role, { user: 'user', admin: 'admin' }

  has_secure_password
end
