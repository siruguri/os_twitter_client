class NotificationLogsController < ApplicationController
  before_action :authenticate_user!
  def index
  end
  
  def list
    if !request.xhr?
      head 200
    else
      @logs = NotificationLog.order(created_at: :desc).limit(30).pluck :notification_message, :created_at
      render json: ({data: @logs}), status: 202
    end
  end
end
