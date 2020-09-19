class UsersController < ApplicationController
  before_action :authenticate_user, only: %i[show index]
  before_action :set_user, only: %i[show]
  before_action :authorize_user, only: %i[show]

  # GET /users
  def index
    if is_master == true
      @users = User.all
      return render(json: @users)
    else
      return render(json: { message: 'You are not master' }, status: :unauthorized)
    end
  end

  # POST /users
  def create
    @user = User.find_by(email: user_params[:email])
    
    if @user.blank?
      @user = User.create!(email: user_params[:email])

      @user.first_name = user_params[:first_name]
      @user.last_name = user_params[:last_name]
      @user.bio = user_params[:bio]
      @user.password = user_params[:password]
      @user.password_confirmation = user_params[:password]

      if @user.save

        return render(json: @user)
      else
        return render(json: @user.errors)
      end
    else
      return render(json: { message: "User w email already exists" }, status: 404)
    end
  end

  
  # POST /users/signin
  def signin
    @user = User.find_by(email: user_params[:email])
    return render(json: { message: "No user found" }) if @user.blank?

    return render(json: { message: 'Incorrect password', status: :unauthorized }, status: :unauthorized) if @user.authenticate(user_params[:password]) == false
    
    refresh_token_id = SecureRandom.uuid
    @user.update(refresh_token_id: refresh_token_id)

    user_is_master = @user.email == 'paulazhu@college.harvard.edu'

    render(json: {
      message: 'Logged in!',
      access_token: encode_access_token({ user_id: @user.id }),
      refresh_token: encode_refresh_token({ user_id: @user.id, id: refresh_token_id }),
      user: @user.as_json(except: [:password_digest, :refresh_token_id]),
      is_master: user_is_master,
      }, status: :ok)
  end

  # GET /users/:id
  def show
    return render(json: @user)
  end

  private

  def user_params
    params.permit(:last_name, :bio, :first_name, :email, \
      :password, :password_confirmation)
  end

  def set_user
    @user = User.find(params[:id])
  end

  def authorize_user
    render(json: { errors: 'Not the correct user!' }, status: :unauthorized) if (current_user != @user && !is_master)
  end

end
