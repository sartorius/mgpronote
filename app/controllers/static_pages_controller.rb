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
