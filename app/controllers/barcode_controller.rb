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


    if params[:checkcbid] == '' then
      #puts "<<<<<<<<< checkcbid is empty string"
      # checkcbid is empty when we have an external code because we cannot solve the MGS id
      sql_query = "SELECT * FROM CLI_ACT_TAG(0, CAST (0 AS SMALLINT), " + @current_user.id.to_s + ", " + @current_user.partner.to_s + ", '" + params[:checkcb] + "', '" + params[:stepgeol] + "');"

    else
      # CAST (1 AS SMALLINT)
      sql_query = "SELECT * FROM CLI_ACT_TAG("+ params[:checkcbid] +", CAST("+ params[:checkcbsec] +" AS SMALLINT), "+ @current_user.id.to_s + ", " + @current_user.partner.to_s + ", '" + params[:checkcb] + "', '" + params[:stepgeol] + "');"

    end


    begin

      #flash[:info] = "Step save: " + params[:stepstep] + " /" + params.to_s + " //" + sql_query
      #@resultSet = ActiveRecord::Base.connection.execute(sql_query)
      @resultSet = ActiveRecord::Base.connection.execute(sql_query)

      render 'savebc'
    end
    rescue Exception => exc
       flash[:info] = "Une erreur est survenue #{exec.message}"
    render 'savebc'
  end


  def savestep

    sql_query = "CALL CLI_STEP_TAG ("+ params[:stepcbid] +", CAST ("+ params[:steprwfid] +" AS SMALLINT), CAST ("+ params[:stepstep] +" AS SMALLINT), TRIM('"+ params[:stepgeol] +"'), " + @current_user.id.to_s + ");"
    #flash[:info] = "Step save: " + params[:stepstep] + " /" + params.to_s + " //" + sql_query

    @refwkf = params[:steprwfid]
    @stepcb = params[:stepcb]
    @stepcbid = params[:stepcbid]
    @stepmwfid = params[:stepmwfid]
    @stepstep = params[:stepstep]
    @stepgeol = params[:stepgeol]


    @steptxt = params[:steptxt]


    begin
      #flash[:info] = "Step save: " + params[:stepstep] + " /" + params.to_s + " //" + sql_query
      ActiveRecord::Base.connection.execute(sql_query)
      @returnmessage = "L'étape a été correctement enregistrée"
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
    if params[:checkcbid] == '' then
      #puts "<<<<<<<<< checkcbid is empty string"
      # checkcbid is empty when we have an external code because we cannot solve the MGS id
      sql_query = "select bc.id, bc.ref_tag, u.name, u.firstname, u.phone, rtc.step, to_char(wt.create_date, 'DD/MM/YYYY HH24:MI UTC') AS create_date, rtc.description, wt.geo_l from wk_tag wt join barcode bc on bc.id = wt.bc_id " +
  										" join ref_status rtc on rtc.id = wt.current_step_id " +
                      " join users u on u.id = wt.user_id " +
                      " WHERE bc.ref_tag IN ('" + params[:checkcb] + "') ORDER BY wt.id ASC;"
    else
      #puts "<<<<<<<<< checkcbid is " + params[:checkcbid].to_s
      sql_query = "select bc.id, bc.ref_tag, u.name, u.firstname, u.phone, rtc.step, to_char(wt.create_date, 'DD/MM/YYYY HH24:MI UTC') AS create_date, rtc.description, wt.geo_l from wk_tag wt join barcode bc on bc.id = wt.bc_id " +
  										" join ref_status rtc on rtc.id = wt.current_step_id " +
                      " join users u on u.id = wt.user_id " +
                      " WHERE bc.id = " + params[:checkcbid] + " AND bc.secure = " + params[:checkcbsec] + " ORDER BY wt.id ASC;"
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
