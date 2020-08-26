class MotherController < ApplicationController
  before_action :mgs_user_is_partner
  before_action :get_partner_company_name

  def mothermng
    load_mother_dashboard()

    render 'mothermng'
  end


  private

  def load_mother_dashboard()

    sql_query = "SELECT id, secure, partner_id, creator_id " +
                      " FROM mother mt " +
                      " WHERE mt.partner_id = " + @current_user.partner.to_s +
                      # End partner check
                      " ORDER BY mt.id DESC LIMIT "+ ENV['SQL_LIMIT_SM'] +";"



    begin

      #flash[:info] = "Step save: " + params[:stepstep] + " /" + params.to_s + " //" + sql_query
      #@resultSet = ActiveRecord::Base.connection.execute(sql_query)
      @resultSet = ActiveRecord::Base.connection.exec_query(sql_query)
      @emptyResultSet = @resultSet.empty?

      @maxRowParamLG = " Cet écran récupère un maximum de " + ENV['SQL_LIMIT_SM'].to_s + " références. Si vous avez besoin de plus contactez-nous avec le code UPG263."
      @maxPrintConstEnv = ENV['MAX_PRINT'].to_s
      puts '@maxPrintConstEnv: ' + @maxPrintConstEnv.to_s
    end
  end


end
