class AnalysisController < ApplicationController
  def task_page
  end
  
  def execute_task
    if params[:commit]
      if ["re-bio all handles", 'update profile stats', 'compute document universe'].include?(params[:commit].downcase)
        flash[:notice] = "Executed command #{params[:commit]}"
        case params[:commit].downcase
        when 'compute document universe'
          DocumentUniverse.reanalyze
        when 'update profile stats'
          ProfileStat.update_all
        when "re-bio all handles"
          @count = 0
          TwitterProfile.all.each do |t|
            @count += 1
            TwitterFetcherJob.perform_later(t, 'bio')
          end
          flash[:notice] += ": Processed #{@count} profiles"
        end
      else
        flash[:error] = "No such command"
      end
    end
    render :task_page
  end
end
