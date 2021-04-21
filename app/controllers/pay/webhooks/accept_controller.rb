module Pay
  module Webhooks
    class AcceptController < Pay::ApplicationController
      before_action :set_callback_charge, :set_response_hmac, only: :charge_response
      before_action :set_response_charge, :set_callback_hmac, only: :charge_callback

      def charge_response
        if @charge.reflected?
          @charge.completed! if @charge.present? && @hmac == params[:hmac] && charge_response_params[:success] == 'true'
          redirect_to(payment_status_url(success: true))
        else
          @charge.failed!
          redirect_to(payment_status_url(success: false))
        end
      end

      def charge_callback
        return head(:ok) if @charge.reflected?

        if @hmac == params[:hmac] && charge_callback_params[:success] == true
          @charge.reflected!
          # result = Transaction::ReflectBalance.call(user: charge.user, transaction: charge)
          # charge.failed! unless result.success?
        else
          @charge.failed!
        end
      end

      private

      def charge_response_params
        params
          .permit(
            :amount_cents, :created_at, :currency, :error_occured,
            :has_parent_transaction, :id, :integration_id, :is_3d_secure, :is_auth, :is_capture,
            :is_refunded, :is_standalone_payment, :is_voided, :owner, :pending, :success,
            :'source_data.pan', :'source_data.sub_type', :'source_data.type', :order
          )
      end

      def charge_callback_params
        params
          .require(:obj)
          .permit(
            :amount_cents, :created_at, :currency, :error_occured,
            :has_parent_transaction, :id, :integration_id, :is_3d_secure, :is_auth, :is_capture,
            :is_refunded, :is_standalone_payment, :is_voided, :owner,
            :pending, :success, source_data:
                                            %i(pan sub_type type), order: %i(id)
          )
      end

      def payment_status_url(success:)
        site_url = ENV.fetch('SITE_DOMAIN_URL')
        "#{site_url}/complete-payment?success=#{success}"
      end

      def set_callback_charge
        @charge = Pay::Charge.find_by_gateway_id(charge_callback_params.dig(:order, :id))
      end

      def set_response_charge
        @charge = Pay::Charge.find_by_processor_id!(charge_response_params[:order])
      end

      def set_response_hmac
        @hmac = Pay::Accept::HMACCalculator.new.calculate(charge_response_params.to_h)
      end

      def set_callback_hmac
        @hmac = Pay::Accept::HMACCalculator.new.calculate(charge_callback_params.to_h)
      end
    end
  end
end
