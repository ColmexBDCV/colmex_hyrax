class AuthorityController < ApplicationController
  
  def person
    names = ::AutofillService.person(params[:person])


    render json: names
  end

  
end
