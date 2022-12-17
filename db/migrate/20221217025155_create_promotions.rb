# frozen_string_literal: true

class CreatePromotions < ActiveRecord::Migration[7.0]
  def change
    create_table :promotions, id: :uuid do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
