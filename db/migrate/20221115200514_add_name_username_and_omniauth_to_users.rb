# frozen_string_literal: true

class AddNameUsernameAndOmniauthToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :name, :string, default: "", null: false # rubocop:disable Rails/BulkChangeTable
    add_column :users, :username, :string, default: "", null: false
    add_column :users, :provider, :string
    add_column :users, :uid, :string
  end
end
