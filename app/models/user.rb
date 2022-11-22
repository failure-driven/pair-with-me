# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable,
    :trackable,
    :omniauthable, omniauth_providers: %i[github]

  validates :name, presence: true
  validates :username, uniqueness: {}

  has_many :authored_pairs,
    foreign_key: :author_id,
    class_name: "Pair",
    dependent: :nullify,
    inverse_of: :author
  has_many :co_authored_pairs,
    foreign_key: :co_author_id,
    class_name: "Pair",
    dependent: :nullify,
    inverse_of: :co_author

  def pairs
    Pair.where(author_id: id).or(
      Pair.where(co_author_id: id),
    )
      .includes(:author, :co_author)
      .map do |pair|
        (pair.author_id == id) ? pair.co_author : pair.author
      end
  end

  def status
    /\d+_no_email@example\.com/.match?(email) ? "un-claimed" : "claimed"
  end

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
    # These need to be updated if the user is being claimed
    user.email = auth.info.email
    user.name = auth.info.name
    user.save # don't throw error with save! as this is dealt with in user.persisted? in omniauth_callbacks_controller.rb
    unless user.provider
      user.provider = auth.provider
      user.uid = auth.uid
    end
    user
  end
end
