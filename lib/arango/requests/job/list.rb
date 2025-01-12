module Arango
  # Arango Requests
  module Requests
    # Job Requests
    module Job
      # API: GET {/dbcontext}/_api/job/{type}#by-type
      class List < Arango::Request
        self.request_method = :get

        self.uri_template = '{/dbcontext}/_api/job/{type}#by-type'

        param :count

        code 200, :success
        code 400, "List cannot be compiled or is empty!"
      end
    end
  end
end
