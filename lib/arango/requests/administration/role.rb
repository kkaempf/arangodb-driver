module Arango
  module Requests
    # Administration Requests
    module Administration
      # API: GET /_admin/server/role
      class Role < Arango::Request
        self.request_method = :get

        self.uri_template = "/_admin/server/role"

        code 200, :success
      end
    end
  end
end
