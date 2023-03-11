module Arango
  # Arango Requests
  module Requests
  # Arango Requests
    module Wal
      class GetProperties < Arango::Request
        self.request_method = :get

        self.uri_template = "/_admin/wal/properties"

        code 200, :success
        code 405, "Invalid HTTP method!"
      end
    end
  end
end
