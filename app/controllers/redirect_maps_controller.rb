class RedirectMapsController < ApplicationController
  def show
    src = params[:id]
    if r=RedirectMap.find_by_src(src)
      req = RedirectRequest.new(request_referer: request.referer, request_agent: request.user_agent)
      req.redirect_map = r
      req.save
      redirect_to r.dest
    else
      render nothing: true
    end
  end
end

