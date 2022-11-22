# frozen_string_literal: true

class CreatePairs < ActiveRecord::Migration[7.0]
  def change
    create_table :pairs, id: :uuid do |t|
      t.references :author, type: :uuid, index: true, null: false, foreign_key: {to_table: :users}
      t.references :co_author, type: :uuid, index: true, null: false, foreign_key: {to_table: :users}

      t.timestamps

      t.index %w[author_id co_author_id], unique: true
    end
  end
end
