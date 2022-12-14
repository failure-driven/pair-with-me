# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
FindPairs.new.process("saramic", options: {"password" => "password"})
FindPairs.new.process("SelenaSmall", options: {"password" => "password"})
FindPairs.new.process("failure-driven")

# Make Selena and Michael admins
%w[
  SelenaSmall
  saramic
].each do |username|
  User.find_by(username: username).tap do |user|
    user.update!(
      user_actions: user.user_actions.merge(admin: {can_administer: true}),
      password: "password",
    )
  end
end
