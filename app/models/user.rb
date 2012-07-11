# == Schema Information
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class User < ActiveRecord::Base
  include AuthenticationsHelper
  
  attr_accessible :email, :name, :password, :password_confirmation,:location,:gender
  has_secure_password

  before_save { |user| user.email = email.downcase }
  before_save :create_persistence_token

  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false}

  validates :password, presence: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true

  has_many :user_user_relationships, foreign_key: "follower_id",
  dependent: :destroy
  has_many :following_users, through: :user_user_relationships, source: :following

  has_many :reverse_user_user_relationships, foreign_key: "following_id",
  class_name:  "UserUserRelationship",
  dependent:   :destroy

  has_many :followers, through: :reverse_user_user_relationships, source: :follower

  has_many :user_box_follows, foreign_key: "user_id",
  dependent: :destroy

  has_many :following_boxes, through: :user_box_follows, source: :box

  # has_many :user_own_box_rel, foreign_key: "user",
  # class_name: "Boxes",
  # dependent: :destroy

  # has_many :owning_boxes, through: :user_own_box_rel, source: :id
  has_many :boxes, class_name: "Box"

  has_many :user_photo_actions, foreign_key: "user_id", 
  dependent: :destroy

  has_many :action_photos, through: :user_photo_actions, source: :photo

  has_many :authentications, dependent: :destroy

  def following?(other_user)
    user_user_relationships.find_by_following_id(other_user.id)
  end

  def follow!(other_user)
    if !following?(other_user)
      user_user_relationships.create!(following_id: other_user.id)
      Notification.create!(source_id: self.id, target_id: other_user.id,
       relation_type: "user_user_relationships")
      other_user.boxes.each do | box |
        follow_box!(box)
      end
    end
  end

  def unfollow!(other_user)
    if following?(other_user)
      user_user_relationships.find_by_following_id(other_user.id).destroy
      other_user.boxes.each do | box |
        unfollow_box(box)
      end
    end
  end


  def follow_box!(box)
    if !following_box?(box)
      user_box_follows.create!(box_id: box.id)
    end
  end

  def unfollow_box!(box)
    if following_box?(box)
      user_box_follows.find_by_box_id(box.id).destroy
    end
  end

  def following_box?(box)
    user_box_follows.find_by_box_id(box.id) != nil
  end

  def act_on_photo!(photo, action)
    unless right_action?(action)
      return false
    end
    if action == :like && liked_photo?(photo)
      return false
    end

    user_photo_actions.create!(photo_id: photo.id, action: action)
    Notification.create!(source_id: self.id, target_id: photo.box.owner.id, 
      relation_type: "user_photo_actions like #{photo.id}")

  end

  def un_act_on_photo!(photo, action)
    unless right_action?(action)
      return false
    end
    user_photo_actions.find_by_photo_id(photo.id).destroy
  end

  def liked_photo?(photo)
    rels = user_photo_actions.find_all_by_action(:like)
    rels.each do | rel |
      if rel.photo_id == photo.id
        return true
      end
    end
    false
  end

  def tweet(content)
    twitter = twitter(self)
    twitter.update(content + " clgt ")
  end

  def verify!
    self.verified = true
    self.save
  end

  def verify?
    self.verified
  end

  private

  def create_persistence_token
    self.persistence_token = SecureRandom.urlsafe_base64
  end

  def right_action?(action) 
    return action == :like || action == :repin
  end

  def unfollow_box(box)

    rel = user_box_follows.find_by_box_id(box.id)
    if rel != nil
      rel.destroy
    end
  end
end
