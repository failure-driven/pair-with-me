# frozen_string_literal: true

class Promotion < ApplicationRecord
  enum status: {draft: 0, sent: 1}
end
