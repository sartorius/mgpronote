class PartnerController < ApplicationController
  before_action :mgs_user_is_partner
  before_action :get_partner_company_name


  def mainstatistics


    # Get all weight for all status
    sql_query_weight_per_step = "SELECT rs.step, rs.id, ROUND(SUM(bc.weight_in_gr)::decimal/1000, 2) AS sum_weight " +
                                " FROM barcode bc JOIN ref_status rs ON bc.status = rs.id " +
                                # You can use this to make sure barcode is link to the partner
                                " JOIN users u ON u.partner = bc.partner_id " +
                                " WHERE u.id = " + @current_user.id.to_s +
                                # End partner check
                                " AND bc.weight_in_gr IS NOT NULL " +
                                # We do not consider 10 dispo client and -1 terminated
                                " AND rs.id NOT IN (10, -1) " +
                	              " GROUP BY rs.step, rs.id ORDER BY rs.id ASC;"

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

      @resultSetAllWeights = ActiveRecord::Base.connection.exec_query(sql_query_weight_per_step)
      @emptyResultSetAllWeights = @resultSetAllWeights.empty?

      render 'mainstatistics'
    end
    rescue Exception => exc
       flash[:info] = "Une erreur est survenue #{exec.message}"
      render 'mainstatistics'
  end

  #One barcode manager
  def onebarcodemng

    puts "onebarcodemng/params[:checkcbid] " + params[:checkcbid].nil?.to_s
    puts "onebarcodemng/params[:checkcbsec]: " + params[:checkcbsec].nil?.to_s


    # We check if we have saved the bc id in session
    # From the click from dashboard we populate the session variable
    if params[:checkcbid].nil? then
      params[:checkcbid] = session[:checkcbid]
    end
    if params[:checkcbsec].nil? then
      params[:checkcbsec] = session[:checkcbsec]
    end


    # So we are checking it the params bc id is available (or refreshed)
    unless params[:checkcbid].nil? then
      # if we do refresh we need to go to main log

      # Save the data when we get them
      unless params[:checkcbid].nil? then
        session[:checkcbid] = params[:checkcbid]
      end

      unless params[:checkcbsec].nil? then
        session[:checkcbsec] = params[:checkcbsec]
      end

      sql_query = "SELECT bc.id AS id, bc.secure, bc.to_name AS tname, bc.to_firstname AS tfirstname, " +
                  		" bc.to_phone AS tphone, bc.ext_ref, bc.secret_code AS secret_code, rp.delivery_addr, rpw.pickup_addr, rpw.pickup_phone, rp.name AS part_name,  " +
                      " bc.type_pack, bc.p_name_firstname, bc.description as bcdescription, bc.p_phone, bc.p_address_note, bc.category, bc.weight_in_gr, bc.wf_id, " +
                  		" to_char(bc.create_date, 'DD/MM/YYYY HH24:MI UTC') AS create_date, rwf.code AS rwf_code, rwf.description  AS rwf_description, rwf.avg_delivery AS rwf_avg_delivery, rwf.mode AS rwf_mode, " +
                  		" rs.id AS step_id, rs.step, rs.description, rs.next_input_needed, rs.act_owner, to_char(bc.create_date + interval '1' day * rwf.avg_delivery, 'DD/MM/YYYY') AS estim_delivery, DATE_PART('day', (bc.create_date + interval '1' day * rwf.avg_delivery) - CURRENT_DATE) AS is_late, " +
                      " rp.hdl_price, rp.type AS rp_type, bc.price_cts, bc.paid_code, bc.mother_ref AS mother_ref, " +
                  		" uo.id AS oid, uo.name AS oname, uo.firstname AS ofirstname, uo.client_ref AS oclient_ref, uo.email AS oemail, uo.phone AS ophone, " +
                  		" uc.name AS cname, uc.firstname AS cfirstname, uc.id AS cid, uc.client_ref AS cclient_ref, uc.email AS cemail, uc.phone AS cphone " +
                  		" FROM barcode bc JOIN ref_partner rp ON rp.id = bc.partner_id " +
                        " JOIN ref_partner_workflow rpw ON bc.wf_id = rpw.wf_id AND rp.id = rpw.partner_id " +
                        " JOIN ref_workflow rwf ON rwf.id = bc.wf_id " +
                    		" JOIN ref_status rs ON rs.id = bc.status " +
                    		" JOIN users uo ON uo.id = bc.owner_id " +
                    		" JOIN users uc ON uc.id = bc.creator_id " +
                    		" WHERE bc.id = " + params[:checkcbid] +
                        " AND bc.partner_id = " + @current_user.partner.to_s +
                    		" AND bc.secure = " + params[:checkcbsec] + ";"

      sql_query_step = " SELECT DISTINCT gs.id, bc.id AS bc_id, bcrs.step, gs.grp_step, gs.common, gs.order_id " +
                        " FROM ref_status rs  " +
                        " JOIN grp_status gs ON rs.grp_id = gs.id " +
                        " LEFT JOIN barcode bc ON bc.status = rs.id " +
                        						" AND bc.id = " + params[:checkcbid] +
                        						" LEFT JOIN ref_status bcrs ON bcrs.id = bc.status " +
                                    " WHERE gs.mode IN ((SELECT CASE WHEN mode IN ('P', 'B') THEN 'T' ELSE mode END FROM ref_workflow rw WHERE rw.id = (select wf_id from barcode bc where bc.id = " + params[:checkcbid] + ")), 'A') " +
                        " order by bc.id, gs.order_id ASC; "
    end

    begin

      unless params[:checkcbid].nil? then
          #flash[:info] = "Step save: " + params[:stepstep] + " /" + params.to_s + " //" + sql_query
          #@resultSet = ActiveRecord::Base.connection.execute(sql_query)
          @resultSet = ActiveRecord::Base.connection.exec_query(sql_query)
          @emptyResultSet = @resultSet.empty?

          @resultSetStepWorkflow = ActiveRecord::Base.connection.exec_query(sql_query_step)

          @screenClient = false

          render 'onebarcodemng'
      else
          # We are doing a refresh
          load_dashboard(nil, nil)
          render 'dashboard'
      end
    end
    rescue Exception => exc
       flash[:info] = "Une erreur est survenue #{exec.message}"
      render 'onebarcodemng'
  end

  def dashboardbyclient

      # Save the data when we get them
      unless params[:clientid].nil? then
        session[:clientid] = params[:clientid]
      end

      unless params[:clientref].nil? then
        session[:clientref] = params[:clientref]
      end



      filter_client_id = params[:clientid]
      filter_client_ref = params[:clientref]
      # Read the data when back
      if filter_client_id.nil? && !session[:clientid].nil? then
        filter_client_id = session[:clientid]
      end

      if filter_client_ref.nil? && !session[:clientref].nil? then
        filter_client_ref = session[:clientref]
      end


      load_dashboard(filter_client_id, nil)

      @msgToDisplay = 'Filtre client: '+ filter_client_ref

      if filter_client_id.nil?
        flash.now[:danger] = "Problème dans le chargement client. Erreur NDH738"
      end

      render 'dashboard'
  end


  def dashboardbymother

    # Save the data when we get them
    unless params[:motherid].nil? then
      session[:motherid] = params[:motherid]
    end

    unless params[:motherref].nil? then
      session[:motherref] = params[:motherref]
    end

    filter_mother_id = params[:motherid]
    filter_mother_ref = params[:motherref]

    # Read the data when back
    if filter_mother_id.nil? && !session[:motherid].nil? then
      filter_mother_id = session[:motherid]
    end

    if filter_mother_ref.nil? && !session[:motherref].nil? then
      filter_mother_ref = session[:motherref]
    end

    #puts "Read Mother id: " + params[:motherid]
    load_dashboard(nil, filter_mother_id)

    @msgToDisplay = 'Filtre MOTHER: '+ filter_mother_ref

    if filter_mother_id.nil?
      flash.now[:danger] = "Problème dans le chargement client. Erreur NDH721"
    end

    render 'dashboard'
  end


  # Get the next step BC
  def dashboard
    #sendEmailTest('ratinahirana@gmail.com', 'Blou Ratinahirana', 'M03200202', 'Arrivé au centre de dépot')
      load_dashboard(nil, nil)

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

  private

  def load_dashboard(client_id, mother_id)

    # Save the data when we get them
    if client_id.nil? then
      session[:clientid] = nil
      session[:clientref] = nil
    end

    if mother_id.nil? then
      session[:motherid] = nil
      session[:motherref] = nil
    end

    if !client_id.nil?
      sql_clause = " AND bc.owner_id = " + client_id.to_s
    elsif !mother_id.nil?
      sql_clause = " AND bc.mother_id = " + mother_id.to_s
    else
      sql_clause = ''
    end
    sql_query = "SELECT bc.id AS id, uo.id AS oid, uo.name AS oname, uo.firstname AS ofirstname, uo.client_ref AS oclient_ref, " +
                      " uo.phone AS ophone, uo.email AS oemail, bc.description as bcdescription, bc.mother_ref, to_char(bc.create_date, 'DD/MM/YYYY') AS create_date, " +
                      " DATE_PART('day', NOW() - bc.create_date) AS diff_days, bc.ref_tag AS ref_tag, " +
                      " rs.step AS step, rs.step_short, LPAD(bc.secure::CHAR(4), 4, '0') AS secure, " +
                      " CASE WHEN bc.p_name_firstname IS NULL THEN '-' ELSE p_name_firstname END, CASE WHEN bc.p_phone IS NULL THEN '-' ELSE bc.p_phone END, CASE WHEN bc.p_address_note IS NULL THEN '-' ELSE bc.p_address_note END, " +
                      " LPAD(bc.secret_code::CHAR(4), 4, '0') AS bsecret_code, " +
                      " bc.type_pack, bc.ext_ref, 'U' AS print, 'N' AS ald_print, rfw.code AS rfw_code, rfw.description AS rfw_desc, bc.paid_code, bc.mother_ref, " +
                      " UPPER(CONCAT(uo.name, uo.firstname, bc.ext_ref, uo.phone, rs.step, rfw.description, rfw.code, bc.mother_ref)) AS raw_data " +
                      " FROM barcode bc join ref_status rs on rs.id = bc.status " +
                      # You can use this to make sure barcode is link to the partner
                      " JOIN users u ON u.partner = bc.partner_id " +
                      " JOIN users uo ON uo.id = bc.owner_id " +
                      " JOIN ref_workflow rfw ON rfw.id = bc.wf_id " +
                      " WHERE u.id = " + @current_user.id.to_s +
                      sql_clause +
                      # End partner check
                      " ORDER BY bc.id DESC LIMIT "+ ENV['SQL_LIMIT_LG'] +";"



    begin

      #flash[:info] = "Step save: " + params[:stepstep] + " /" + params.to_s + " //" + sql_query
      #@resultSet = ActiveRecord::Base.connection.execute(sql_query)
      @resultSet = ActiveRecord::Base.connection.exec_query(sql_query)
      @emptyResultSet = @resultSet.empty?

      @maxRowParamLG = " Cet écran récupère un maximum de " + ENV['SQL_LIMIT_LG'].to_s + " références. Si vous avez besoin de plus contactez-nous avec le code UPG678."
      @maxPrintConstEnv = ENV['MAX_PRINT'].to_s
      puts '@maxPrintConstEnv: ' + @maxPrintConstEnv.to_s

  end

end
