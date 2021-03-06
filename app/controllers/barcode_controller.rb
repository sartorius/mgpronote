class BarcodeController < ApplicationController
  require 'json'
  before_action :mgs_user_is_partner, :except => [:checkbc, :checkstephome, :apireadstepbc]
  skip_before_action :verify_authenticity_token, :only => [:apireadstepbc]


  # --------------------------------------- API ---------------------------------------

  def apireadstepbc

    puts "READ -------- " + params[:ref].to_s

    sql_query = "SELECT * FROM ref_partner WHERE id = 2;"
    @resultSet = ActiveRecord::Base.connection.exec_query(sql_query)

    render json: @resultSet.to_json
  end

  # --------------------------------------- GENERIC ---------------------------------------

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
    @do_we_need_grp_notify = false;

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
        # sendEmailNotification(to_addr, firstname_name, cb_code, status, msg)
        @do_we_need_grp_notify = true;
        # puts 'Notif Pure: ' + notification.inspect
        sendEmailNotification(notification['to_addr'].to_s,
                                notification['firstname'].to_s,
                                encodeMGS(notification['bc_id'].to_s, notification['bc_sec'].to_s),
                                notification['step'].to_s,
                                notification['msg'].to_s)
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
        # sendEmailNotification(to_addr, firstname_name, cb_code, status, msg)
        @do_we_need_grp_notify = true;
        # puts 'Notif Ext: ' + notification.inspect
        sendEmailNotification(notification['to_addr'].to_s,
                                notification['firstname'].to_s,
                                encodeMGS(notification['bc_id'].to_s, notification['bc_sec'].to_s),
                                notification['step'].to_s,
                                notification['msg'].to_s)
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
    @list_mother_array = JSON.parse(params[:grpcheckcbmother])
    @list_mother_array_raw = JSON.parse(params[:grpcheckcbmotherraw])

    #puts '--------------------------'
    puts 'PURE Size <<<<<<<<<<< ' + @list_pure_array.inspect
    puts 'EXT Size <<<<<<<<<<< ' + @list_ext_array.inspect
    puts 'MOTHER Size <<<<<<<<<<< ' + @list_mother_array.inspect

    # We need to make sure we have only one mother


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

    mother_clause = ''
    start_coma = ''
    for mother_array in @list_mother_array do
      # puts 'pure_array id: ' + get_safe_pg_number(pure_array["id"].to_s) + '/secure: ' + get_safe_pg_number(pure_array["secure"].to_s)

      mother_clause = mother_clause + start_coma + gen_dual_not_safe_clause(get_safe_pg_number(mother_array["id"].to_s), get_safe_pg_number(mother_array["secure"].to_s))
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

    # Clause w/ unexpected mother
    sql_query_ck_where_bc_unexpected_mt = " WHERE bc.partner_id = " + @current_user.partner.to_s + " AND bc.mother_id IS NOT NULL " + sql_query_where_cut

    # This Q check there is no incident and only one status
    # We need to check if more than one row is returned and if there is no incident
    sql_query_check_distinct = sql_query_ck_col_distinct + sql_query_ck_where_bc_table_only
    @resultSetCheckOne = ActiveRecord::Base.connection.exec_query(sql_query_check_distinct)

    # This Q will check the condition ALL_FOUND
    # We count the number of barcode we found
    sql_query_check_count = sql_query_count + sql_query_ck_where_bc_table_only
    @resultSetCheckCount = ActiveRecord::Base.connection.exec_query(sql_query_check_count)

    # MOTHER SQL
    sql_query_where_mother_cut = " AND ((mt.id, mt.secure) IN ( " + mother_clause  + ' )) '

    # We should get zero to be safe has no mother need to be involved in simple grouping
    sql_query_check_count_unexpected_mt = sql_query_count + sql_query_ck_where_bc_unexpected_mt
    @resultSetCheckCountUnexpectedMt = ActiveRecord::Base.connection.exec_query(sql_query_check_count_unexpected_mt)


    # Are we in associating to Mother ?
    are_we_associating_to_mother = false;

    # Control variables
    need_to_feedback_not_found = false;
    need_to_feedback_not_all_the_same = false;
    # This display if all are under incident
    @need_to_feedback_incident_exists = false;

    # This is not need to be checked if Mother
    @need_to_feedback_next_weight = false;
    # This is not need to be checked if Mother
    @need_to_feedback_next_terminated = false;

    # This need to be blocked : if at least one has a mother and we try to evolve it separatly from his/her mother
    @need_to_feedback_unexpected_mother = false;

    # Mother check
    @need_to_feedback_more_than_one_mother = false;
    @need_to_feedback_mother_not_found = false;
    @need_to_feedback_mother_not_same_wf = false;
    @need_to_feedback_next_not_mother = false;

    all_check_are_passed = true;



    # START the checks **************************************************************

    if @list_mother_array.size > 1 then

      #puts 'Xroad 0 - we found: ' + @list_mother_array.size.to_s
      all_check_are_passed = false;

      # There are several mother and we need to let the user know
      @need_to_feedback_more_than_one_mother = true;
    elsif (@list_mother_array.size == 1) then
      # ----------------- We are in mother case
      are_we_associating_to_mother = true;
    end


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

    # We need to check if we find the mother or no
    if !(@list_mother_array.empty?) then


      # Check Mother
      # This Q will retrieve the count of all FOUND elements (Condition: ALL_FOUND)
      sql_query_mother_count = "SELECT COUNT(1) AS mother_count FROM mother mt "
      # Clause w/ barcode table only
      sql_query_ck_where_mother_table_only = " WHERE mt.partner_id = " + @current_user.partner.to_s + sql_query_where_mother_cut + " ;"

      sql_query_check_mother_count = sql_query_mother_count + sql_query_ck_where_mother_table_only
      @resultSetCheckMotherCount = ActiveRecord::Base.connection.exec_query(sql_query_check_mother_count)

      puts 'XMroad 2 - we found: ' + @resultSetCheckMotherCount[0]['mother_count'].to_s
      if @resultSetCheckMotherCount[0]['mother_count'].to_i == 0 then
        #puts 'XMroad 2 - we found: ' + @resultSetCheckMotherCount[0]['mother_count'].to_s
        all_check_are_passed = false;

        # Some have not been found
        @need_to_feedback_mother_not_found = true;
      end
    end





    # We check here if they are all the same or not
    # If they are all the same the distinct retrieve only one line
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

    # We check here unexpected mother
    if (@resultSetCheckCountUnexpectedMt[0]['mg_count'].to_i > 0) && !(are_we_associating_to_mother) then
      #puts 'Xroad 4 - we found: ' + @resultSetCheckOne[0]['under_incident'].to_s
      all_check_are_passed = false;

      # This is important if the result retrieve only one line (means all are the same)
      # But all are under incident then we need to tells the user that we have an issue.
      @need_to_feedback_unexpected_mother = true;
    end



    # Weight Exception
    # We will avoid to goes to DB if previous check are KO
    # We go on category 3 check
    if all_check_are_passed and !(are_we_associating_to_mother) then

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
        # 4 is for Pickup Enl??vement
        if @resultSetCheckWeight.length > 0 then
          #puts 'Xroad 31 - we found: ' + @resultSetCheckWeight.length.to_s
          all_check_are_passed = false;

          # We have more than one line which is not possible that means the barcode are not the same
          @need_to_feedback_next_weight = true;
        end

    end

    # Terminated Exception
    # We will avoid to goes to DB if previous check are KO
    # We go on category 312 check
    if all_check_are_passed and !(are_we_associating_to_mother) then

        # This Q check the column with specific where clause
        # Need to return zero lines max
        sql_query_ck_terminated_col = ' SELECT rte.id AS end_step_id '
        # Clause with terminated
        sql_query_where_ck_terminated =  " WHERE bc.partner_id = " + @current_user.partner.to_s +
                                              " AND rte.id IN (-1) " +
                                              " AND bc.status = wt.current_step_id " + sql_query_where_cut

        sql_query_big_ck_terminated = sql_query_ck_terminated_col + sql_query_join + sql_query_where_ck_terminated
        @resultSetCheckTerminated = ActiveRecord::Base.connection.exec_query(sql_query_big_ck_terminated)

        # We check here if next step is terminated
        if @resultSetCheckTerminated.length > 0 then
          #puts 'Xroad 312 - we found: ' + @resultSetCheckTerminated.length.to_s
          all_check_are_passed = false;

          # We have more than one line which is not possible that means the barcode are not the same
          @need_to_feedback_next_terminated = true;
        end

    end


    if all_check_are_passed and (are_we_associating_to_mother) then
      # This Q check the column with specific where clause
      # Need to return zero lines max
      sql_query_ck_mother_not_same_wf_col = ' SELECT DISTINCT bc.wf_id FROM barcode bc JOIN mother mt ON mt.wf_id = bc.wf_id '
      # Clause with wk_tag table
      sql_query_where_ck_not_same_wf =  " WHERE bc.partner_id = " + @current_user.partner.to_s +
                                                            sql_query_where_mother_cut + " " + sql_query_where_cut


      sql_query_big_ck_not_same_moth = sql_query_ck_mother_not_same_wf_col + sql_query_where_ck_not_same_wf
      @resultSetCheckNotSameMother = ActiveRecord::Base.connection.exec_query(sql_query_big_ck_not_same_moth)


      # We check here if we have mix Delivery (D) and Pickup (P) with next steps 2 or 4
      # 2 is for Delivery Reception
      # 4 is for Pickup Enl??vement
      if @resultSetCheckNotSameMother.length == 0 then
        #puts 'Xroad 31 - we found: ' + @resultSetCheckWeight.length.to_s
        all_check_are_passed = false;

        # We have more than one line which is not possible that means the barcode are not the same
        @need_to_feedback_mother_not_same_wf = true;
      end
    end


    # Mother next Exception
    # We will avoid to goes to DB if previous check are KO
    # We are in case of mother we need to check next step
    if all_check_are_passed and (are_we_associating_to_mother) then

      # This Q check the column with specific where clause
      # Need to return zero lines max
      sql_query_ck_next_moth_col = ' SELECT DISTINCT rte.id AS end_step_id '
      # Clause with wk_tag table
      sql_query_where_ck_next_moth =  " WHERE bc.partner_id = " + @current_user.partner.to_s +
                                            " AND rte.handle_mother = 'Y' " +
                                            " AND bc.status = wt.current_step_id " + sql_query_where_cut

      sql_query_big_ck_next_moth = sql_query_ck_next_moth_col + sql_query_join + sql_query_where_ck_next_moth
      @resultSetCheckNextIsMother = ActiveRecord::Base.connection.exec_query(sql_query_big_ck_next_moth)

      # We check here if we have mix Delivery (D) and Pickup (P) with next steps 2 or 4
      # 2 is for Delivery Reception
      # 4 is for Pickup Enl??vement
      puts 'XMroad 31 - we found: ' + @resultSetCheckNextIsMother.length.to_s
      if @resultSetCheckNextIsMother.length < 1 then
        #puts 'Xroad 31 - we found: ' + @resultSetCheckWeight.length.to_s
        all_check_are_passed = false;

        # We have more than one line which is not possible that means the barcode are not the same
        @need_to_feedback_next_not_mother = true;
      end


    end


    ##### FROM HERE we need to pass or feedback
    # The variable need_to_feedback_not_all_the_same tells us if pass or not
    # Then we go on if else management

    # WE ARE IN STANDARD GROUPING NO ASSOCIATION
    if all_check_are_passed and !(are_we_associating_to_mother) then
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
    elsif all_check_are_passed then
      # We are in association

      render 'resultgrpassociation'

    else
      # We need to get feedback
      # We need to access database for feedback !
      if need_to_feedback_not_all_the_same || @need_to_feedback_incident_exists || @need_to_feedback_next_weight || @need_to_feedback_next_terminated || @need_to_feedback_unexpected_mother then
        #puts 'Xroad 3 & 4 feedback'
        # We go on feedback mode here
        # We fill the result set for feedback
        debug_sql_query_ck_col = "SELECT bc.id, bc.secure, bc.ext_ref, bc.under_incident, bc.type_pack AS bc_type_pack, bc.mother_ref AS bc_mother_ref, rs.step, rs.description AS rs_description, rw.code AS rw_code, rw.description AS rw_description "
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

    @verificationIsOK = true

    @paymentUpdate = false
    @comment = ''

    if (!params[:steppaid].nil?) && (params[:steppaid] == 'Y') then
      puts 'You clicked on PAID'

      @paymentUpdate = true
      @comment = 'Mise ?? jour: paiement valid??'
      # We are in payment validation
      sql_query = "SELECT * FROM CLI_PAYMT_TAG ("+ params[:stepcbid] +", 'P', " + @current_user.id.to_s + ", '" + @comment.to_s + "');"
    elsif (!params[:steppaid].nil?) && (params[:steppaid] == 'N') then
      puts 'You clicked on UNPAID'

      @paymentUpdate = true
      @comment = 'Mise ?? jour: paiement invalid??'
      # We are in payment validation
      sql_query = "SELECT * FROM CLI_PAYMT_TAG ("+ params[:stepcbid] +", 'N', " + @current_user.id.to_s + ", '" + @comment.to_s + "');"
    elsif (params[:stepcomment].nil?) || (params[:stepcomment] == '') then
          puts 'savestep Check point 2'

          # We save in gram
          unless params[:stepweight].nil? || (params[:stepweight] == '')
            stepWeightKilo = (params[:stepweight].to_s.gsub(/,/, '.').to_f * 1000).to_i
          end

          # In case the step is verification of the code
          # We do the verification code here
          unless params[:verif].nil? || (params[:verif] == '')
            sql_query_verif = "SELECT * FROM CLI_VERIF_CODE (" + params[:stepcbid] + ", CAST (" + get_safe_pg_number(params[:verif]) + ' AS SMALLINT));'
            @checkVerifResultSet = ActiveRecord::Base.connection.exec_query(sql_query_verif)

            # M000030TG/9178
            # puts 'inspect: ' + @checkVerifResultSet.inspect
            # puts 'row: ' + @checkVerifResultSet[0]['cli_verif_code'].to_s

            unless @checkVerifResultSet[0]['cli_verif_code'].to_i == 0 then
              # Check has failed
              @verificationIsOK = false
            end
          end

          # We are not in incident case
          sql_query = "SELECT * FROM CLI_STEP_TAG ("+ params[:stepcbid] +", CAST ("+ params[:steprwfid] +" AS SMALLINT), CAST ("+ params[:stepstep] + " AS SMALLINT), TRIM('"+ params[:stepgeol] +"'), " +
                          @current_user.id.to_s + ", " + get_safe_pg_number(stepWeightKilo.to_s) + ");"
          #flash[:info] = "Step save: " + params[:stepstep] + " /" + params.to_s + " //" + sql_query

          @steptxt = params[:steptxt]
          @refwkf = params[:steprwfid]
          @stepcbid = params[:stepcbid]
          @stepmwfid = params[:stepmwfid]
          @stepstep = params[:stepstep]
          @stepgeol = params[:stepgeol]
          @stepweight = params[:stepweight]

    else
        puts 'savestep Check point 3'
        # We are in incident case
        sql_query = "SELECT * FROM CLI_COM_TAG ("+ params[:stepcbid] +", " + @current_user.id.to_s + ", " + get_safe_pg_wq(params[:stepcomment]) + ");"
        @incidentDeclared = 'Y'
        @comment = params[:stepcomment]
    end


    begin

      unless !@verificationIsOK then
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
          # sendEmailNotification(to_addr, firstname_name, cb_code, status, msg)
          # Notif Pure: {"bc_id"=>41, "bc_sec"=>9710, "name"=>"De la Cannelle", "firstname"=>"Tsiky", "to_addr"=>"tsiky.d@gmail.com", "step"=>"Arriv?? Tana", "msg"=>"Le paquet est arriv?? ?? Tana. Il est en formalit?? entr??e de territoire."}
          # puts 'Notif for: ' + encodeMGS(notification['bc_id'].to_s, notification['bc_sec'].to_s)
          # puts 'Notif: ' + notification.inspect
          sendEmailNotification(notification['to_addr'].to_s,
                                  notification['firstname'].to_s,
                                  encodeMGS(notification['bc_id'].to_s, notification['bc_sec'].to_s),
                                  notification['step'].to_s,
                                  notification['msg'].to_s)
        end


        @returnmessage = "L'op??ration a ??t?? correctement enregistr??e"

      else
        # Verification code is KO
        flash.now[:danger] = 'Navr?? ! Echec v??rification code. Ne peux ??tre remis. Veuillez re-essayer'
        @returnmessage = 'Code de v??rification invalide'
        @steptxt = 'Echec: ' + @steptxt
      end

      render 'resultsavestep'
    end
  end


  # Check BC Utils

  def checkbc
    @checkBCIndicator = 1
    render 'checkbc'
  end


  def checkstephome
    @checkBCFromHome = 1
    checkstep

  end

  # checkstep/savebc
  # Save Next step BC
  # Operation after read BC
  def checkstep
    # checkcbid is empty when we have an external code

    sql_query = "SELECT bc.id, bc.ref_tag, u.id AS uid, u.name, u.firstname, u.client_ref AS uclient_ref, u.phone, rtc.step, to_char(wt.create_date, 'DD/MM/YYYY HH24:MI UTC') AS create_date, rtc.description, wt.geo_l, " +
                " wtc.comment AS com, ucom.name AS ucomname, ucom.firstname AS ucomfirstname, ucom.id AS ucomid, ucom.client_ref AS ucomclient_ref, to_char(wtc.create_date, 'DD/MM/YYYY HH24:MI UTC') AS ucom_date " +
                " FROM wk_tag wt JOIN barcode bc on bc.id = wt.bc_id " +
                    " JOIN ref_status rtc on rtc.id = wt.current_step_id " +
                    " JOIN users u on u.id = wt.user_id " +
                    " LEFT JOIN wk_tag_com wtc ON wtc.wk_tag_id = wt.id " +
                    " LEFT JOIN users ucom ON wtc.user_id = ucom.id "

    sql_query_param = "SELECT bc.id, bc.ref_tag, u.id AS uid, u.name, u.firstname, u.client_ref AS uclient_ref, wp.comment AS wp_comment, to_char(wp.create_date, 'DD/MM/YYYY HH24:MI UTC') AS create_date FROM wk_param wp JOIN barcode bc on bc.id = wp.bc_id " +
                      " JOIN users u on u.id = wp.user_id "

    if params[:checkcbid] == '' then
      #puts "<<<<<<<<< checkcbid is empty string"
      # checkcbid is empty when we have an external code because we cannot solve the MGS id
      sql_where_clause = " WHERE bc.ext_ref IN (" + get_safe_pg_wq_ns(params[:checkcb]) + " ) "
      sql_query = sql_query + sql_where_clause + " ORDER BY wt.id ASC;"
      sql_query_param = sql_query_param + sql_where_clause + " ORDER BY wp.id ASC;"
    else
      #puts "<<<<<<<<< checkcbid is " + params[:checkcbid].to_s
      sql_where_clause = " WHERE bc.id = " + params[:checkcbid] + " AND bc.secure = " + params[:checkcbsec]
      sql_query = sql_query + sql_where_clause + " ORDER BY wt.id ASC;"
      sql_query_param = sql_query_param + sql_where_clause + " ORDER BY wp.id ASC;"
    end




    begin

      #flash[:info] = "Step save: " + params[:stepstep] + " /" + params.to_s + " //" + sql_query
      #@resultSet = ActiveRecord::Base.connection.execute(sql_query)
      @resultSet = ActiveRecord::Base.connection.exec_query(sql_query)
      @resultSetParam = ActiveRecord::Base.connection.exec_query(sql_query_param)

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
