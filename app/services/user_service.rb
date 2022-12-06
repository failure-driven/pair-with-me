# frozen_string_literal: true

require "find_pairs"

class UserService
  def self.find(username)
    @user = User.find_by(username: username) || User.where("username ilike ?", username)&.first
    return @user if @user

    github_api = FindPairs::GitHub::Api.new(nickname: username, cache_dir: nil)
    return nil if github_api.user_deets == {}

    @user = User.create!(
      username: github_api.user_deets["login"],
      uid: github_api.user_deets["id"],
      provider: "github",
      email: best_email(github_api.user_deets),
      name: github_api.user_deets["name"] || "nickname: #{github_api.user_deets["login"]}",
      password: SecureRandom.hex(32),
    )
  end

  def self.best_email(user_deets)
    user_deets["email"] ||
      format(
        "%<id>s+%<login>s@users.noreply.github.com}",
        id: user_deets["id"],
        login: user_deets["login"],
      )
  end
end
