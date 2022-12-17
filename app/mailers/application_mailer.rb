# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: Rails.configuration.default_from_email
  layout "mailer"
end
