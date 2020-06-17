class BarcodeController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:savestep]

  def readbc
    render 'readbc'
  end

  def savestep

    sql_query = "INSERT INTO tag (bc, step, geo) VALUES ('" + params[:stepcb] + "', '" +
                                    params[:stepstep] + "', '" +
                                    params[:stepgeol] + "');"




    @stepcb = params[:stepcb]
    @stepstep = params[:stepstep]
    @stepgeol = params[:stepgeol]

    begin
      #flash[:info] = "Step save: " + params[:stepstep] + " /" + params.to_s + " //" + sql_query
      ActiveRecord::Base.connection.execute(sql_query)
      @returnmessage = "L'étape a été correctement enregistrée"
      render 'savestep'
    end
    rescue Exception => exc
       @returnmessage = "Une erreur est survenue #{exec.message}"
       render 'savestep'
  end


end
