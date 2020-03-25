class User < ApplicationRecord
  belongs_to :role
  has_and_belongs_to_many :groups
end
