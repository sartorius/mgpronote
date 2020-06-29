class ApplicationController < ActionController::Base
  include SessionsHelper

  private

  def get_partner_company_name
    unless !@resultSetCompany.nil?
      sql_query = "SELECT id, name, description, COALESCE(to_phone, 'NR') AS pphone, COALESCE(website, 'NR') AS pwebsite FROM ref_partner WHERE id = " + @current_user.partner.to_s + ";"
      begin
        #flash[:info] = "Step save: " + params[:stepstep] + " /" + params.to_s + " //" + sql_query
        #@resultSet = ActiveRecord::Base.connection.execute(sql_query)
        @resultSetCompany = ActiveRecord::Base.connection.exec_query(sql_query).cast_values
      end
    end
  end

end
