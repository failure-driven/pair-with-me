# frozen_string_literal: true

class PromotionMailer < ApplicationMailer
  def new_promotion_email
    @user = params[:user]
    @promotion = params[:promotion]
    @options = params[:options]

    subject = "#{@options[:demo] ? "[TEST] " : ""}#{@promotion.title}"
    mail(to: @user.email, subject: subject)
  end
end
