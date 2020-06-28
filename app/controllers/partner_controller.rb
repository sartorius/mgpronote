class PartnerController < ApplicationController
  before_action :mgs_user_is_partner
  before_action :get_partner_company_name


  def reception
    render 'reception'
  end

  def mainstatistics
    sql_query = "SELECT rs.step, COUNT(1) AS cnt_stat " +
                        " FROM barcode bc JOIN ref_status rs ON bc.status = rs.id " +
                        # You can use this to make sure barcode is link to the partner
                        " JOIN users u ON u.partner = bc.partner_id " +
                        " WHERE u.id = " + @current_user.id.to_s +
                        # End partner check
        	              " GROUP BY rs.step;"
    begin

      @resultSet = ActiveRecord::Base.connection.exec_query(sql_query)
      @emptyResultSet = @resultSet.empty?

      render 'mainstatistics'
    end
    rescue Exception => exc
       flash[:info] = "Une erreur est survenue #{exec.message}"
      render 'mainstatistics'
  end

  #One barcode manager
  def onebarcodemng
    render 'onebarcodemng'
  end

  # Get the next step BC
  def dashboard

    sql_query = "SELECT bc.id AS id, bc.ref_tag AS ref_tag, rs.step AS step, LPAD(bc.secret_code::CHAR(4), 4, '0') AS bsecret_code " +
                      " FROM barcode bc join ref_status rs on rs.id = bc.status " +
                      # You can use this to make sure barcode is link to the partner
                      " JOIN users u ON u.partner = bc.partner_id " +
                      " WHERE u.id = " + @current_user.id.to_s +
                      # End partner check
                      " ORDER BY bc.id ASC;"


    begin

      #flash[:info] = "Step save: " + params[:stepstep] + " /" + params.to_s + " //" + sql_query
      #@resultSet = ActiveRecord::Base.connection.execute(sql_query)
      @resultSet = ActiveRecord::Base.connection.exec_query(sql_query)
      @emptyResultSet = @resultSet.empty?

      render 'dashboard'
    end
    rescue Exception => exc
       flash[:info] = "Une erreur est survenue #{exec.message}"
      render 'dashboard'
  end

  def printtwelve

    sql_query = "SELECT bc.id AS id, bc.ref_tag AS ref_tag, rs.step AS step, LPAD(bc.secret_code::CHAR(4), 4, '0') AS bsecret_code " +
                      "FROM barcode bc join ref_status rs on rs.id = bc.status " +
                      # You can use this to make sure barcode is link to the partner
                      " JOIN users u ON u.partner = bc.partner_id " +
                      " WHERE u.id = " + @current_user.id.to_s +
                      # End partner check
                      " ORDER BY bc.id ASC LIMIT 12;"


    begin

      #flash[:info] = "Step save: " + params[:stepstep] + " /" + params.to_s + " //" + sql_query
      #@resultSet = ActiveRecord::Base.connection.execute(sql_query)
      @resultSet = ActiveRecord::Base.connection.exec_query(sql_query)
      @emptyResultSet = @resultSet.empty?

      render 'printtwelve'
    end
    rescue Exception => exc
       flash[:info] = "Une erreur est survenue #{exec.message}"
      render 'printtwelve'
  end

  def printnotrack
    render 'printnotrack'
  end
  
end
