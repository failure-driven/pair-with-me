# frozen_string_literal: true

class AddUserActionsToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :user_actions, :jsonb, default: {}, null: false
  end
end
