require 'rails_helper'

RSpec.describe Pay::Accept::Billable::PaymentsController, type: :controller do
  let(:user) { create(:user, processor: :accept) }

  before do 
    ENV['ACCEPT_BASE_URI'] = 'https://accept.paymobsolutions.com/api'
    ENV['ACCEPT_INTEGRATION_ID'] = ''
    ENV['ACCEPT_HMAC_SECRET'] = ''
    ENV['ACCEPT_API_KEY'] = ''
  end
  context '#charge' do
    context 'charging user' do
      it 'charges user', vcr: { cassette_name: 'transaction_creation' } do
        user.charge(20)
        charges = user.charges
        expect(charges.count).to eq(1)
        expect(charges.first.amount).to eq(20)
      end
    end
  end
end