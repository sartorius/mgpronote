class BarcodeController < ApplicationController
  require 'json'
  before_action :mgs_user_is_partner, :except => [:checkbc, :checkstep]
  # skip_before_action :verify_authenticity_token, :only => [:savestep, :checkstep]

  # Get the next step BC
  def getnext
      render 'getnext'
  end

  # Get next grouping action
  def grpgetnext
      @grpIndicator = 'Y'
      render 'grpgetnext'
  end


  def grpsavebc
    puts 'PURE <<<<<<<<<<< ' + params[:grpcheckcbpure]
    puts 'EXT <<<<<<<<<<< ' + params[:grpcheckcbext]

    list_pure_array = JSON.parse(params[:grpcheckcbpure])
    list_ext_array = JSON.parse(params[:grpcheckcbext])

    puts '--------------------------'
    puts 'PURE Size <<<<<<<<<<< ' + list_pure_array.inspect
    puts 'EXT Size <<<<<<<<<<< ' + list_ext_array.inspect


    pure_clause = ''
    start_coma = ''
    for pure_array in list_pure_array do
      # puts 'pure_array id: ' + get_safe_pg_number(pure_array["id"].to_s) + '/secure: ' + get_safe_pg_number(pure_array["secure"].to_s)

      pure_clause = pure_clause + start_coma + gen_dual_not_safe_clause(get_safe_pg_number(pure_array["id"].to_s), get_safe_pg_number(pure_array["secure"].to_s))
      start_coma = ', '
    end

    ext_clause = ''
    start_coma = ''
    for ext_array in list_ext_array do
      # puts 'ext_array value: ' + get_safe_pg_wq_ns(ext_array.to_s)
      ext_clause = ext_clause + start_coma + get_safe_pg_wq_ns(ext_array.to_s)
      start_coma = ', '
    end


    # puts 'pure_clause <<<<<<<<<<< ' + list_pure_array.inspect
    # puts 'ext_clause <<<<<<<<<<< ' + list_ext_array.inspect


    sql_query_col = "SELECT wt.bc_id, bc.secure, bc.ext_ref, bc.under_incident, bc.type_pack AS bc_type_pack, bc.category AS bc_category, rte.act_owner AS rse_act_owner, " +
                    " rte.next_input_needed AS rse_next_input_needed, mw.wkf_id AS wkf_id, mw.id AS line_wkf_id, rtc.step AS current_step, " +
    		            " rte.id AS end_step_id, rte.step AS end_step, rte.description AS desc_end_step "



    sql_query_join = " FROM mod_workflow mw JOIN wk_tag wt ON mw.wkf_id = wt.mwkf_id " +
    							               " AND mw.start_id = wt.current_step_id " +
    				                     " JOIN ref_status rtc ON rtc.id = wt.current_step_id " +
    				                     " JOIN ref_status rte ON rte.id = mw.end_id " +
                                 " JOIN barcode bc ON bc.id = wt.bc_id "


    if (list_pure_array.empty?) then
      puts '>> 1'
      # No Pure
      sql_query_where_cut =        " AND (bc.ext_ref IN (" + ext_clause + ") " + ");"

    elsif (list_ext_array.empty?)
      puts '>> 2'
      # No Ext
      sql_query_where_cut =        " AND ((bc.id, bc.secure) IN ( " + pure_clause  + ' )) ' + " ;"
    else
      puts '>> 3'
      sql_query_where_cut =        " AND (((bc.id, bc.secure) IN ( " + pure_clause  + ' )) ' +
      			                       " OR (bc.ext_ref IN (" + ext_clause + ") " + "));"

    end

    sql_query_count = "SELECT COUNT(1) AS mg_count FROM barcode bc "

    sql_query_ck_col_distinct = "SELECT DISTINCT bc.under_incident, bc.status, bc.wf_id FROM barcode bc "

    #Get transition
    sql_query_where =             " WHERE bc.partner_id = " + @current_user.partner.to_s +
                                 " AND bc.status = wt.current_step_id " + sql_query_where_cut

    sql_query_ck_where =         " WHERE bc.partner_id = " + @current_user.partner.to_s + sql_query_where_cut

    # This query check there is no incident and only one status
    sql_query_check_one = sql_query_ck_col_distinct + sql_query_ck_where
    # We need to check if more than one row is returned and if there is no incident

    @resultSetCheckOne = ActiveRecord::Base.connection.exec_query(sql_query_check_one)
    sql_query_check_count = sql_query_count + sql_query_ck_where


    @resultSetCheckCount = ActiveRecord::Base.connection.exec_query(sql_query_check_count)

    #If all are under incident or different we raise an error.
    if (@resultSetCheckOne.length > 1) || (@resultSetCheckOne[0]['under_incident'].to_s == 'true') || (@resultSetCheckCount[0]['mg_count'].to_i != @resultSetCheckOne.length) then
      puts 'There are more than one status or one incident or several WF'
      # We go on feedback mode here
      debug_sql_query_ck_col = "SELECT bc.id, bc.secure, bc.ext_ref, bc.under_incident, rs.step, rs.description AS rs_description, rw.code AS rw_code, rw.description AS rw_description "
      debug_sql_query_ck_col_from = " FROM barcode bc JOIN ref_status rs ON rs.id = bc.status JOIN ref_workflow rw on rw.id = bc.wf_id "
      # We still use the
      debug_sql_query_check_one = debug_sql_query_ck_col + debug_sql_query_ck_col_from  + sql_query_ck_where

      @debugResultSetCheckOne = ActiveRecord::Base.connection.exec_query(debug_sql_query_check_one)


      @pureResultSetNotFound = 0
      @extResultSetNotFound = 0
      unless (@resultSetCheckCount[0]['mg_count'].to_i == @resultSetCheckOne.length)

        # gen_union_pure_for_except_not_safe
        # gen_union_ext_for_except_not_safe
        # Here we need to identify missing lines
        pure_union = ''
        start_union = ''
        for pure_array in list_pure_array do

          pure_union = pure_union + start_union + gen_union_pure_for_except_not_safe(get_safe_pg_number(pure_array["id"].to_s), get_safe_pg_number(pure_array["secure"].to_s))
          start_union = ' UNION '
        end

        ext_union = ''
        start_union = ''
        for ext_array in list_ext_array do

          ext_union = ext_union + start_union + gen_union_ext_for_except_not_safe(get_safe_pg_wq_ns(ext_array.to_s))
          start_union = ' UNION '
        end

        puts 'Pure not found: ' + pure_union
        puts 'Ext not found: ' + ext_union

        sql_query_not_found_pure = pure_union + ' EXCEPT SELECT bc.id AS id, bc.secure AS secure FROM barcode bc ' + sql_query_ck_where
        sql_query_not_found_ext = ext_union + ' EXCEPT SELECT bc.ext_ref AS ext_ref FROM barcode bc ' + sql_query_ck_where

        # Missing line list

        @pureResultSetNotFound = ActiveRecord::Base.connection.exec_query(sql_query_not_found_pure)
        @extResultSetNotFound = ActiveRecord::Base.connection.exec_query(sql_query_not_found_ext)

      end

      # Then we render to tell the user that something is KO
      render 'resultgrpgetnexterror'

    else
      puts 'Everything seems to be OK to grp evolution'

      redirect_to accessrightserror_path
    end


    sql_query_big_one = sql_query_col + sql_query_join + sql_query_where


    #Handle Weight !

  end


  # checkstep/savebc
  # Save Next step BC
  # Operation after read BC -- Need to review CLI_ACT_TAG must it create BC?
  def savebc
    @readBC = params[:checkcb]


    if (params[:checkcbid] == '') then
      #puts "<<<<<<<<< checkcbid is empty string"
      # checkcbid is empty when we have an external code because we cannot solve the MGS id
      sql_query = "SELECT * FROM CLI_ACT_TAG(0, CAST (0 AS SMALLINT), " + @current_user.id.to_s + ", " + @current_user.partner.to_s + ", " + get_safe_pg_wq(params[:checkcb]) + ", '" + params[:stepgeol] + "');"

    else
      # CAST (1 AS SMALLINT)
      sql_query = "SELECT * FROM CLI_ACT_TAG("+ params[:checkcbid] +", CAST("+ params[:checkcbsec] +" AS SMALLINT), "+ @current_user.id.to_s + ", " + @current_user.partner.to_s + ", " + get_safe_pg_wq(params[:checkcb]) + ", '" + params[:stepgeol] + "');"

    end


    begin

      #flash[:info] = "Step save: " + params[:stepstep] + " /" + params.to_s + " //" + sql_query
      #@resultSet = ActiveRecord::Base.connection.execute(sql_query)
      @resultSet = ActiveRecord::Base.connection.exec_query(sql_query)

      #puts '>>>>>>>>>>> ' + @resultSet.to_s

      if (@resultSet.nil?) || (@resultSet.empty?) then

        #We did not find the BC
         @cbToCheck = params[:checkcb];
         render 'resultcheckstep'
      else
        render 'savebc'
      end


    end
    rescue Exception => exc
       flash[:info] = "Une erreur est survenue #{exec.message}"
      render 'savebc'
  end


  def savestep

    @incidentDeclared = 'N'
    @stepcb = params[:stepcb]

    if (params[:stepcomment].nil?) || (params[:stepcomment] == '') then


          # We are not in incident case
          sql_query = "CALL CLI_STEP_TAG ("+ params[:stepcbid] +", CAST ("+ params[:steprwfid] +" AS SMALLINT), CAST ("+ params[:stepstep] + " AS SMALLINT), TRIM('"+ params[:stepgeol] +"'), " +
                          @current_user.id.to_s + ", " + get_safe_pg_number(params[:stepweight]) + ");"
          #flash[:info] = "Step save: " + params[:stepstep] + " /" + params.to_s + " //" + sql_query

          @refwkf = params[:steprwfid]
          @stepcbid = params[:stepcbid]
          @stepmwfid = params[:stepmwfid]
          @stepstep = params[:stepstep]
          @stepgeol = params[:stepgeol]
          @steptxt = params[:steptxt]
          @stepweight = params[:stepweight]

    else
        # We are in incident case
        sql_query = "CALL CLI_COM_TAG ("+ params[:stepcbid] +", " + @current_user.id.to_s + ", " + get_safe_pg_wq(params[:stepcomment]) + ");"
        @incidentDeclared = 'Y'
        @comment = params[:stepcomment]
    end


    begin
      #flash[:info] = "Step save: " + params[:stepstep] + " /" + params.to_s + " //" + sql_query
      ActiveRecord::Base.connection.execute(sql_query)
      @returnmessage = "L'opération a été correctement enregistrée"
      render 'resultsavestep'
    end
    rescue Exception => exc
       @returnmessage = "Une erreur est survenue #{exec.message}"
       render 'resultsavestep'
  end


  # Check BC Utils

  def checkbc
    render 'checkbc'
  end

  # checkstep/savebc
  # Save Next step BC
  # Operation after read BC
  def checkstep

=begin
    select bc.ref_tag,
          rtc.step,
          to_char(wt.create_date, 'DD/MM/YYYY HH24:MI UTC') AS create_date,
          rtc.description,
          wt.geo_l
          from wk_tag wt join barcode bc on bc.id = wt.bc_id
										join ref_status rtc on rtc.id = wt.current_step_id
							WHERE bc.ref_tag = '39287392' ORDER BY wt.id ASC;

=end
    # checkcbid is empty when we have an external code

    sql_query = "SELECT bc.id, bc.ref_tag, u.name, u.firstname, u.phone, rtc.step, to_char(wt.create_date, 'DD/MM/YYYY HH24:MI UTC') AS create_date, rtc.description, wt.geo_l, " +
                " wtc.comment AS com, ucom.name AS ucomname, ucom.firstname AS ucomfirstname, to_char(wtc.create_date, 'DD/MM/YYYY HH24:MI UTC') AS ucom_date " +
                " FROM wk_tag wt JOIN barcode bc on bc.id = wt.bc_id " +
                    " JOIN ref_status rtc on rtc.id = wt.current_step_id " +
                    " JOIN users u on u.id = wt.user_id " +
                    " LEFT JOIN wk_tag_com wtc ON wtc.wk_tag_id = wt.id " +
                    " LEFT JOIN users ucom ON wtc.user_id = ucom.id "

    if params[:checkcbid] == '' then
      #puts "<<<<<<<<< checkcbid is empty string"
      # checkcbid is empty when we have an external code because we cannot solve the MGS id
      sql_query = sql_query + " WHERE bc.ext_ref IN (" + get_safe_pg_wq_ns(params[:checkcb]) + ") ORDER BY wt.id ASC;"
    else
      #puts "<<<<<<<<< checkcbid is " + params[:checkcbid].to_s
      sql_query = sql_query + " WHERE bc.id = " + params[:checkcbid] + " AND bc.secure = " + params[:checkcbsec] + " ORDER BY wt.id ASC;"
    end




    begin

      #flash[:info] = "Step save: " + params[:stepstep] + " /" + params.to_s + " //" + sql_query
      #@resultSet = ActiveRecord::Base.connection.execute(sql_query)
      @resultSet = ActiveRecord::Base.connection.execute(sql_query)
      @cbToCheck = params[:checkcb];

      render 'resultcheckstep'
    end
    rescue Exception => exc
       flash[:info] = "Une erreur est survenue #{exec.message}"
       render 'resultcheckstep'
  end

  private


  def gen_union_pure_for_except_not_safe(i, j)
    return " SELECT " + i + " AS id, " + j + " AS secure "
  end

  def gen_union_ext_for_except_not_safe(i)
    return " SELECT " + i + " AS ext_ref "
  end

end
