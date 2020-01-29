module Arango
  module Edge
    module Mixin
      def self.included(base)
        base.include(Arango::Edge::InstanceMethods)
      end
    end
  end
end
