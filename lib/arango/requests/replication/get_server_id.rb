module Arango
  # Arango Requests
  module Requests
    # Replication Requests
    module Replication
      # API: GET {/dbcontext}/_api/replication/server-id
      class GetServerId < Arango::Request
        self.request_method = :get

        self.uri_template = '{/dbcontext}/_api/replication/server-id'

        code 200, :success
        code 405, "Invalid HTTP request method!"
        code 500, "A error occurred during synchronization or when starting the continous replication!"
      end
    end
  end
end
