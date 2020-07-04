module SessionsHelper

  # Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id
  end

  # Remembers a user in a persistent session.
  def remember(user)
    user.remember
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # Returns the user corresponding to the remember token cookie.
  def current_user
    # DEBUG CHANGE
    puts '>>>> ' + session[:user_id].to_s
    puts '@current_user is nil >>>> ' + @current_user.nil?.to_s
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)

    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # Returns true if the given user is the current user.
  def current_user?(user)
    user == current_user
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end

  # Forgets a persistent session.
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # Logs out the current user.
  def log_out
    forget(current_user)
    reset_session
    @current_user = nil
  end

  # Stores the URL trying to be accessed.
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end

  # Define here specific MGS Access Rights

  def is_partner?
    !current_user.nil? and (@current_user.partner > 1)
  end

  # This methode copy paste the user controller
  # Confirms a logged-in user.
  def mgs_logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Connectez-vous s'il vous plaît"
      redirect_to login_url
    end
  end

  # Confirms user is partner.
  def mgs_user_is_partner
    mgs_logged_in_user

    # We need to test logging else it test the user
    if logged_in?
      # Partner are greater than 1
      unless @current_user.partner > 1
        redirect_to accessrightserror_path
      end
    end
  end

  def mgs_form_authenticity_token
    session[:_mgs_csrf_token] = SecureRandom.base64(32)
  end

end
