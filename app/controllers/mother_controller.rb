class MotherController < ApplicationController
  before_action :mgs_user_is_partner
  before_action :get_partner_company_name
  before_action :verify_authenticity_token, :only => [:createmother]

  def mothermng
    load_mother_dashboard()
    @getAuthToken = mgs_form_authenticity_token.to_s

    render 'mothermng'
  end


  def createmother
    if params[:auth_token] == session[:_mgs_csrf_token].to_s then

      puts 'We create a mother.'

      sql_query = "SELECT * FROM CLI_CRT_MOTHER(" + @current_user.id.to_s + ", CAST(" + params[:partner_id] + " AS SMALLINT));"
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


  private

  def load_mother_dashboard()

    sql_query = "SELECT 'X' AS mt_ref, 'X' AS c_crt, mt.id AS id, mt.secure, CASE WHEN rfw.code IS NULL THEN 'na' ELSE rfw.code END AS rfw_code, " +
                      " partner_id, creator_id, u.firstname AS u_firstname, u.client_ref AS u_client_ref, " +
                      " 'U' AS print, 'N' AS ald_print, " +
                      " UPPER(CONCAT(u.name, u.firstname)) AS raw_data " +
                      " FROM mother mt " +
                      " JOIN users u on u.id = " + @current_user.id.to_s +
                      " LEFT JOIN ref_workflow rfw ON rfw.id = mt.wf_id " +
                      " WHERE mt.partner_id = " + @current_user.partner.to_s +
                      # End partner check
                      " ORDER BY mt.id DESC LIMIT "+ ENV['SQL_LIMIT_SM'] +";"


    begin

      #flash[:info] = "Step save: " + params[:stepstep] + " /" + params.to_s + " //" + sql_query
      #@resultSet = ActiveRecord::Base.connection.execute(sql_query)
      @resultSet = ActiveRecord::Base.connection.exec_query(sql_query)
      @emptyResultSet = @resultSet.empty?

      @maxRowParamSM = " Cet écran récupère un maximum de " + ENV['SQL_LIMIT_SM'].to_s + " références. Si vous avez besoin de plus contactez-nous avec le code UPG259."
      @maxPrintConstEnv = ENV['MAX_PRINT'].to_s
      puts '@maxPrintConstEnv: ' + @maxPrintConstEnv.to_s
    end
  end


end
