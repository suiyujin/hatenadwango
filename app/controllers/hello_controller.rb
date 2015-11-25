class HelloController < ApplicationController
  protect_from_forgery except: :index

  def index
    render json: { sample: { message: 'Hello!' } }, callback: callback_param
  end

  def jsonp_test
    render :jsonp_test
  end
end
