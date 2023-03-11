module Arango
  # Arango Requests
  module Requests
  # Arango Requests
    module Administration
      class ClusterEndpoints < Arango::Request
        self.request_method = :get

        self.uri_template = "/_api/cluster/endpoints"

        code 200, :success
        code 501, "Cannot get cluster endpoints for some reason."
      end
    end
  end
end
