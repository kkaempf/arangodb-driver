module Arango
  # Arango Requests
  module Requests
  # Arango Requests
    module AQL
      class GetQueryTrackingProperties < Arango::Request
        self.request_method = :get

        self.uri_template = "/_api/query/properties"

        code 200, :success
        code 400, "Malformed request!"
      end
    end
  end
end
