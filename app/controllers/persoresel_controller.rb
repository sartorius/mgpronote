class PersoreselController < ApplicationController
  before_action :mgs_logged_in_user



  def createbarcodebyclient

    # Check the session
    if params[:auth_token] == session[:_mgs_csrf_token].to_s then


      sql_query = "SELECT * FROM CLI_CRT_BC(" +
                    @current_user.id.to_s + ", "+
                    @current_user.id.to_s + ", CAST(" + params[:partner_id] +
                    " AS SMALLINT), TRIM('" + params[:order] + "'));"
      @resultSet = ActiveRecord::Base.connection.exec_query(sql_query)

      puts '>>> ' + @resultSet[0]['cli_crt_bc'].to_s
      if @resultSet[0]['cli_crt_bc'].to_i > 0 then
        render plain: 'ok'
      elsif @resultSet[0]['cli_crt_bc'].to_i == -3 then

        render plain: 'max'
      elsif @resultSet[0]['cli_crt_bc'].to_i == -2 then

        render plain: 'poc'
      else
        render plain: 'unk'
      end
    else
      #Do nothing
      render plain: 'ko'
    end
  end


  def getmypartnerlist
    sql_query = "SELECT rp.id AS id, rp.name AS rp_name, rp.description AS rp_desc, to_char(cpx.create_date, 'DD/MM/YYYY') AS since, count(1) AS totalbc "
    sql_query += " FROM client_partner_xref cpx JOIN users u on cpx.client_id = u.id "
    sql_query += " JOIN ref_partner rp on rp.id = cpx.partner_id "
    sql_query += " AND cpx.client_id = " + @current_user.id.to_s
    sql_query += " JOIN barcode bc ON bc.owner_id = u.id AND bc.partner_id = rp.id "
    sql_query += " GROUP BY rp.id, rp.name, rp.description, cpx.create_date "
    sql_query += " ORDER BY cpx.create_date DESC;"

    begin

      @resultSet = ActiveRecord::Base.connection.exec_query(sql_query)
      @emptyResultSet = @resultSet.empty?
    end
    rescue Exception => exc
       flash.now[:danger] = "Une erreur est survenue #{exec.message}"

       @getAuthToken = mgs_form_authenticity_token.to_s

    render 'getmypartnerlist'
  end

  def addadditionnal

    sql_query_check_ext_ref = "SELECT COUNT(1) AS mg_count FROM barcode WHERE ext_ref = " + get_safe_pg_wq_ns(params[:mgaddextref]) +
                                " AND id NOT IN (" + params[:checkcbid] + ");"

    @resultSetCheckCount = ActiveRecord::Base.connection.exec_query(sql_query_check_ext_ref)

    if @resultSetCheckCount[0]['mg_count'].to_i == 0 then
        sql_query = " UPDATE barcode SET ext_ref = " + get_safe_pg_wq_ns(params[:mgaddextref]) +
                      ", to_name = " + get_safe_pg_wq(params[:mgaddtname]) +
                      ", to_firstname = " + get_safe_pg_wq(params[:mgaddtfname]) +
                      ", description = " + get_safe_pg_wq(params[:mgadddescription]) +
                      ", to_phone = " + get_safe_pg_wq(params[:mgaddtphone]) +
                      " WHERE id = " + params[:checkcbid] + " AND owner_id = " + @current_user.id.to_s + ";"

        ActiveRecord::Base.connection.exec_query(sql_query)

        flash.now[:success] = "La mise à jour des informations additionnels a été correctement effectué"

    else
      message  = "Il semble que la référence externe a déjà été enregistrée par quelqu'un d'autre. Veuillez la re-vérifier."
      message += "Si vous pensez qu'il s'agit d'une erreur, il s'agit d'un code YZJ90, contactez-nous. Nous sommes navrés pour la gêne occasionée."
      flash.now[:danger] = message
    end

    seeone
  end

  def addaddress
    #We do the transaction here then we go on seeone
    puts 'You are in see one'

    sql_query = "SELECT * FROM CLI_STEP_ADDR_TAG ("+ params[:checkcbid] +", CAST ("+ params[:steprwfid] +" AS SMALLINT), TRIM('"+ params[:stepgeol] + "'), " + " NULL, NULL, NULL, NULL, " + @current_user.id.to_s + ", " + get_safe_pg_wq(params[:mgaddpknm]) + ", " + get_safe_pg_wq(params[:mgaddpkph]) + ", " + get_safe_pg_wq(params[:mgaddpkadd]) + ");"


    puts 'sql_query: ' + sql_query

    begin

      @resultSetFunc = ActiveRecord::Base.connection.exec_query(sql_query)

      message  = "Les informations ont été correctement enregistrés."
      flash.now[:success] = message

      seeone
    end
    rescue Exception => exc
       message  = "Navré ! Une erreur GDJ90 est survenue #{exec.message}"
       flash.now[:danger] = message

       seeone

  end


  def seeone
    sql_query = "SELECT bc.id AS id, bc.secure, bc.to_name AS tname, bc.to_firstname AS tfirstname, " +
                		" bc.to_phone AS tphone, bc.description as bcdescription, bc.ext_ref, bc.secret_code AS secret_code, bc.type_pack AS type_pack, rp.delivery_addr, rp.pickup_addr, rp.name AS part_name,  " +
                    " bc.type_pack, bc.p_name_firstname, bc.p_phone, bc.p_address_note, bc.category, bc.weight_in_gr, bc.wf_id, " +
                    " to_char(bc.create_date, 'DD/MM/YYYY HH24:MI UTC') AS create_date, " +
                		" rs.id AS step_id, rs.step, rs.description, rs.next_input_needed, rs.act_owner, " +
                		" uo.id AS oid, uo.name AS oname, uo.client_ref AS oclient_ref, uo.firstname AS ofirstname, uo.email AS oemail, uo.phone AS ophone, " +
                		" uc.name AS cname, uc.firstname AS cfirstname, uc.email AS cemail, uc.phone AS cphone " +
                		" FROM barcode bc JOIN ref_partner rp ON rp.id = bc.partner_id " +
                  		"JOIN ref_status rs ON rs.id = bc.status " +
                  		"JOIN users uo ON uo.id = bc.owner_id " +
                  		"JOIN users uc ON uc.id = bc.creator_id " +
                  		" WHERE bc.id = " + params[:checkcbid] +
                  		" AND bc.secure = " + params[:checkcbsec] +
                  		" AND bc.owner_id = " + @current_user.id.to_s + ";"

    begin

      #flash[:info] = "Step save: " + params[:stepstep] + " /" + params.to_s + " //" + sql_query
      #@resultSet = ActiveRecord::Base.connection.execute(sql_query)
      @resultSet = ActiveRecord::Base.connection.exec_query(sql_query)
      @emptyResultSet = @resultSet.empty?

      @screenClient = true

      render 'seeone'
    end
    rescue Exception => exc
       flash[:info] = "Une erreur est survenue #{exec.message}"
      render 'seeone'
  end

  # Get the next step BC
  def dashboard

    sql_query = "SELECT bc.id AS id, bc.ref_tag AS ref_tag, rs.step AS step, LPAD(bc.secure::CHAR(4), 4, '0') AS secure, LPAD(bc.secret_code::CHAR(4), 4, '0') AS bsecret_code, " +
                      " bc.type_pack, bc.p_name_firstname, bc.p_phone, bc.p_address_note, bc.description AS bc_description, " +
                      " rp.name AS part_name, bc.status, rp.to_phone AS part_phone, to_char(bc.create_date, 'DD/MM/YYYY') AS create_date, DATE_PART('day', NOW() - bc.create_date) AS diff_days, 'X' AS raw_data " +
                      " FROM barcode bc join ref_status rs on rs.id = bc.status " +
                      # You can use this to make sure barcode is link to the owner id
                      " JOIN users u ON u.id = bc.owner_id " +
                      " JOIN ref_partner rp ON rp.id = bc.partner_id " +
                      " WHERE u.id = " + @current_user.id.to_s +
                      # End partner check
                      " ORDER BY bc.id DESC;"


    begin

      #flash[:info] = "Step save: " + params[:stepstep] + " /" + params.to_s + " //" + sql_query
      #@resultSet = ActiveRecord::Base.connection.execute(sql_query)
      @resultSet = ActiveRecord::Base.connection.exec_query(sql_query)
      @emptyResultSet = @resultSet.empty?

      render 'dashboard'
    end
    rescue Exception => exc
       flash[:info] = "Une erreur est survenue #{exec.message}"
      render 'dashboard'
  end

end
