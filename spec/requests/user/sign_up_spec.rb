# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User', type: :request do
  describe 'POST sign_up' do
    context 'with invalid data' do
      before(:each) { post '/auth', params: invalid_data }
      context 'missed all data' do
        let(:invalid_data) { nil }
        it 'returns error message' do
          expect(response.body)
            .to match(/Please submit proper sign up data in request body/)
        end
      end

      context 'missed email' do
        let(:invalid_data) { { password: 'password' } }
        it 'returns error message' do
          expect(response.body)
            .to match(/Email can't be blank/)
        end
      end

      context 'missed password' do
        let(:invalid_data) { { email: 'user@email.com' } }
        it 'returns error message' do
          expect(response.body)
            .to match(/Password can't be blank/)
        end
      end

      context 'invalid password' do
        let(:invalid_data) { { email: 'user@email.com', password: 'pas' } }
        it 'returns error message' do
          expect(response.body)
            .to match(/Password is too short/)
        end
      end

      context 'invalid email' do
        let(:invalid_data) { { email: 'invalid_email', password: 'password' } }
        it 'returns error message' do
          expect(response.body)
            .to match(/Email is not an email/)
        end
      end
    end

    context 'with walid data' do
      before(:each) { post '/auth', params: valid_data }

      context 'as manager' do
        let(:valid_data) do
          { email: 'user@email.com', password: 'password', role: :manager }
        end

        it 'returns manager' do
          role = JSON.parse(response.body)['data']['role']
          expect(role).to eq('manager')
        end
      end

      context 'as user by default' do
        let(:valid_data) do
          { email: 'user@email.com', password: 'password' }
        end

        it 'returns user' do
          role = JSON.parse(response.body)['data']['role']
          expect(role).to eq('user')
        end
      end
    end
  end
end
