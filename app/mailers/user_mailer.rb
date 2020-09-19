class UserMailer < ApplicationMailer
  default from: ENV['GMAIL_USERNAME']
 
  def welcome_email(email_address)
    @url  = 'http://t4sg.herokuapp.com/verify'
    mail(to: email_address, subject: 'Welcome!')
  end
end
