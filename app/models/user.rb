# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable,
    :trackable,
    :omniauthable, omniauth_providers: %i[github]

  def self.from_omniauth(auth)
    user = where(arel_table[:email].eq(auth.info.email).or(
      User.arel_table[:provider].eq(auth.provider).and(User.arel_table[:uid].eq(auth.uid)),
    )).first_or_create do |user|
      user.email = auth.info.email
      user.provider = auth.provider
      user.uid = auth.uid
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name # assuming the user model has a name
      user.username = auth.info.nickname if auth.provider == "github"
      user.username ||= auth.info.email[/^[^@]+@/].gsub(/[^a-z^A-Z\-_0-9]/, "")
      # user.image = auth.info.image # assuming the user model has an image
      # If you are using confirmable and the provider(s) you use validate emails,
      # uncomment the line below to skip the confirmation emails.
      # user.skip_confirmation!
    end
    unless user.provider
      user.provider = auth.provider
      user.uid = auth.uid
    end
    user
  end
end
