module Arango
  class Database
    module AQLFunctions

      def list_aql_functions(namespace: nil)
        query = nil
        query = { namespace: namespace } unless namespace.nil?
        result = execute_request(get: "_api/aqlfunction", query: query)
        result.result.map { |r| Arango::Result.new(r) }
      end

      def create_aql_function(name, code: nil, is_deterministic: nil, &block)
        if block_given?
          source_block = Parser::CurrentRuby.parse(block.source).children.last
          source_block = source_block.children.last if source_block.type == :block
          source_code = Unparser.unparse(source_block)
          compiled_ruby= Opal.compile(source_code, parse_comments: false)
          if compiled_ruby.start_with?('/*')
            start_of_code = compiled_ruby.index('*/') + 3
            compiled_ruby = compiled_ruby[start_of_code..-1]
          end
          code = <<~JAVASCRIPT
          function() {
            require('opal');
            return #{compiled_ruby}
          }
          JAVASCRIPT
        end
        body = { code: code, name: name, isDeterministic: is_deterministic }
        result = execute_request(post: "_api/aqlfunction", body: body)
        result.response_code == 200 || result.response_code == 201
      end

      def drop_aql_function(name, group: nil)
        query = nil
        query = { group: group } unless group.nil?
        result = request(delete: "_api/aqlfunction/#{name}", query: query)
        result.response_code == 200
      end
    end
  end
end
