class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy
  before_action :mgs_logged_in_user,   only: [:show, :editpwd]
  before_action :get_partner_company_name,   only: [:show]

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    is_created_by_partner = false;
    generated_pwd = 'na';
    @user = User.new(user_params)

    # Lets check that password are empty or not to see if created automatically
    if @user.password.to_s == '00000000' then
      # We can consider that this user has been created automatically
      # We need to do a specific activation email !
      is_created_by_partner = true;
      generated_pwd = 'MGS' + rand(10000..50000).to_s
      @user.password = generated_pwd
      @user.password_confirmation = generated_pwd
    end


    if @user.save
      if is_created_by_partner then
        # This will hydrate current_user
        mgs_user_is_partner
        # Now we need to add the client to the partner
        # Use the private method to assign client here
        attach_client_to_partner(@current_user.id.to_s, @user.email)

        email_additionnal_html = ClientController.get_email_text_after_attach_client_to_partner(@current_user.partner.to_s, get_safe_pg_wq_ns(@user.email))
        @user.send_activation_email_created_by_partner(generated_pwd, get_partner_company_name, email_additionnal_html)


        flash[:success] = "Le client " + @user.email.to_s + " a été créé et attaché à votre liste avec succès. Un email lui a été envoyé."
        redirect_to '/clientmng'
      else
        @user.send_activation_email
        flash.now[:success] = "S'il vous plaît, vérifiez vos emails pour activer votre compte. Nous y avions un mail d'activation. Si vous ne le trouvez pas, vérifiez votre dossier spam."
        render 'static_pages/home'
      end

    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def editpwd
    @user = @current_user
    render 'editpwd'
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash.now[:success] = "Profil mis à jour"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash.now[:success] = "Compte supprimé"
    redirect_to users_url
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation, :firstname, :phone, :partner)
    end

    # Before filters

    # Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
        store_location
        flash.now[:danger] = "Connectez-vous s'il vous plaît"
        redirect_to login_url
      end
    end

    # Confirms the correct user.
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    # Confirms an admin user.
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end

    def attach_client_to_partner(current_user_id, email)
      sql_query = "SELECT * FROM CLI_ADD_CLT(" + current_user_id.to_s + ", "+ get_safe_pg_wq_ns(email) +");"
      ActiveRecord::Base.connection.exec_query(sql_query)

    end
end
