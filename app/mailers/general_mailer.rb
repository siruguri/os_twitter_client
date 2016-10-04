class GeneralMailer < ActionMailer::Base
  default from: 'siruguri@gmail.com'
  
  def notification_email(opts={})
    opts = opts.with_indifferent_access

    # This class is defined in email_controller.rb
    @payload = opts[:payload] || ''

    opts[:to] ||= 'siruguri@gmail.com'
    
    subject = 'webhook receipt notice: siruguri -> siruguri'
    mail to: opts[:to], subject: subject
  end
end
