module Arango
  # Arango Requests
  module Requests
  # Arango Requests
    module Replication
      class GetApplierState < Arango::Request
        self.request_method = :get

        self.uri_template = '{/dbcontext}/_api/replication/applier-state'

        code 200, :success
        code 405, "Invalid HTTP request method!"
        code 500, "A error occurred!"
      end
    end
  end
end
