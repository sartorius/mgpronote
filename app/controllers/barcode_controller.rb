class BarcodeController < ApplicationController
  before_action :mgs_user_is_partner, :except => [:checkbc, :checkstep]
  # skip_before_action :verify_authenticity_token, :only => [:savestep, :checkstep]

  # Get the next step BC
  def getnext
      render 'getnext'
  end

  # Save Next step BC
  def savebc
    @readBC = params[:checkcb]

    sql_query = "SELECT * FROM CLI_ACT_TAG(" + @current_user.id.to_s + ", " + @current_user.partner.to_s + ", '" + params[:checkcb] + "', '" + params[:stepgeol] + "');"

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

    # CAST (1 AS SMALLINT)
    sql_query = "CALL CLI_STEP_TAG ("+ params[:stepcbid] +", CAST ("+ params[:steprwfid] +" AS SMALLINT), CAST ("+ params[:stepstep] +" AS SMALLINT), TRIM('"+ params[:stepgeol] +"'));"

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

    sql_query = "select bc.ref_tag, rtc.step, to_char(wt.create_date, 'DD/MM/YYYY HH24:MI UTC') AS create_date, rtc.description, wt.geo_l from wk_tag wt join barcode bc on bc.id = wt.bc_id " +
										" join ref_status rtc on rtc.id = wt.current_step_id " +
                    " WHERE bc.ref_tag IN ('" + params[:checkcb] + "') ORDER BY wt.id ASC;"


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
