class BarcodeController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:savestep]

  def readbc
    render 'readbc'
  end

  def savestep
    flash[:info] = "Step save: " + params[:stepstep] + " /" + params.to_s
    render 'savestep'
  end
end
