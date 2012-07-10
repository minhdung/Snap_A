module SessionsHelper

  def sign_in(user)
    cookies.permanent[:persistence_token] = user.persistence_token
    self.current_user = user
  end

  def signed_in?
    !current_user.nil?
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= User.find_by_persistence_token(cookies[:persistence_token])
  end

  def current_user?(user)
    user == current_user
  end

  def signed_in_user
    unless signed_in?
      store_location
      redirect_to signin_path, notice: "Please sign in."
    end
  end

  def not_signed_in_user
    if signed_in?
      store_location
      flash[:info] = "Please sign out to use this feature."
      redirect_to root_path
    end
  end

  def signed_in_facebook
    unless facebook?(current_user)
      store_location
      redirect_to find_friends_path, notice: "Please sign in Facebook."
    end
  end

  def signed_in_twitter
    unless twitter?(current_user)
      store_location
      redirect_to "#", notice: "Please sign in Twitter."
    end
  end

  def sign_out
    self.current_user = nil
    cookies.delete(:persistence_token)
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def facebook?(user)
    !user.authentications.find_by_provider("facebook").nil?
  end

  def twitter?(user)
    !user.authentications.find_by_provider("twitter").nil?
  end
end
