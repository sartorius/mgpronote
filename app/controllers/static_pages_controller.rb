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
end
