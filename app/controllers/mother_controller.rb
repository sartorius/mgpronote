class MotherController < ApplicationController
  before_action :mgs_user_is_partner
  before_action :get_partner_company_name
  before_action :verify_authenticity_token, :only => [:createmother]

  def mothermng
    load_mother_dashboard
    load_partner_workflow
    @getAuthToken = mgs_form_authenticity_token.to_s

    render 'mothermng'
  end


  def createmother
    if params[:auth_token] == session[:_mgs_csrf_token].to_s then

      puts 'We create a mother.'

      sql_query = "SELECT * FROM CLI_CRT_MOTHER(" + @current_user.id.to_s + ", CAST(" + params[:partner_id] + " AS SMALLINT), CAST(" + params[:wf_id] + " AS SMALLINT));"
      @resultSet = ActiveRecord::Base.connection.exec_query(sql_query)

      puts '>>> Here is the returned value: ' + @resultSet[0]['cli_crt_mother'].to_s
      if @resultSet[0]['cli_crt_mother'].to_i > 0 then
        render plain: @resultSet[0]['cli_crt_mother'].to_s
      else
        render plain: 'unk'
      end

    else
      #Do nothing
      puts 'We DONT create a mother.'
      render plain: 'ko'
    end
  end


  # Save the assocaition here
  def associatemother
    #puts '*** PURE <<<<<<<<<<< ' + params[:grpcheckcbpure]
    #puts '*** PURE ID <<<<<<<<<<< ' + params[:grpcheckcbpureid]
    #puts '*** EXT <<<<<<<<<<< ' + params[:grpcheckcbext]

    @list_pure_array = JSON.parse(params[:grpcheckcbpure])
    @list_pure_array_id = JSON.parse(params[:grpcheckcbpureid])
    @list_ext_array = JSON.parse(params[:grpcheckcbext])

    @list_mother_array = JSON.parse(params[:grpcheckcbmother])
    @list_mother_array_raw = JSON.parse(params[:grpcheckcbmotherraw])

    @do_we_need_grp_notify = false

    # puts '--------------------------'
    # puts '@list_mother_array: ' + @list_mother_array.inspect
    # puts '@list_mother_array_raw: ' + @list_mother_array_raw.inspect

    # puts '@list_mother_array_raw 0: ' + @list_mother_array_raw[0].to_s
    # puts '@list_mother_array 0 id: ' + @list_mother_array[0]["id"].to_s

    #puts '*** PURE inspect <<<<<<<<<<< ' + @list_pure_array.inspect
    # *** PURE <<<<<<<<<<< [{"id":20,"secure":8473},{"id":19,"secure":536},{"id":18,"secure":2359}]
    #puts '*** PURE ID inspect <<<<<<<<<<< ' + @list_pure_array_id.inspect
    # *** PURE ID <<<<<<<<<<< [20,19,18]
    #puts '*** EXT inspect <<<<<<<<<<< ' + @list_ext_array.inspect
    # *** EXT <<<<<<<<<<< ["AZERTY5","AZERTY4"]

    # We need to check if the list is not empty
    # CALL CLI_GRPSTEP_TAG_PURE('{20, 19, 18}'::BIGINT[], CAST(7 AS SMALLINT), 'N', 140);
    unless (@list_pure_array_id.empty?) then
      # Construct the array
      pure_array_id = ''
      start_coma = ''
      for pure_id in @list_pure_array_id do
        pure_array_id = pure_array_id + start_coma + get_safe_pg_number(pure_id.to_s)
        start_coma = ', '
      end
      # Finalize
      pure_array_id = " '{"+ pure_array_id + "}'::BIGINT[] "

      # CLI_GRPASSO_PURE(par_bc_id_arr BIGINT[], par_user_id BIGINT, par_mother_id BIGINT, par_mother_ref CHAR(11))
      sql_query_pure_id = "SELECT * FROM CLI_GRPASSO_PURE ("+ pure_array_id + ", " + @current_user.id.to_s + ", " + @list_mother_array[0]["id"].to_s + ", '" + @list_mother_array_raw[0].to_s  + "');"
      #puts 'Q Pure ID: ' + sql_query_pure_id

      @resultSetCallPureId = ActiveRecord::Base.connection.exec_query(sql_query_pure_id)
      # There is no notification to send

    end


    # We need to check if the list is not empty
    # CALL CLI_GRPSTEP_TAG_EXT('{"AZERTY5","AZERTY4"}'::VARCHAR(35)[], CAST(7 AS SMALLINT), 'N', 140);
    unless (@list_ext_array.empty?) then
      # Construct the array
      ext_array = ''
      start_coma = ''
      for ext in @list_ext_array do
        ext_array = ext_array + start_coma + get_safe_pg_wq_ns_notrim_doublequote(ext.to_s)
        start_coma = ', '
      end
      # Finalize
      ext_array = " '{"+ ext_array + "}'::VARCHAR(35)[] "

      # CLI_GRPASSO_EXT(par_bc_ext_arr VARCHAR(35)[], par_user_id BIGINT, par_mother_id BIGINT, par_mother_ref CHAR(11))
      sql_query_ext = "SELECT * FROM CLI_GRPASSO_EXT("+ ext_array + ", " + @current_user.id.to_s + ", " + @list_mother_array[0]["id"].to_s + ", '" + @list_mother_array_raw[0].to_s  + "');"
      #puts 'Q EXT: ' + sql_query_ext

      @resultSetCallExt = ActiveRecord::Base.connection.exec_query(sql_query_ext)
      # There is no notification to send
    end

    render 'resultfinalassociation'

  end

  # ********************************************* OPERATION FROM SCREEN *********************************************

  def markstepmother
    @list_mother_array = JSON.parse(params[:list_of_mt])
    puts '@list_mother_array: ' + @list_mother_array.inspect
    puts 'step_id: ' + params[:step_id] + ' /wf_id: ' + params[:wf_id]

    unless (@list_mother_array.empty?) then
      # Construct the array
      mother_array_id = ''
      start_coma = ''
      for mother_id in @list_mother_array do
        mother_array_id = mother_array_id + start_coma + get_safe_pg_number(mother_id.to_s)
        start_coma = ', '
      end
      # Finalize
      mother_array_id = " '{"+ mother_array_id + "}'::BIGINT[] "

      # (array_of_mother_id, mwkf_id, step_id, geo_l, user_id)
      sql_query_mother_id = "SELECT * FROM CLI_STEP_MT ("+ mother_array_id + ", CAST (" + params[:wf_id] + " AS SMALLINT), CAST (" + params[:step_id] + " AS SMALLINT), TRIM('N'), " + @current_user.id.to_s  + ");"
      #puts 'Q Pure ID: ' + sql_query_pure_id

      @resultSetCallStepMother = ActiveRecord::Base.connection.exec_query(sql_query_mother_id)
      # There is no notification to send
      @resultSetCallStepMother.each do |notification|
        # conveniently, row is a hash
        # the keys are the fields, as you'd expect
        # the values are pre-built ruby primitives mapped from their corresponding field types in MySQL
        # Here's an otter: http://farm1.static.flickr.com/130/398077070_b8795d0ef3_b.jpg
        # <%= "#{val['id']}, #{val['name']}, #{val['age']}" %>
        # puts 'Notif: ' + notification['bc_id'].to_s +' / '+ notification['bc_sec'].to_s +' / '+ notification['name'].to_s +' / '+ notification['firstname'].to_s +' / '+ notification['to_addr'].to_s +' / '+ notification['step'].to_s +' / '+ notification['msg'].to_s
        # sendEmailNotification(to_addr, firstname_name, cb_code, status, msg)
        # puts 'Notif Ext: ' + notification.inspect
        sendEmailNotification(notification['to_addr'].to_s,
                                notification['firstname'].to_s,
                                encodeMGS(notification['bc_id'].to_s, notification['bc_sec'].to_s),
                                notification['step'].to_s,
                                notification['msg'].to_s)
      end

      render plain: 'ok'

    else
      render plain: 'ko'
    end

  end



  def dissociatemother
    @list_mother_array = JSON.parse(params[:list_of_mt])
    puts '@list_mother_array: ' + @list_mother_array.inspect

    unless (@list_mother_array.empty?) then
      # Construct the array
      mother_array_id = ''
      start_coma = ''
      for mother_id in @list_mother_array do
        mother_array_id = mother_array_id + start_coma + get_safe_pg_number(mother_id.to_s)
        start_coma = ', '
      end
      # Finalize
      mother_array_id = " '{"+ mother_array_id + "}'::BIGINT[] "

      sql_query_mother_id = "SELECT * FROM CLI_UNGRP_MT ("+ mother_array_id + ", " + @current_user.id.to_s  + ");"
      #puts 'Q Pure ID: ' + sql_query_pure_id
      @resultSetCallDisMother = ActiveRecord::Base.connection.exec_query(sql_query_mother_id)

      render plain: 'ok'

    else
      render plain: 'ko'
    end

  end


  def incidentmother
    @list_mother_array = JSON.parse(params[:list_of_mt])
    puts '@list_mother_array: ' + @list_mother_array.inspect

    unless (@list_mother_array.empty?) then
      # Construct the array
      mother_array_id = ''
      start_coma = ''
      for mother_id in @list_mother_array do
        mother_array_id = mother_array_id + start_coma + get_safe_pg_number(mother_id.to_s)
        start_coma = ', '
      end
      # Finalize
      mother_array_id = " '{"+ mother_array_id + "}'::BIGINT[] "

      sql_query_mother_id = "SELECT * FROM CLI_DECLARE_INC_MT("+ mother_array_id + ", " + @current_user.id.to_s  + ");"
      #puts 'Q Pure ID: ' + sql_query_pure_id
      @resultSetCallIncMother = ActiveRecord::Base.connection.exec_query(sql_query_mother_id)

      @resultSetCallIncMother.each do |notification|
        # conveniently, row is a hash
        # the keys are the fields, as you'd expect
        # the values are pre-built ruby primitives mapped from their corresponding field types in MySQL
        # Here's an otter: http://farm1.static.flickr.com/130/398077070_b8795d0ef3_b.jpg
        # <%= "#{val['id']}, #{val['name']}, #{val['age']}" %>
        # puts 'Notif: ' + notification['bc_id'].to_s +' / '+ notification['bc_sec'].to_s +' / '+ notification['name'].to_s +' / '+ notification['firstname'].to_s +' / '+ notification['to_addr'].to_s +' / '+ notification['step'].to_s +' / '+ notification['msg'].to_s
        # sendEmailNotification(to_addr, firstname_name, cb_code, status, msg)
        # puts 'Notif Ext: ' + notification.inspect
        sendEmailNotification(notification['to_addr'].to_s,
                                notification['firstname'].to_s,
                                encodeMGS(notification['bc_id'].to_s, notification['bc_sec'].to_s),
                                notification['step'].to_s,
                                notification['msg'].to_s)
      end

      render plain: 'ok'

    else
      render plain: 'ko'
    end

  end



  # ************************************************* PRIVATE ****************************************************

  private

  def load_mother_dashboard

    sql_query_with = " WITH moth_occ AS ( SELECT mother_id, count(1) AS occ from mother_barcode_xref GROUP BY mother_id) "

    sql_query = sql_query_with + " SELECT 'X' AS mt_ref, 'X' AS c_crt, mt.id AS id, mt.secure, mt.status AS status_code, mt.under_incident, CASE WHEN rs.step_short IS NULL THEN 'Nouveau' ELSE rs.step_short END AS mstatus, CASE WHEN rfw.code IS NULL THEN 'na' ELSE rfw.code END AS rfw_code, " +
                      " partner_id, rfw.id AS rfw_id, creator_id, u.firstname AS u_firstname, u.client_ref AS u_client_ref, to_char(mt.create_date, 'DD/MM/YYYY') AS create_date, " +
                      " CASE WHEN mo.occ IS NULL THEN 0 ELSE mo.occ END AS occ, " +
                      " 'U' AS print, 'N' AS ald_print, 'N' AS status_sel, " +
                      " UPPER(CONCAT(u.name, u.firstname, CASE WHEN rs.step_short IS NULL THEN 'Nouveau' ELSE rs.step_short END, rfw.description)) AS raw_data " +
                      " FROM mother mt " +
                      " JOIN users u on u.id = " + @current_user.id.to_s +
                      " LEFT JOIN ref_status rs ON mt.status = rs.id " +
                      " LEFT JOIN ref_workflow rfw ON rfw.id = mt.wf_id " +
                      " LEFT JOIN moth_occ mo ON mt.id = mo.mother_id " +
                      " WHERE mt.partner_id = " + @current_user.partner.to_s +
                      # End partner check
                      " ORDER BY mt.id DESC LIMIT "+ ENV['SQL_LIMIT_SM'] +";"


    sql_query_workflow_mt = " SELECT rw.code AS rw_code, mw.start_id, rts.step AS st_step, mw.end_id, rte.step AS en_step, rts.handle_mother AS st_mt, rte.handle_mother AS en_mt FROM mod_workflow mw " +
                    				" JOIN ref_workflow rw ON rw.id = mw.wkf_id " +
                    				" JOIN ref_partner_workflow rpw ON rpw.wf_id = rw.id " +
                    				" JOIN ref_status rts ON rts.id = mw.start_id " +
                    				" JOIN ref_status rte ON rte.id = mw.end_id " +
                    				" WHERE rpw.partner_id = " + @current_user.partner.to_s +
                    				" AND (rts.handle_mother || rte.handle_mother) IN ('NY', 'YY') " +
                    				" ORDER BY mw.start_id, rw.code; "

    begin

      #flash[:info] = "Step save: " + params[:stepstep] + " /" + params.to_s + " //" + sql_query
      #@resultSet = ActiveRecord::Base.connection.execute(sql_query)
      @resultSet = ActiveRecord::Base.connection.exec_query(sql_query)

      @resultSetWorkflowMt = ActiveRecord::Base.connection.exec_query(sql_query_workflow_mt)

      @emptyResultSet = @resultSet.empty?

      @maxRowParamSM = " Cet écran récupère un maximum de " + ENV['SQL_LIMIT_SM'].to_s + " références. Si vous avez besoin de plus contactez-nous avec le code UPG259."
      @maxPrintConstEnv = ENV['MAX_PRINT'].to_s
      puts '@maxPrintConstEnv: ' + @maxPrintConstEnv.to_s
    end
  end

  # The result set retrieved here is different from Partner or Client.
  # The client need to break the list per partner as JsonArray
  # For the client we do use it like it is
  def load_partner_workflow
    sql_query = "SELECT rw.id AS rw_id, rw.code AS rw_code, rw.description AS rw_description, rpw.partner_id AS rpw_partner_id " +
                " FROM ref_workflow rw JOIN ref_partner_workflow rpw ON rpw.wf_id = rw.id " +
                " WHERE rpw.partner_id = " + @current_user.partner.to_s + " ORDER BY rw.id ASC;"
    begin

      @resultSetWorkflow = ActiveRecord::Base.connection.exec_query(sql_query)
    end
    rescue Exception => exc
       flash.now[:danger] = "Une erreur est survenue #{exec.message}"
  end


end
