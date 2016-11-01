class AnalysisController < ApplicationController
  before_action :authenticate_user!

  def search
    # Bio tag search
  end
  
  def task_page
  end
  
  def execute_task
    if params[:commit]
      if ["re-bio all handles", 'update profile stats', 'compute document universe'].include?(params[:commit].downcase)
        notice_str = "Got command #{params[:commit]}"
        case params[:commit].downcase
        when /compute document universe/
          DocumentUniverse.reanalyze
          notice_str += '... executed'
        when /update profile stats/
          ProfileStat.build_cache
          notice_str += '... executed'
        when /re.bio all handles/
          @count = 0
          TwitterProfile.all.each do |t|
            @count += 1
            TwitterFetcherJob.perform_later(t, 'bio')
          end
          notice_str += ": Processed #{@count} profiles"
        end
      else
        flash[:error] = "No such command"
      end
    end

    flash[:notice] = notice_str
    render :task_page
  end
end
