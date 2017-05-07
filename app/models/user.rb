class User < ApplicationRecord
	mount_uploader :avatar, AvatarUploader
	has_many :posts
	has_many :comments
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def fullname
		[firstName, lastName].join(' ').strip
  end

  acts_as_messageable

  def mailboxer_name
  	self.fullname
  end

  def mailboxer_email(object)
  	self.email
  end


end
