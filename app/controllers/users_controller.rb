class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy]

  def index
    unless @current_user&.admin?
      render json: { error: 'Forbidden' }, status: :forbidden and return
    end
    @users = User.all
    respond_to do |format|
      format.html
      format.json { render json: @users.as_json(except: [:password_digest]) }
    end
  end

  def show
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to @user, notice: 'User was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to users_url, notice: 'User was successfully destroyed.'
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :encrypted_password, :name)
    end
end
