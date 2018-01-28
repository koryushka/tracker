require "rails_helper"

RSpec.describe "Issues", type: :request do
  describe 'POST create' do
    context 'as authenticated' do
      let(:headers) do
        role.create_new_auth_token.merge('accept' => "application/json")
      end
      context 'user' do
        let(:user) { create(:user) }
        let(:role) { user }

        scenario 'should create issue' do
          params = {
            issue: {
              title: 'Title',
              content: 'Content'
            }
          }
          post '/issues', { params: params, headers: headers }

          expect(response).to have_http_status(:created)
        end

      end
    end
  end
end
