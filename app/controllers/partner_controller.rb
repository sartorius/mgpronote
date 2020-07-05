class PartnerController < ApplicationController
  before_action :mgs_user_is_partner
  before_action :get_partner_company_name


  def mainstatistics

    # Get all status
    sql_query = "SELECT rs.step, rs.id, COUNT(1) AS cnt_stat " +
                        " FROM barcode bc JOIN ref_status rs ON bc.status = rs.id " +
                        # You can use this to make sure barcode is link to the partner
                        " JOIN users u ON u.partner = bc.partner_id " +
                        " WHERE u.id = " + @current_user.id.to_s +
                        # End partner check
        	              " GROUP BY rs.step, rs.id ORDER BY rs.id ASC;"

    # Get all client stats
    sql_query_client = "SELECT u.id AS id, u.name AS name, u.firstname AS firstname, u.email AS email, cpx.has_poc AS poc, to_char(cpx.create_date, 'DD/MM/YYYY') AS since, bc.owner_id, count(1) AS totalbc "
    sql_query_client += " FROM client_partner_xref cpx JOIN users u on cpx.client_id = u.id "
    sql_query_client += " JOIN barcode bc on bc.owner_id = u.id "
    sql_query_client += " AND cpx.partner_id = " + @current_user.partner.to_s + " "
    sql_query_client += " GROUP BY u.id, u.name, u.firstname, u.email, cpx.has_poc, bc.owner_id, cpx.create_date "
    sql_query_client += " ORDER BY cpx.create_date DESC LIMIT 10;"

    begin

      @resultSet = ActiveRecord::Base.connection.exec_query(sql_query)
      @emptyResultSet = @resultSet.empty?

      @resultSetClient = ActiveRecord::Base.connection.exec_query(sql_query_client)
      @emptyResultSetClients = @resultSetClient.empty?

      render 'mainstatistics'
    end
    rescue Exception => exc
       flash[:info] = "Une erreur est survenue #{exec.message}"
      render 'mainstatistics'
  end

  #One barcode manager
  def onebarcodemng
    sql_query = "SELECT bc.id AS id, bc.secure, bc.to_name AS tname, bc.to_firstname AS tfirstname, " +
                		" bc.to_phone AS tphone, bc.ext_ref, bc.secret_code AS secret_code, rp.delivery_addr, rp.pickup_addr, rp.name AS part_name,  " +
                    " bc.type_pack, bc.p_name_firstname, bc.p_phone, bc.p_address_note, bc.category, bc.weight_in_gr, bc.wf_id, " +
                		" to_char(bc.create_date, 'DD/MM/YYYY HH24:MI UTC') AS create_date, " +
                		" rs.id AS step_id, rs.step, rs.description, rs.next_input_needed, rs.act_owner, " +
                		" uo.name AS oname, uo.firstname AS ofirstname, uo.email AS oemail, uo.phone AS ophone, " +
                		" uc.name AS cname, uc.firstname AS cfirstname, uc.email AS cemail, uc.phone AS cphone " +
                		" FROM barcode bc JOIN ref_partner rp ON rp.id = bc.partner_id " +
                  		"JOIN ref_status rs ON rs.id = bc.status " +
                  		"JOIN users uo ON uo.id = bc.owner_id " +
                  		"JOIN users uc ON uc.id = bc.creator_id " +
                  		" WHERE bc.id = " + params[:checkcbid] +
                      " AND bc.partner_id = " + @current_user.partner.to_s +
                  		" AND bc.secure = " + params[:checkcbsec] + ";"

    begin

      #flash[:info] = "Step save: " + params[:stepstep] + " /" + params.to_s + " //" + sql_query
      #@resultSet = ActiveRecord::Base.connection.execute(sql_query)
      @resultSet = ActiveRecord::Base.connection.exec_query(sql_query)
      @emptyResultSet = @resultSet.empty?

      render 'onebarcodemng'
    end
    rescue Exception => exc
       flash[:info] = "Une erreur est survenue #{exec.message}"
      render 'onebarcodemng'
  end

  # Get the next step BC
  def dashboard
    #sendEmailTest('ratinahirana@gmail.com', 'Blou Ratinahirana', 'M03200202', 'Arrivé au centre de dépot')

    sql_query = "SELECT bc.id AS id, uo.name AS oname, uo.firstname AS ofirstname, " +
                      " uo.phone AS ophone, to_char(bc.create_date, 'DD/MM/YYYY') AS create_date, " +
                      " DATE_PART('day', NOW() - bc.create_date) AS diff_days, bc.ref_tag AS ref_tag, " +
                      " rs.step AS step, LPAD(bc.secure::CHAR(4), 4, '0') AS secure, " +
                      " LPAD(bc.secret_code::CHAR(4), 4, '0') AS bsecret_code, " +
                      " bc.type_pack, bc.ext_ref, " +
                      " UPPER(CONCAT(uo.name, uo.firstname, bc.ext_ref, uo.phone, rs.step)) AS raw_data " +
                      " FROM barcode bc join ref_status rs on rs.id = bc.status " +
                      # You can use this to make sure barcode is link to the partner
                      " JOIN users u ON u.partner = bc.partner_id " +
                      " JOIN users uo ON uo.id = bc.owner_id " +
                      " WHERE u.id = " + @current_user.id.to_s +
                      # End partner check
                      " ORDER BY bc.id DESC LIMIT "+ ENV['SQL_LIMIT_LG'] +";"


    begin

      #flash[:info] = "Step save: " + params[:stepstep] + " /" + params.to_s + " //" + sql_query
      #@resultSet = ActiveRecord::Base.connection.execute(sql_query)
      @resultSet = ActiveRecord::Base.connection.exec_query(sql_query)
      @emptyResultSet = @resultSet.empty?

      @maxRowParamLG = " Cet écran récupère un maximum de " + ENV['SQL_LIMIT_LG'].to_s + " références. Si vous avez besoin de plus contactez-nous avec le code UPG678."

      render 'dashboard'
    end
    rescue Exception => exc
       flash[:info] = "Une erreur est survenue #{exec.message}"
      render 'dashboard'
  end

  def printtwelve

    sql_query = "SELECT bc.id AS id, bc.ref_tag AS ref_tag, rs.step AS step, LPAD(bc.secure::CHAR(4), 4, '0') AS secure, LPAD(bc.secret_code::CHAR(4), 4, '0') AS bsecret_code " +
                      "FROM barcode bc join ref_status rs on rs.id = bc.status " +
                      # You can use this to make sure barcode is link to the partner
                      " JOIN users u ON u.partner = bc.partner_id " +
                      " WHERE u.id = " + @current_user.id.to_s +
                      # End partner check
                      " ORDER BY bc.id ASC LIMIT 12;"


    begin

      #flash[:info] = "Step save: " + params[:stepstep] + " /" + params.to_s + " //" + sql_query
      #@resultSet = ActiveRecord::Base.connection.execute(sql_query)
      @resultSet = ActiveRecord::Base.connection.exec_query(sql_query)
      @emptyResultSet = @resultSet.empty?

      render 'printtwelve'
    end
    rescue Exception => exc
       flash[:info] = "Une erreur est survenue #{exec.message}"
      render 'printtwelve'
  end

  def printnotrack
    render 'printnotrack'
  end

end
