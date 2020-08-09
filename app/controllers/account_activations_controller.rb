class AccountActivationsController < ApplicationController

  def edit
    user = User.find_by(email: params[:email])

    if user.nil?
      flash[:danger] = "Cet email est introuvable."
      redirect_to root_url
    elsif user.activated?
      flash[:success] = "Bonne nouvelle, ce compte est déjà activé. Connectez-vous s'il vous plaît."
      redirect_to login_url
    elsif user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      flash[:success] = "Votre compte est activé !"
      redirect_to user
    else
      flash[:danger] = "Le lien d'activation est invalide."
      redirect_to root_url
    end
  end
end
