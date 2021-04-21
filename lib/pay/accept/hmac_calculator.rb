# frozen_string_literal: true
module Pay
  module Accept
    class HMACCalculator
      def calculate(hash)
        concatenated_params = flatten(hash).sort.to_h.values.join
        OpenSSL::HMAC.hexdigest('SHA512', hmac_key, concatenated_params)
      end

      private

      def flatten(hash)
        new_hash = {}
        hash.each do |key, value|
          if value.is_a?(Hash)
            new_hash.merge!(value.transform_keys { |k| "#{key}.#{k}" })
          else
            new_hash[key] = value
          end
        end
        new_hash
      end

      def hmac_key
        # ENV.fetch('ACCEPT_HMAC_SECRET')
        "some key"
      end
    end
  end
end
