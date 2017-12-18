class UsersController < ApplicationController
  skip_before_action :authorize, only: [:new, :create]
  before_action :new_user_only, only: [:new, :create] 
  before_action :set_user, only: [:index, :edit, :update, :destroy]

  def index
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        # MessagingService.produce_user(@user)
        GopayService.register_gopay(@user)
        format.html { redirect_to login_path, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to user_path, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_user
      @user = @current_user.decorate
    end

    def user_params
      params.require(:user).permit(:email, :phone, :first_name, :last_name, :password, :password_confirmation)
    end

    def new_user_only
      if session[:gojek_user_id]
        redirect_to index_path, notice: 'Please logout first'
      end
    end
end
