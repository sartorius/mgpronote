class ClientController < ApplicationController
  before_action :mgs_user_is_partner
  before_action :get_partner_company_name
  before_action :verify_authenticity_token, :only => [:createbarcodeforclient]



  def createbarcodeforclient
    if params[:auth_token] == session[:_mgs_csrf_token].to_s then

      sql_query = "SELECT * FROM CLI_CRT_BC(" + @current_user.id.to_s + ", "+ params[:client_id] +", CAST(" + params[:partner_id] + " AS SMALLINT), TRIM('" + params[:order] + "'));"
      @resultSet = ActiveRecord::Base.connection.exec_query(sql_query)

      if @resultSet[0]['cli_crt_bc'].to_i > 0 then
        render plain: 'ok'
      elsif @resultSet[0]['cli_add_clt'].to_i == -2 then
        render plain: '-nar'
      end
    else
      #Do nothing
      render plain: 'ko'
    end


  end

  def newclient
    sql_query = "SELECT * FROM CLI_ADD_CLT(" + @current_user.id.to_s + ", "+ get_safe_pg_wq_ns(params[:email]) +");"
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

      load_clients
      render 'clientmng'
    end
    rescue Exception => exc
       flash.now[:danger] = "Une erreur est survenue #{exec.message}"
      render 'clientmng'
  end


  def clientmng
    load_clients
    @getAuthToken = mgs_form_authenticity_token.to_s


    render 'clientmng'
  end

  def signnewclient
    render 'signnewclient'
  end

  private

  def load_clients
=begin
    sql_query = "SELECT u.id AS id, u.name AS name, u.firstname AS firstname, u.email AS email, cpx.has_poc AS poc, to_char(cpx.create_date, 'DD/MM/YYYY') AS since "
	  sql_query += "FROM client_partner_xref cpx JOIN users u on cpx.client_id = u.id "
		sql_query += "and cpx.partner_id = " + @current_user.partner.to_s + " ORDER BY cpx.create_date DESC;"
=end

    sql_query = "SELECT u.id AS id, u.name AS name, u.firstname AS firstname, u.email AS email, cpx.has_poc AS poc, to_char(cpx.create_date, 'DD/MM/YYYY') AS since, bc.owner_id, count(1) AS totalbc "
    sql_query += " FROM client_partner_xref cpx JOIN users u on cpx.client_id = u.id AND cpx.partner_id = " + @current_user.partner.to_s + " "
    sql_query += " LEFT JOIN barcode bc on bc.owner_id = u.id "
    sql_query += " AND cpx.partner_id = " + @current_user.partner.to_s + " AND bc.partner_id = " + @current_user.partner.to_s + " "
    sql_query += " GROUP BY u.id, u.name, u.firstname, u.email, cpx.has_poc, bc.owner_id, cpx.create_date "
    sql_query += " ORDER BY cpx.create_date DESC;"

    begin

      @resultSet = ActiveRecord::Base.connection.exec_query(sql_query)
      @emptyResultSet = @resultSet.empty?
    end
    rescue Exception => exc
       flash.now[:danger] = "Une erreur est survenue #{exec.message}"
  end

end
