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

  # Save the grouping action here
  # We actually save the last step here and notify
  def grpsavestep
    #puts '*** PURE <<<<<<<<<<< ' + params[:grpcheckcbpure]
    #puts '*** PURE ID <<<<<<<<<<< ' + params[:grpcheckcbpureid]
    #puts '*** EXT <<<<<<<<<<< ' + params[:grpcheckcbext]

    @list_pure_array = JSON.parse(params[:grpcheckcbpure])
    @list_pure_array_id = JSON.parse(params[:grpcheckcbpureid])
    @list_ext_array = JSON.parse(params[:grpcheckcbext])
    @stepTxt = params[:steptxt]

    #puts '--------------------------'
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

      sql_query_pure_id = "SELECT * FROM CLI_GRPSTEP_TAG_PURE ("+ pure_array_id +", CAST ("+ params[:stepstep] + " AS SMALLINT), TRIM('"+ params[:stepgeol] +"'), " + @current_user.id.to_s + ");"
      #puts 'Q Pure ID: ' + sql_query_pure_id

      @resultSetCallPureId = ActiveRecord::Base.connection.exec_query(sql_query_pure_id)


      # This retrieve notification
      puts 'Query has been launched correctly'
      @resultSetCallPureId.each do |notification|
        # conveniently, row is a hash
        # the keys are the fields, as you'd expect
        # the values are pre-built ruby primitives mapped from their corresponding field types in MySQL
        # Here's an otter: http://farm1.static.flickr.com/130/398077070_b8795d0ef3_b.jpg
        # <%= "#{val['id']}, #{val['name']}, #{val['age']}" %>
        # puts 'Notif: ' + notification['bc_id'].to_s +' / '+ notification['bc_sec'].to_s +' / '+ notification['name'].to_s +' / '+ notification['firstname'].to_s +' / '+ notification['to_addr'].to_s +' / '+ notification['step'].to_s +' / '+ notification['msg'].to_s
        puts 'Notif Pure: ' + notification.inspect
      end

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

      sql_query_ext = "SELECT * FROM CLI_GRPSTEP_TAG_EXT("+ ext_array +", CAST ("+ params[:stepstep] + " AS SMALLINT), TRIM('"+ params[:stepgeol] +"'), " + @current_user.id.to_s + ");"
      #puts 'Q EXT: ' + sql_query_ext

      @resultSetCallExt = ActiveRecord::Base.connection.exec_query(sql_query_ext)

      # This retrieve notification
      puts 'Query has been launched correctly'
      @resultSetCallExt.each do |notification|
        # conveniently, row is a hash
        # the keys are the fields, as you'd expect
        # the values are pre-built ruby primitives mapped from their corresponding field types in MySQL
        # Here's an otter: http://farm1.static.flickr.com/130/398077070_b8795d0ef3_b.jpg
        # <%= "#{val['id']}, #{val['name']}, #{val['age']}" %>
        # puts 'Notif: ' + notification['bc_id'].to_s +' / '+ notification['bc_sec'].to_s +' / '+ notification['name'].to_s +' / '+ notification['firstname'].to_s +' / '+ notification['to_addr'].to_s +' / '+ notification['step'].to_s +' / '+ notification['msg'].to_s
        puts 'Notif Ext: ' + notification.inspect
      end
    end

    render 'resultfinalgrpresultstep'

  end


  # GROUPING action retrieving future action and different checks
  def grpsavebc
    #puts 'PURE <<<<<<<<<<< ' + params[:grpcheckcbpure]
    #puts 'EXT <<<<<<<<<<< ' + params[:grpcheckcbext]

    @list_pure_array = JSON.parse(params[:grpcheckcbpure])
    @list_ext_array = JSON.parse(params[:grpcheckcbext])

    #puts '--------------------------'
    #puts 'PURE Size <<<<<<<<<<< ' + @list_pure_array.inspect
    #puts 'EXT Size <<<<<<<<<<< ' + @list_ext_array.inspect


    # Pure is the list the array with only pure MGS number
    # The list contains (id, secure)
    # PURE <<<<<<<<<<< [{"id":1,"secure":3301},{"id":2,"secure":4352}]
    pure_clause = ''
    start_coma = ''
    for pure_array in @list_pure_array do
      # puts 'pure_array id: ' + get_safe_pg_number(pure_array["id"].to_s) + '/secure: ' + get_safe_pg_number(pure_array["secure"].to_s)

      pure_clause = pure_clause + start_coma + gen_dual_not_safe_clause(get_safe_pg_number(pure_array["id"].to_s), get_safe_pg_number(pure_array["secure"].to_s))
      start_coma = ', '
    end

    # This contains only external preference
    # EXT <<<<<<<<<<< ["3222475413469","3263851322913"]
    ext_clause = ''
    start_coma = ''
    for ext_array in @list_ext_array do
      # puts 'ext_array value: ' + get_safe_pg_wq_ns(ext_array.to_s)
      ext_clause = ext_clause + start_coma + get_safe_pg_wq_ns(ext_array.to_s)
      start_coma = ', '
    end

    # Debug
    # puts 'pure_clause <<<<<<<<<<< ' + @list_pure_array.inspect
    # puts 'ext_clause <<<<<<<<<<< ' + @list_ext_array.inspect




    sql_query_join = " FROM mod_workflow mw JOIN wk_tag wt ON mw.wkf_id = wt.mwkf_id " +
    							               " AND mw.start_id = wt.current_step_id " +
    				                     " JOIN ref_status rtc ON rtc.id = wt.current_step_id " +
    				                     " JOIN ref_status rte ON rte.id = mw.end_id " +
                                 " JOIN barcode bc ON bc.id = wt.bc_id "

    count_of_list_pure_and_ext = 0
    # We need to check the content of the received list
    # Cut Qs is matchin only the list of PURE and EXT
    if (@list_pure_array.empty?) then
      #puts '>> 1'
      # No Pure
      sql_query_where_cut =        " AND (bc.ext_ref IN (" + ext_clause + ") " + ");"
      count_of_list_pure_and_ext = @list_ext_array.length

    elsif (@list_ext_array.empty?)
      #puts '>> 2'
      # No Ext
      sql_query_where_cut =        " AND ((bc.id, bc.secure) IN ( " + pure_clause  + ' )) ' + " ;"
      count_of_list_pure_and_ext = @list_pure_array.length

    else
      #puts '>> 3'
      # Both
      sql_query_where_cut =        " AND (((bc.id, bc.secure) IN ( " + pure_clause  + ' )) ' +
      			                       " OR (bc.ext_ref IN (" + ext_clause + ") " + "));"

      count_of_list_pure_and_ext = @list_pure_array.length + @list_ext_array.length
    end

    # Check Qs
    # This Q will retrieve the count of all FOUND elements (Condition: ALL_FOUND)
    sql_query_count = "SELECT COUNT(1) AS mg_count FROM barcode bc "

    # This Q will retrieve all distinct parameters (Condition: ALL_SAME_STATUS_AND_WF)
    # This Q Check there is no incident (Condition: NO_INCIDENT)
    sql_query_ck_col_distinct = "SELECT DISTINCT bc.under_incident, bc.status, bc.wf_id FROM barcode bc "


    # Clause w/ barcode table only
    sql_query_ck_where_bc_table_only = " WHERE bc.partner_id = " + @current_user.partner.to_s + sql_query_where_cut

    # This Q check there is no incident and only one status
    # We need to check if more than one row is returned and if there is no incident
    sql_query_check_distinct = sql_query_ck_col_distinct + sql_query_ck_where_bc_table_only
    @resultSetCheckOne = ActiveRecord::Base.connection.exec_query(sql_query_check_distinct)

    # This Q will check the condition ALL_FOUND
    # We count the number of barcode we found
    sql_query_check_count = sql_query_count + sql_query_ck_where_bc_table_only
    @resultSetCheckCount = ActiveRecord::Base.connection.exec_query(sql_query_check_count)






    # Control variables
    need_to_feedback_not_found = false;
    need_to_feedback_not_all_the_same = false;
    # This display if all are under incident
    @need_to_feedback_incident_exists = false;
    @need_to_feedback_delivery_pickup = false;
    @need_to_feedback_next_weight = false;

    all_check_are_passed = true;


    #If we found none
    if @resultSetCheckCount[0]['mg_count'].to_i == 0 then
      #puts 'Xroad 1 - we found: ' + @resultSetCheckCount[0]['mg_count'].to_s
      all_check_are_passed = false;

      # Nothing is found
      need_to_feedback_not_found = true;
    end


    # If we found less than expected
    if @resultSetCheckCount[0]['mg_count'].to_i < count_of_list_pure_and_ext then
      #puts 'Xroad 2 - we found: ' + @resultSetCheckCount[0]['mg_count'].to_s
      #puts 'Xroad 2 - versus: ' + count_of_list_pure_and_ext.to_s
      all_check_are_passed = false;

      # Some have not been found
      need_to_feedback_not_found = true;
    end


    # We check here if they are all the same or not
    # If they are all the same the distinc retrieve only one line
    if @resultSetCheckOne.length > 1 then
      #puts 'Xroad 3 - we found: ' + @resultSetCheckOne.length.to_s
      all_check_are_passed = false;

      # We have more than one line which is not possible that means the barcode are not the same
      need_to_feedback_not_all_the_same = true;
    end


    # We need to check if incident exists
    # If the result is empty we should not go in here
    if (!@resultSetCheckOne.empty?) && (@resultSetCheckOne[0]['under_incident'].to_s == 'true') then
      #puts 'Xroad 4 - we found: ' + @resultSetCheckOne[0]['under_incident'].to_s
      all_check_are_passed = false;

      # This is important if the result retrieve only one line (means all are the same)
      # But all are under incident then we need to tells the user that we have an issue.
      @need_to_feedback_incident_exists = true;
    end


    # Delivery Pickup Exception
    # We will avoid to goes to DB if previous check are KO
    # We go on category 2 check
    if all_check_are_passed then

        # This Q check the column with specific where clause
        # Need to return 2 lines max
        sql_query_ck_delivery_pickup_col = ' SELECT DISTINCT bc.type_pack AS bc_type_pack, rte.id AS end_step_id '
        # Clause with wk_tag table
        sql_query_where_ck_delivery_pickup =  " WHERE bc.partner_id = " + @current_user.partner.to_s +
                                              " AND bc.type_pack IN ('D', 'P') AND rte.id IN (2, 4) " +
                                              " AND bc.status = wt.current_step_id " + sql_query_where_cut

        sql_query_big_ck_delivery_pickup = sql_query_ck_delivery_pickup_col + sql_query_join + sql_query_where_ck_delivery_pickup
        @resultSetCheckDeliveryPickup = ActiveRecord::Base.connection.exec_query(sql_query_big_ck_delivery_pickup)

        # We check here if we have mix Delivery (D) and Pickup (P) with next steps 2 or 4
        # 2 is for Delivery Reception
        # 4 is for Pickup Enlèvement
        if @resultSetCheckDeliveryPickup.length > 2 then
          #puts 'Xroad 21 - we found: ' + @resultSetCheckDeliveryPickup.length.to_s
          all_check_are_passed = false;

          # We have more than one line which is not possible that means the barcode are not the same
          @need_to_feedback_delivery_pickup = true;
        end

    end

    # Weight Exception
    # We will avoid to goes to DB if previous check are KO
    # We go on category 3 check
    if all_check_are_passed then

        # This Q check the column with specific where clause
        # Need to return zero lines max
        sql_query_ck_weight_col = ' SELECT rte.id AS end_step_id '
        # Clause with wk_tag table
        sql_query_where_ck_weight =  " WHERE bc.partner_id = " + @current_user.partner.to_s +
                                              " AND rte.id IN (6) " +
                                              " AND bc.status = wt.current_step_id " + sql_query_where_cut

        sql_query_big_ck_weight = sql_query_ck_weight_col + sql_query_join + sql_query_where_ck_weight
        @resultSetCheckWeight = ActiveRecord::Base.connection.exec_query(sql_query_big_ck_weight)

        # We check here if we have mix Delivery (D) and Pickup (P) with next steps 2 or 4
        # 2 is for Delivery Reception
        # 4 is for Pickup Enlèvement
        if @resultSetCheckWeight.length > 0 then
          #puts 'Xroad 31 - we found: ' + @resultSetCheckWeight.length.to_s
          all_check_are_passed = false;

          # We have more than one line which is not possible that means the barcode are not the same
          @need_to_feedback_next_weight = true;
        end

    end





    ##### FROM HERE we need to pass or feedback
    # The variable need_to_feedback_not_all_the_same tells us if pass or not
    # Then we go on if else management

    if all_check_are_passed then
      #puts 'all_check_are_passed : EVERYTHING IS OK HERE'


      # This is general Q
      # We case type pack to avoid duplicate lines when actually only one end step is possible
      # Exception delivery pickup is handled before
      sql_query_col = " SELECT DISTINCT 0 AS bc_id,  bc.under_incident AS curr_inc, CASE WHEN rte.id IN (2, 4) THEN bc.type_pack ELSE 'N' END AS bc_type_pack, " +
                      " bc.category AS bc_category, rte.act_owner AS rse_act_owner,  rte.next_input_needed AS rse_next_input_needed, mw.wkf_id AS rwkf_id, " +
                      " mw.id AS mwkf_id, rtc.step AS curr_step,  rte.id AS end_step_id, rte.step AS end_step, rte.description AS end_step_desc"

      # Clause with wk_tag table
      sql_query_where =  " WHERE bc.partner_id = " + @current_user.partner.to_s +
                                   " AND bc.status = wt.current_step_id " + sql_query_where_cut

      # Everything is good here ! Enjoy
      # We need to access database for good results !
      sql_query_big_one = sql_query_col + sql_query_join + sql_query_where
      #puts 'Big one query: ' + sql_query_big_one.to_s

      # We retrieve actually next steps here !
      # Close to the end
      # Aja aja ! Fighting
      # The unique, the only one the best : resultSet !
      @resultSet = ActiveRecord::Base.connection.exec_query(sql_query_big_one)



      render 'resultgrpgetnext'
    else
      # We need to get feedback
      # We need to access database for feedback !
      if need_to_feedback_not_all_the_same || @need_to_feedback_incident_exists || @need_to_feedback_delivery_pickup || @need_to_feedback_next_weight then
        #puts 'Xroad 3 & 4 feedback'
        # We go on feedback mode here
        # We fill the result set for feedback
        debug_sql_query_ck_col = "SELECT bc.id, bc.secure, bc.ext_ref, bc.under_incident, bc.type_pack AS bc_type_pack, rs.step, rs.description AS rs_description, rw.code AS rw_code, rw.description AS rw_description "
        debug_sql_query_ck_col_from = " FROM barcode bc JOIN ref_status rs ON rs.id = bc.status JOIN ref_workflow rw on rw.id = bc.wf_id "
        # We still use the
        debug_sql_query_check_distinct = debug_sql_query_ck_col + debug_sql_query_ck_col_from  + sql_query_ck_where_bc_table_only
        @debugResultSetCheckOne = ActiveRecord::Base.connection.exec_query(debug_sql_query_check_distinct)
      else
        # We need to instanciate because the view will iterate
        @debugResultSetCheckOne = Array.new
      end
      # We need to tell the user which are not found
      if need_to_feedback_not_found then
          #puts 'Xroad 1 & 2 feedback'

          @pureResultSetNotFound = 0
          @extResultSetNotFound = 0

          # gen_union_pure_for_except_not_safe
          # gen_union_ext_for_except_not_safe
          # Here we need to identify missing lines
          pure_union = ''
          start_union = ''
          for pure_array in @list_pure_array do

            pure_union = pure_union + start_union + gen_union_pure_for_except_not_safe(get_safe_pg_number(pure_array["id"].to_s), get_safe_pg_number(pure_array["secure"].to_s))
            start_union = ' UNION '
          end

          ext_union = ''
          start_union = ''
          for ext_array in @list_ext_array do

            ext_union = ext_union + start_union + gen_union_ext_for_except_not_safe(get_safe_pg_wq_ns(ext_array.to_s))
            start_union = ' UNION '
          end

          #puts 'DEBUG: Pure not found: ' + pure_union
          #puts 'DEBUG: Ext not found: ' + ext_union

          # Missing line list
          # Be carefull if sometimes pure and not found are empty list
          if @list_pure_array.length == 0 then
            # We have no missing pure no need to check
            @pureResultSetNotFound = Array.new
          else
            sql_query_not_found_pure = pure_union + ' EXCEPT SELECT bc.id AS id, bc.secure AS secure FROM barcode bc ' + sql_query_ck_where_bc_table_only
            @pureResultSetNotFound = ActiveRecord::Base.connection.exec_query(sql_query_not_found_pure)
          end

          if @list_ext_array.length == 0 then
            # We have no missing ext no need to check
            @extResultSetNotFound = Array.new
          else
            sql_query_not_found_ext = ext_union + ' EXCEPT SELECT bc.ext_ref AS ext_ref FROM barcode bc ' + sql_query_ck_where_bc_table_only
            @extResultSetNotFound = ActiveRecord::Base.connection.exec_query(sql_query_not_found_ext)
          end




      end

      # Then we render to tell the user that something is KO
      render 'resultgrpgetnexterror'
    end

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


  # We actually save the last step here and notify
  def savestep

    @incidentDeclared = 'N'
    @stepcb = params[:stepcb]

    if (params[:stepcomment].nil?) || (params[:stepcomment] == '') then


          # We are not in incident case
          sql_query = "SELECT * FROM CLI_STEP_TAG ("+ params[:stepcbid] +", CAST ("+ params[:steprwfid] +" AS SMALLINT), CAST ("+ params[:stepstep] + " AS SMALLINT), TRIM('"+ params[:stepgeol] +"'), " +
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
        sql_query = "SELECT * FROM CLI_COM_TAG ("+ params[:stepcbid] +", " + @current_user.id.to_s + ", " + get_safe_pg_wq(params[:stepcomment]) + ");"
        @incidentDeclared = 'Y'
        @comment = params[:stepcomment]
    end


    begin
      #flash[:info] = "Step save: " + params[:stepstep] + " /" + params.to_s + " //" + sql_query
      @notificationResultSet = ActiveRecord::Base.connection.exec_query(sql_query)

      puts 'Query has been launched correctly'
      @notificationResultSet.each do |notification|
        # conveniently, row is a hash
        # the keys are the fields, as you'd expect
        # the values are pre-built ruby primitives mapped from their corresponding field types in MySQL
        # Here's an otter: http://farm1.static.flickr.com/130/398077070_b8795d0ef3_b.jpg
        # <%= "#{val['id']}, #{val['name']}, #{val['age']}" %>
        # puts 'Notif: ' + notification['bc_id'].to_s +' / '+ notification['bc_sec'].to_s +' / '+ notification['name'].to_s +' / '+ notification['firstname'].to_s +' / '+ notification['to_addr'].to_s +' / '+ notification['step'].to_s +' / '+ notification['msg'].to_s
        puts 'Notif: ' + notification.inspect
      end

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
