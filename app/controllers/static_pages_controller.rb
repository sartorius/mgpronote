class StaticPagesController < ApplicationController


  def home
  end

  def help
  end

  def about
  end

  def contact
  end

  def readbc
  end

  def wakeupnote
      sql_query = "SELECT wp.exam_date AS wp_exam_date, wp.exam_subject AS wp_exam_subject, wp.exam_name AS wp_exam_name, wp.exam_note AS wp_exam_note, wp.exam_best AS wp_exam_best, wp.exam_avg AS wp_exam_avg "
      sql_query += " FROM wakeup_pnnote wp "
      sql_query += " ORDER BY wp.exam_date DESC LIMIT "+ ENV['SQL_LIMIT_MD'] +";"

      begin

        @resultSet = ActiveRecord::Base.connection.exec_query(sql_query)
        @emptyResultSet = @resultSet.empty?
        @maxRowParamMD = " Cet écran récupère un maximum de " + ENV['SQL_LIMIT_MD'].to_s + " lignes. Si vous avez besoin de plus contactez-nous avec le code UPG921."
      end
      rescue Exception => exc
         flash.now[:danger] = "Une erreur est survenue #{exec.message}"

    render 'wakeupnote'
  end

  def wakeupcertif
    render 'wakeupcertif'
  end

  def why
    render 'why'
  end

  def pricing
    render 'pricing'
  end

  def letsbepartners
    render 'letsbepartners'
  end

  def howtouse
    render 'howtouse'
  end

  def accessrightserror
    render 'accessrightserror'
  end

  def termsofuse
    render 'termsofuse'
  end

  def features
    ApplicationSms.get_logging_oma
    render 'features'
  end
end
