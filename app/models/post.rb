class Post < ApplicationRecord
  belongs_to :created_by, class_name: 'User', optional: true
end
