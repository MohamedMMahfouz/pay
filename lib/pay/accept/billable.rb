module Pay
  module Accept
    class Billable
      attr_reader :billable

      delegate :processor_id, :processor_id?, :email,
               :customer_name, :card_token, to: :billable

      def initialize(billable)
        @billable = billable
      end

      def customer
        billable.update(processor: :accept, processor_id: processor_id.id) if processor_id.present?
      end

      def charge(amount)
        api = Pay::Accept::ApiHandler.initiate_order(
          amount: amount,
          user: billable,
          payment_reference: generate_payment_reference
        )
        raise Pay::Accept::Error, 'Failed to retreive order id from accept api' unless api.order_id.present?

        create_transaction(amount, api.payment_key, api.order_id)
      end

      def generate_payment_reference
        Pay::Charge.generate_payment_reference
      end

      def create_transaction(amount, payment_key, order_id)
        charge = Pay::Charge.new(
          amount: amount,
          # wallet: user.wallet,
          # transaction_type: :deposit,
          owner: billable,
          processor_id: order_id,
          processor: :accept,
          payment_reference: payment_key
        )
        return charge if charge.save

        raise Pay::Accept::Error, error_messaage(charge)
      end

      def error_message(charge)
        charge.errors.messages.map { |k, v| "#{k}: #{v.join(', ')}"}.join(', ')
      end
    end
  end
end