class AjaxController < ApplicationController
  def multiplex
    if request.xhr?
      # Implement this ajax library to return true iff the action is
      # found in a dictionary, and its db action succeeded
      status_struct = Ajax::Library.route_action(params[:payload], current_user)
      
      code = status_struct[:code].nil? ? (
        status_struct[:status] == 'success' ? 200 : 500
      ) : (
        status_struct[:code]
      )

      status_struct.delete :code
      render json: status_struct.merge({request: params[:payload]}),
             status_code: code,
             layout: nil
    else
      render json: {}, layout: nil
    end
  end
end
