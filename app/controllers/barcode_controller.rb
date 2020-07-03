class BarcodeController < ApplicationController
  before_action :mgs_user_is_partner, :except => [:checkbc, :checkstep]
  # skip_before_action :verify_authenticity_token, :only => [:savestep, :checkstep]

  # Get the next step BC
  def getnext
      render 'getnext'
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


end
