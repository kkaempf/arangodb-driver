module Arango
  # Arango Requests
  module Requests
    # User Requests
    module User
      # API: DELETE {/dbcontext}/_api/user/{user}
      class Delete < Arango::Request
        self.request_method = :delete

        self.uri_template = '{/dbcontext}/_api/user/{user}'

        code 201, :success
        code 401, "No database access to the _system database!"
        code 403, "No server access!"
      end
    end
  end
end
