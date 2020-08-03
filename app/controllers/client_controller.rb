class ClientController < ApplicationController
  before_action :mgs_user_is_partner
  before_action :get_partner_company_name
  before_action :verify_authenticity_token, :only => [:createbarcodeforclient]


  def revokmngbarcodeforclient
    if params[:auth_token] == session[:_mgs_csrf_token].to_s then

      # puts 'We have retrieve email: ' + params[:client_email].to_s

      sql_query = "UPDATE client_partner_xref SET has_poc = " + params[:order] + " WHERE client_id = "+ params[:client_id] +" AND partner_id = " + @current_user.partner.to_s + " ;"

      @resultSet = ActiveRecord::Base.connection.exec_query(sql_query)

      render plain: 'ok'
    else
      #Do nothing
      render plain: 'ko'
    end

  end

  def createbarcodeforclient
    if params[:auth_token] == session[:_mgs_csrf_token].to_s then

      puts 'We have retrieve email: ' + params[:client_email].to_s

      sql_query = "SELECT * FROM CLI_CRT_BC(" + @current_user.id.to_s + ", "+ params[:client_id] +", CAST(" + params[:partner_id] + " AS SMALLINT), TRIM('" + params[:order] + "'));"
      @resultSet = ActiveRecord::Base.connection.exec_query(sql_query)

      if @resultSet[0]['cli_crt_bc'].to_i > 0 then
        render plain: 'ok'
      elsif @resultSet[0]['cli_crt_bc'].to_i == -2 then
        render plain: '-nar'
      else
        render plain: 'unk'
      end

    else
      #Do nothing
      render plain: 'ko'
    end


  end

  def newclient
    need_to_create_client = false;

    sql_query = "SELECT * FROM CLI_ADD_CLT(" + @current_user.id.to_s + ", "+ get_safe_pg_wq_ns(params[:email]) +");"
    begin

      @resultSet = ActiveRecord::Base.connection.exec_query(sql_query)
      @emptyResultSet = @resultSet.empty?

      if (@resultSet[0]['cli_add_clt'].to_s == '0') || (@resultSet[0]['cli_add_clt'].to_s == '4')
        then
        message  = "L'utilisateur "+ params[:email] +" a été bien ajouté à votre liste de clients"
        if (@resultSet[0]['cli_add_clt'].to_s == '4') then
          message += " Par contre, ce compte n'est pas encore activé. Votre client doit vérifier ses mails pour l'activer et profiter de tous les avantages de MG Suivi."
          flash.now[:warning] = message
        else
          flash.now[:success] = message
        end

        email_msg = ClientController.get_email_text_after_attach_client_to_partner(@current_user.partner, get_safe_pg_wq_ns(params[:email]))

        puts "email msg: " + email_msg
        # Notify the client
        sendPlainEmail(params[:email],
                        'votre compte a été ajouté par un partenaire transporteur',
                        'Félicitation ! Un partenaire de MG Suivi vous a ajouté dans sa liste de client. Vous pouvez dès à présent créer des suivis pour tracer vos achats que vous faites parvenir par ce transporteur. ' + email_msg)


      elsif @resultSet[0]['cli_add_clt'].to_s == '1' then
        message  = "L'utilisateur "+ params[:email] +" n'existe pas sur MG Suivi. Assurez vous d'avoir le bon email."
        flash.now[:warning] = message

        # Notify the client
        # We need to propose to create a new client
        need_to_create_client = true;

      elsif @resultSet[0]['cli_add_clt'].to_s == '2' then
        message  = "L'utilisateur "+ params[:email] +" existe déja dans votre liste de clients. "
        flash.now[:warning] = message
      else
        message  = "L'utilisateur "+ params[:email] +" n'a pas été ajouté à votre liste de client. Une erreur DUH239 s'est produite. "
        message += "Nous sommes navrés pour la gêne occasionée."
        flash.now[:danger] = message
      end


      if need_to_create_client then
        # We are in a case of account creation by the partner
        # The account will be created but not verified
        puts 'IN users/new_created_by_partner'

        #We create a new one empty
        @user = User.new
        @email_to_create = params[:email]
        @user.email = @email_to_create.to_s
        puts 'Here is the user to create : ' + @user.inspect

        render 'new_created_by_partner'
      else
        # The client exists and we attach it
        puts 'IN client manager'
        load_clients
        @getAuthToken = mgs_form_authenticity_token.to_s
        render 'clientmng'
      end

    end
    rescue Exception => exc
       flash.now[:danger] = "Une erreur est survenue #{exc.message}"
       render 'clientmng'
  end

  def self.get_email_text_after_attach_client_to_partner(partner_id, email)
    #We need to retrieve the client information and partner address to let the user know
    sql_query_mail_add_client = "SELECT u.firstname, u.client_ref, u.id, rp.delivery_addr, rp.pickup_addr FROM client_partner_xref cpx " +
                                      " JOIN users u ON u.id = cpx.client_id " +
                                      " JOIN ref_partner rp ON rp.id = cpx.partner_id " +
                                      " WHERE rp.id = " + partner_id.to_s +
                                      " AND u.email = " + email + ";"

    @resultSetAddClientNotif = ActiveRecord::Base.connection.exec_query(sql_query_mail_add_client)
    # xxx
    puts "Add Client: " + @resultSetAddClientNotif[0]['firstname'].to_s + ' - ' +
                          @resultSetAddClientNotif[0]['client_ref'].to_s + ' - ' +
                          @resultSetAddClientNotif[0]['id'].to_s + ' - ' +
                          @resultSetAddClientNotif[0]['delivery_addr'].to_s + ' - ' +
                          @resultSetAddClientNotif[0]['pickup_addr'].to_s

    # puts "Ref client: " + helpers.encode_client_ref(@resultSetAddClientNotif[0]['firstname'].to_s, @resultSetAddClientNotif[0]['id'].to_s, @resultSetAddClientNotif[0]['client_ref'].to_s)

    notif_client_ref = helpers.encode_client_ref(@resultSetAddClientNotif[0]['firstname'].to_s,
                                              @resultSetAddClientNotif[0]['id'].to_s,
                                              @resultSetAddClientNotif[0]['client_ref'].to_s)

    return "<br><br>Votre référence client est le " + notif_client_ref + ". " +
                " C'est une référence personnelle et elle ne doit pas être partagée. " +
                " Si vous décidez de faire livrer chez ce partenaire, vous devez faire livrer à cette adresse: <br><br>" +
                @resultSetAddClientNotif[0]['delivery_addr'].to_s.gsub(/@/, " - " + notif_client_ref + " <br> ") + " " +
                "<br><br>Connectez-vous vite sur MG Suivi pour obtenir le meilleur de votre tracking."

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

    sql_query = "SELECT u.id AS id, u.name AS name, u.client_ref AS client_ref, u.firstname AS firstname, u.email AS email, 'X' AS enc_client_ref, 'X' AS raw_data, cpx.has_poc AS poc, to_char(cpx.create_date, 'DD/MM/YYYY') AS since, bc.owner_id, count(1) AS totalbc "
    sql_query += " FROM client_partner_xref cpx JOIN users u on cpx.client_id = u.id AND cpx.partner_id = " + @current_user.partner.to_s + " "
    sql_query += " LEFT JOIN barcode bc on bc.owner_id = u.id "
    sql_query += " AND cpx.partner_id = " + @current_user.partner.to_s + " AND bc.partner_id = " + @current_user.partner.to_s + " "
    sql_query += " GROUP BY u.id, u.name, u.client_ref, u.firstname, u.email, cpx.has_poc, bc.owner_id, cpx.create_date "
    sql_query += " ORDER BY cpx.create_date DESC LIMIT "+ ENV['SQL_LIMIT_MD'] +";"

    begin

      @resultSet = ActiveRecord::Base.connection.exec_query(sql_query)
      @emptyResultSet = @resultSet.empty?
      @maxRowParamMD = " Cet écran récupère un maximum de " + ENV['SQL_LIMIT_MD'].to_s + " lignes. Si vous avez besoin de plus contactez-nous avec le code UPG921."
    end
    rescue Exception => exc
       flash.now[:danger] = "Une erreur est survenue #{exec.message}"
  end

end
