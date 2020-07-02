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

  # This method need to be use everytime we have a string VARCHAR to had
  # It contains already the quote
  def get_safe_pg_wq(str)
    if str.nil? then
      return "NULL"
    elsif str == ''
      return "NULL"
    else
      return " TRIM('" + str.gsub(/"|'|!|>|;/, '') + "')"
    end
  end
  #Special no whitespace
  def get_safe_pg_wq_ns(str)
    if str.nil? then
      return "NULL"
    elsif str == ''
      return "NULL"
    else
      return " TRIM('" + str.gsub(/"|'|!|>|;|\s/, '') + "')"
    end
  end

  #Special no whitespace
  def get_safe_pg_number(str)
    if str.nil? then
      return "NULL"
    elsif str == ''
      return "NULL"
    else
      return str.gsub(/"|'|!|>|;|\s/, '')
    end
  end

end
