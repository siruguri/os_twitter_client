module Users
  class RegistrationsController < Devise::RegistrationsController
    protected
    def after_sign_up_path_for(resource)
      twitter_input_handle_path
    end
    def after_inactive_sign_up_path_for(resource)
      twitter_input_handle_path
    end
  end
end
