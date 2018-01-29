# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User', type: :request do
  describe 'POST sign_in' do
    context 'with valid credentials' do
      before(:each) { post '/auth/sign_in', params: valid_data }
      let(:user) { create(:user) }
      let(:valid_data) { { email: user.email, password: user.password } }

      it 'responds with status code 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns user data' do
        data = JSON.parse(response.body)['data']

        expect(data['email']).to eq(user.email)
        expect(data['role']).to eq(user.role)
      end
    end

    context 'with invalid credentials' do
      before(:each) { post '/auth/sign_in', params: invalid_data }
      let(:invalid_data) { { email: 'username', password: 'password' } }

      it 'responds with status code 401' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns error message' do
        expect(response.body)
          .to match(/Invalid login credentials. Please try again./)
      end
    end
  end
end
