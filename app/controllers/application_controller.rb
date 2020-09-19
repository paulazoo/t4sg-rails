class ApplicationController < ActionController::API
  include Response
  include ExceptionHandler
  # include Knock::Authenticable

  private

  def encode_access_token(payload={})
    payload[:typ] = "access"
    payload[:exp] = 6.hours.from_now.to_i # Long access token until refresh token works
    payload[:iat] = Time.now.to_i
    JWT.encode(payload, ENV['SECRET_KEY_BASE'])
  end

  def encode_refresh_token(payload={})
    payload[:typ] = "refresh"
    payload[:exp] = 24.hours.from_now.to_i
    payload[:iat] = Time.now.to_i
    JWT.encode(payload, ENV['SECRET_KEY_BASE'])
  end

  def auth_header
    request.headers['Authorization']
  end

  def decoded_token
    if auth_header
      token = auth_header.split(' ')[1]
      begin
        JWT.decode(token, ENV['SECRET_KEY_BASE'])
      rescue JWT::DecodeError
        []
      end
    end
  end

  def current_user
    decoded_hash = decoded_token
    Rails.logger.info "Decoded Token"
    Rails.logger.info decoded_hash
    if decoded_hash && !decoded_hash.empty?
      user_id = decoded_hash[0]['user_id']
      @user = User.find(user_id)
    end
  end

  def logged_in
    !!current_user
  end

  def authenticate_user
    render(json: { message: 'Please login or refresh token' }, status: :ok) unless logged_in
  end

  def is_master
    (current_user.email == 'paulazhu@college.harvard.edu')
  end
end
