module Ajax
  class Response
    @@_data = nil
    def self.update(s)
      @@_data = s
    end
    def self.last_known_response
      @@_data
    end
  end
    
  class Library
    def self.route_action(action_str, user=nil)
      status_struct = {status: 'error', code: '500'}
      
      matches = /^(\w+)\/(\w+)\/(.*)/.match(action_str)
      if matches
        controller = matches[1]
        action = matches[2]
        params = matches[3].split '/'                                  
        data = nil
        case controller
        when 'reads'
          status_struct = {status: 'success'}
        when 'actions'
          # this is special, to allow for direct multiplexing from here, rather than send to
          # a model in the app
          code = 422
          begin
            if params.size > 0 and (i = params[0].to_i) != '0' and Actions.valid_ids.include?(i)
              success = Actions.perform i, {user: user}.merge(params.size > 1 ? ({data: params[1..-1]}) : {})
              data = Actions.last_known_response
            end
            if success
              code = 200
            end
          rescue Exception => e
            code = 500
          end

          status_struct = {status: success ? 'success' : 'error', code: code, data: data}      
        end
      end
            
      status_struct
    end
  end
end
