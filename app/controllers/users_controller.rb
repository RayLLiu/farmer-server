class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy ]

  # GET /users or /users.json
  def index
    @users = User.all
  end

  # GET /users/1 or /users/1.json
  def show
  end

  # GET /users/new
  def new
    puts "test==================s"
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users or /users.json
  def create
    Rails.logger.info "try to register user"
    @user = User.new(user_params)
    
    if user.save
      if turbo_native_app?
        user.remember_me = true
        sign_in user
        render json: {
          token: user.api_tokens.first_or_create(name: ApiToken::APP_NAME).token
        }
      else
        api_token = user.api_tokens.first_or_create(name: ApiToken::DEFAULT_NAME)
        render json: {
          user: {
            id: user.id,
            email: user.email,
            first_name: user.first_name,
            last_name: user.last_name,
            time_zone: user.time_zone,
            api_tokens: [{
              id: api_token.id,
              name: api_token.name,
              token: api_token.token
            }]
          },
          account: user.accounts.first.as_json(only: [:id, :name, :owner_id, :personal]).merge(
            address: user.accounts.first.address.as_json
          ),
          user_accounts: user.account_users.includes(:account).map do |account_user|
            account_data = account_user.account.as_json(only: [:id, :name, :owner_id, :personal])

            # Get the user's roles for the account
            roles = account_user.roles

            # Merge the roles into the account data
            account_data.merge(roles: roles)
          end
        }
      end
    else
      render json: {
        errors: user.errors,
        error: user.errors.full_messages.to_sentence
      }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: "User was successfully updated." }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    @user.destroy!

    respond_to do |format|
      format.html { redirect_to users_path, status: :see_other, notice: "User was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.fetch(:user, {})
    end
end
