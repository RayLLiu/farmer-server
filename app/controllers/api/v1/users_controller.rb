module Api
  module V1
    class UsersController < ApplicationController
      skip_before_action :authenticate_user_from_token!, only: [:create]

      def create
        @user = User.new(user_params)

        if @user.save
          render json: {
            user: {
              id: @user.id,
              email: @user.email,
              authentication_token: @user.authentication_token
            }
          }, status: :created
        else
          render json: {
            errors: @user.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end
    end
  end
end 