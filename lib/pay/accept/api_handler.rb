# frozen_string_literal: true

require 'httparty'

module Pay
  module Accept
    class ApiHandler
      include HTTParty
      base_uri ENV.fetch('ACCEPT_BASE_URI')
      headers 'Content-Type' => 'application/json'
      attr_reader :auth_token, :merchant_id, :amount, :order_id, :payment_key,
                  :user, :payment_reference

      def initialize(amount, user, payment_reference)
        @amount = amount
        @user = user
        @payment_reference = payment_reference
      end

      def self.initiate_order(amount:, user:, payment_reference:)
        api = new(amount, user, payment_reference)
        api.authenticate
        api.create_order
        api.request_payment_key
        api
      end

      def authenticate
        response = self.class.post('/auth/tokens',body: { api_key: api_key }.to_json)
        return unless response.code == 201 ##double check

        parsed_response = response.parsed_response
        @auth_token = parsed_response['token']
        @merchant_id = parsed_response['profile']['id']
      end

      def create_order
        response = self.class.post('/ecommerce/orders', body: order_body.to_json)
        return unless response.code == 201 ##double check

        parsed_response = response.parsed_response
        @order_id = parsed_response['id']
      end

      def request_payment_key
        response = self.class.post(
          '/acceptance/payment_keys',
          body: request_payment_body.to_json
        )
        return unless response.code == 201 ##double check

        parsed_response = response.parsed_response
        @payment_key = parsed_response['token']
      end

      private

      def api_key
        ENV.fetch('ACCEPT_API_KEY')
      end

      def integration_id
        ENV.fetch('ACCEPT_INTEGRATION_ID')
      end

      def order_body
        {
          auth_token: auth_token,
          merchant_id: merchant_id,
          delivery_needed: false,
          currency: 'EGP',
          amount_cents: amount.to_i * 100,
          merchant_order_id: payment_reference
        }
      end

      def request_payment_body
        {
          auth_token: auth_token,
          amount_cents: amount.to_i * 100,
          order_id: order_id,
          currency: 'EGP',
          integration_id: integration_id,
          billing_data: billing_data,
        }
      end

      def billing_data
        {
          email: user.email,
          first_name: user.try(:first_name),#user.name.split(' ')[0],
          last_name: user.try(:last_name),#user.name.split(' ')[1] ? user.name.split(' ')[1] : user.name.split(' ')[0],
          building: 'NA',
          apartment: 'NA',
          street: 'NA',
          floor: 'NA',
          city: 'NA',
          phone_number: user.try(:phone_number),
          country: 'NA'
        }
      end
    end
  end
end