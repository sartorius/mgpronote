class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        forwarding_url = session[:forwarding_url]
        reset_session
        log_in user
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        #redirect_to forwarding_url || user
        redirect_to root_url
      else
        message  = "Votre compte n'est pas encore activé. "
        message += "Vérifiez vos emails pour l'email, nous y avons envoyé le lien d'activation."
        flash.now[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = "Le mot de passe et l'email ne correspondent pas."
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
