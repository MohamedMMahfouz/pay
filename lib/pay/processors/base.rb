module Pay
  module Processors
    class Base
      attr_reader :billable

      delegate :processor_id, :processor_id?, :customer_name, :email, to: :billable

      def initialize(billable)
        @billable = billable
      end
    end
  end
end
