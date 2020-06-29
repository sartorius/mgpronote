class ClientController < ApplicationController
  before_action :mgs_user_is_partner
  before_action :get_partner_company_name


  def newclient
    sql_query = "SELECT * FROM CLI_ADD_CLT(" + @current_user.id.to_s + ", TRIM('"+ params[:email] +"'));"
    begin

      @resultSet = ActiveRecord::Base.connection.exec_query(sql_query)
      @emptyResultSet = @resultSet.empty?

      if @resultSet[0]['cli_add_clt'].to_s == '0' then
        message  = "L'utilisateur "+ params[:email] +" a été bien ajouté à votre liste de clients"
        flash.now[:success] = message
      elsif @resultSet[0]['cli_add_clt'].to_s == '1' then
        message  = "L'utilisateur "+ params[:email] +" n'existe pas. Assurez vous d'avoir le bon email. "
        message += "Demandez à votre client s'il a bien créé son compte que son compte est activé. "
        message += "Il reçoit son lien d'activation par email."
        flash.now[:danger] = message
      elsif @resultSet[0]['cli_add_clt'].to_s == '2' then
        message  = "L'utilisateur "+ params[:email] +" existe déja dans votre liste de clients. "
        flash.now[:warning] = message
      else
        message  = "L'utilisateur "+ params[:email] +" n'a pas été ajouté à votre liste de client. Une erreur DUH239 s'est produite. "
        message += "Nous sommes navrés pour la gêne occasionée."
        flash.now[:danger] = message
      end

      render 'clientmng'
    end
    rescue Exception => exc
       flash[:info] = "Une erreur est survenue #{exec.message}"
      render 'clientmng'
  end

  def clientmng
    render 'clientmng'
  end

  def signnewclient
    render 'signnewclient'
  end

end
