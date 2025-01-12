module Arango
  # Arango Requests
  module Requests
    # Task Requests
    module Task
      # API: POST /_api/tasks
      class Create < Arango::Request
        self.request_method = :post

        self.uri_template = '/_api/tasks'

        body :name, :required
        body :command, :required
        body :params, :required
        body :period
        body :offset

        code 200, :success
        code 400, "Task must include name, command, and params"
        code 409, "duplicate task name"
      end
    end
  end
end
