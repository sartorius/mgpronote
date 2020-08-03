class UserMailer < ApplicationMailer

  def account_activation(user)
    @user = user
    mail to: user.email, subject: "Compte activation"
  end

  def account_activation_by_client(user, pwd, partner_name, add_info)
    @user = user
    @pwd = pwd
    @partner_name = partner_name[0][1].to_s
    @add_info = add_info.to_s
    mail to: user.email, subject: "Compte activation créé par " + @partner_name
  end

  def password_reset(user)
    @user = user
    mail to: user.email, subject: "Changement de mot de passe"
  end
end
