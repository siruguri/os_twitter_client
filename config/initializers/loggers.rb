log_path = File.join(File.dirname(__FILE__), '..', '..', 'log', "activejob_#{Rails.env}.log")
ActiveJob::Base.logger = Logger.new(log_path)

ActiveJob::Base.logger.level = Rails.env.production? ? :error : :debug

