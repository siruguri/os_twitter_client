require 'dotenv'
Dotenv.load

remote_server = ENV['RAILS_REMOTE_SERVER']
remote_port = ENV['RAILS_REMOTE_PORT']

server remote_server, user: "www-data", port: remote_port, roles: %w(web app db)

set :branch, 'master'
set :rails_env, :development

set :ssh_options, {
      keys: %w(/users/sameer/.ssh/digital_ocean_sameer),
      port: remote_port,
#      forward_agent: false,
#      auth_methods: %w(password)
    }

set :deploy_to, "/var/www/railsapps/#{fetch(:full_app_name)}"

#
# And/or per server (overrides global)
# ------------------------------------
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
