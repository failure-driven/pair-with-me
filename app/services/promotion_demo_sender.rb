# frozen_string_literal: true

class PromotionDemoSender < ApplicationService
  attr_reader :promotion

  def initialize(promotion)
    @promotion = promotion
  end

  def call
    User.where("user_actions->'admin'->>'can_administer' = 'true'").each do |admin_user|
      PromotionMailer
        .with(promotion: promotion, user: admin_user, options: {demo: true})
        .new_promotion_email
        .deliver_later
    end
  end
end
