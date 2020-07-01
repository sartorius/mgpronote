class PersoreselController < ApplicationController
  before_action :mgs_logged_in_user


  def addaddress
    #We do the transaction here then we go on seeone

    sql_query = "CALL CLI_STEP_ADDR_TAG ("+ params[:checkcbid] +", CAST ("+ params[:steprwfid] +" AS SMALLINT), TRIM('"+ params[:stepgeol] + "'), " +
                " '" + params[:mgaddextref] + "', '" + params[:mgaddtname] + "', '" + params[:mgaddtfname] + "', '" + params[:mgaddtphone] + "', " + @current_user.id.to_s + ");"

    puts 'sql_query: ' + sql_query

    begin

      ActiveRecord::Base.connection.exec_query(sql_query)

      message  = "Les informations ont été correctement enregistrés."
      flash.now[:success] = message

      seeone
    end
    rescue Exception => exc
       message  = "Navré ! Une erreur GDJ90 est survenue #{exec.message}"
       flash.now[:danger] = message

       seeone

  end


  def seeone
    sql_query = "SELECT bc.id AS id, bc.secure, bc.to_name AS tname, bc.to_firstname AS tfirstname, " +
                		" bc.to_phone AS tphone, bc.ext_ref, bc.secret_code AS secret_code, rp.name AS part_name,  " +
                		" to_char(bc.create_date, 'DD/MM/YYYY HH24:MI UTC') AS create_date, " +
                		" rs.id AS step_id, rs.step, rs.description, rs.input_needed, " +
                		" uo.name AS oname, uo.firstname AS ofirstname, uo.email AS oemail, uo.phone AS ophone, " +
                		" uc.name AS cname, uc.firstname AS cfirstname, uc.email AS cemail, uc.phone AS cphone " +
                		" FROM barcode bc JOIN ref_partner rp ON rp.id = bc.partner_id " +
                  		"JOIN ref_status rs ON rs.id = bc.status " +
                  		"JOIN users uo ON uo.id = bc.owner_id " +
                  		"JOIN users uc ON uc.id = bc.creator_id " +
                  		" WHERE bc.id = " + params[:checkcbid] +
                  		" AND bc.secure = " + params[:checkcbsec] +
                  		" AND bc.owner_id = " + @current_user.id.to_s + ";"

    begin

      #flash[:info] = "Step save: " + params[:stepstep] + " /" + params.to_s + " //" + sql_query
      #@resultSet = ActiveRecord::Base.connection.execute(sql_query)
      @resultSet = ActiveRecord::Base.connection.exec_query(sql_query)
      @emptyResultSet = @resultSet.empty?

      render 'seeone'
    end
    rescue Exception => exc
       flash[:info] = "Une erreur est survenue #{exec.message}"
      render 'seeone'
  end

  # Get the next step BC
  def dashboard

    sql_query = "SELECT bc.id AS id, bc.ref_tag AS ref_tag, rs.step AS step, LPAD(bc.secure::CHAR(4), 4, '0') AS secure, LPAD(bc.secret_code::CHAR(4), 4, '0') AS bsecret_code, " +
                      " rp.name AS part_name, bc.status, rp.to_phone AS part_phone, to_char(bc.create_date, 'DD/MM/YYYY') AS create_date, DATE_PART('day', NOW() - bc.create_date) AS diff_days " +
                      " FROM barcode bc join ref_status rs on rs.id = bc.status " +
                      # You can use this to make sure barcode is link to the owner id
                      " JOIN users u ON u.id = bc.owner_id " +
                      " JOIN ref_partner rp ON rp.id = bc.partner_id " +
                      " WHERE u.id = " + @current_user.id.to_s +
                      # End partner check
                      " ORDER BY bc.id DESC;"


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

end
