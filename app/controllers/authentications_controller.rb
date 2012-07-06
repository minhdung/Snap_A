class AuthenticationsController < ApplicationController
  def create
    omniauth = auth_hash
    token = omniauth['credentials']['token']
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])

    if authentication
      # User is already registered with application
      flash[:info] = 'Signed in successfully.'
      sign_in_and_redirect(authentication.user)
    elsif current_user
      # User is signed in but has not already authenticated with this social network
      current_user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'], :access_token => token)
      # current_user.apply_omniauth(omniauth)
      current_user.save
      flash[:info] = 'Authentication successful.'
      redirect_to root_path
    else
      # User is new to this application
      # user = User.new
      authentication = Authentication.new(:provider => omniauth['provider'], :uid => omniauth['uid'], :access_token => token)
      session[:authentication] = authentication
      # user.apply_omniauth(omniauth)

      redirect_to signup_path
    end
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    flash[:notice] = 'Successfully destroyed authentication.'
    redirect_to authentications_url
  end

  def auth_hash
    request.env['omniauth.auth']
  end

  private
  def sign_in_and_redirect(user)
    sign_in user
    unless current_user
      user_session = UserSession.new(User.find_by_single_access_token(user.single_access_token))
      user_session.save
    end
    redirect_to root_path
  end
end
