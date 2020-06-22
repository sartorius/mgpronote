class PartnerController < ApplicationController
  # Get the next step BC
  def dashboard

    sql_query = "SELECT bc.id AS id, bc.ref_tag AS ref_tag, rs.step AS step, LPAD(bc.secret_code::CHAR(4), 4, '0') AS bsecret_code, " +
                      "bc.to_email AS dest_email " +
                      "FROM barcode bc join ref_status rs on rs.id = bc.status ORDER BY bc.id ASC;"


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

    sql_query = "SELECT bc.id AS id, bc.ref_tag AS ref_tag, rs.step AS step, LPAD(bc.secret_code::CHAR(4), 4, '0') AS bsecret_code, " +
                      "bc.to_email AS dest_email " +
                      "FROM barcode bc join ref_status rs on rs.id = bc.status ORDER BY bc.id ASC LIMIT 12;"


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
end
