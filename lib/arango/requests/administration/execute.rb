module Arango
  # Arango Requests
  module Requests
    # Administration Requests
    module Administration
      # API: POST /_admin/execute
      class Execute < Arango::Request
        self.request_method = :post

        self.uri_template = "/_admin/execute"

        # TODO
        # body_is_string

        code 200, :success
        code 403, "Error 403!"
        code 404, "Error 404!"
      end
    end
  end
end
