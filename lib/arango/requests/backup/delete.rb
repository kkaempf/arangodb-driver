module Arango
  # Arango Requests
  module Requests
    # Backup Requests
    module Backup
      # API: POST /_admin/backup/delete
      class Delete < Arango::Request
        self.request_method = :post

        self.uri_template = "/_admin/backup/delete"

        body :id, :required

        code 200, :success
        code 400, "Bad paramaters or another error, see result!"
        code 404, "Backup with given identifier could not be found!"
      end
    end
  end
end
