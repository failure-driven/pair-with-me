# frozen_string_literal: true

class Pair < ApplicationRecord
  belongs_to :author, class_name: "User"
  belongs_to :co_author, class_name: "User"
end
