require 'rails_helper'

RSpec.describe Pay::Webhooks::AcceptController, type: :controller do
  let(:user) { create(:user, :with_reflected_charge) }
  let(:reflected_charge) { create(:charge, :reflected) }
  let(:charge) { create(:charge) }
  let(:mocked_hmac_value) { '558j23ejs1233284234' }

  before do
    ENV['SITE_DOMAIN_URL'] = 'test_url'
    expect_any_instance_of(Pay::Accept::HMACCalculator).to receive(:calculate).and_return(mocked_hmac_value)
  end

  describe 'GET #charge_response' do
    context 'when charge is reflected' do
      it 'complete the charge' do 
        get :charge_response, params: {
          order: reflected_charge.processor_id,
          hmac: mocked_hmac_value,
          success: 'true'
        }

        expect(reflected_charge.reload.status).to eq('completed')
      end
    end

    context 'when charge is not reflected' do 
      it 'fails the charge' do 
        get :charge_response, params: {
          order: charge.processor_id,
          hmac: mocked_hmac_value,
          success: 'true'
        }

        expect(charge.reload.status).to eq('failed')
      end
    end

    context 'when hmac is incorrect' do 
      it 'the charge remains reflected' do 
        get :charge_response, params: {
          order: reflected_charge.processor_id,
          hmac: 'some value',
          success: 'true'
        }

        expect(reflected_charge.reload.status).to eq('reflected')
      end
    end

    context 'when success is false' do 
      it 'the charge remains reflected' do 
        get :charge_response, params: {
          order: reflected_charge.processor_id,
          hmac: 'some value',
          success: 'false'
        }

        expect(reflected_charge.reload.status).to eq('reflected')
      end
    end
  end


  describe 'POST #charge_callback' do
    context 'when charge is reflected' do
      it 'does nothing and returns success' do 
        post :charge_callback, params: {
          obj: {
            order: { id: reflected_charge.processor_id },
            success: true
          },
          hmac: mocked_hmac_value,
        }
        expect(response).to be_ok
        expect(reflected_charge.reload.status).to eq('reflected')
      end
    end

    context 'when charge is not reflected' do 
      context 'when hmac is correct and success is true' do 
        it 'reflect the charge' do 
          post :charge_callback, params: {
            obj: {
              order: { id: charge.processor_id },
              success: true
            },
            hmac: mocked_hmac_value,
          }
          expect(charge.reload.status).to eq('reflected')
        end
      end

      context 'when hmac is incorrect and success is false' do 
        it 'fails the charge' do 
          post :charge_callback, params: {
            obj: {
              order: { id: charge.processor_id },
              success: false
            },
            hmac: 'some value',
          }
          expect(charge.reload.status).to eq('failed')
        end
      end
    end
  end
end
