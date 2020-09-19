class MentorSerializer < ActiveModel::Serializer
  attributes :id

  has_many :mentees
  has_one :user
end
