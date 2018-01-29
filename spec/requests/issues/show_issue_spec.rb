require "rails_helper"

RSpec.describe "Issues", type: :request do
  describe 'GET show' do
    context 'as authenticated' do
    end
    context 'as not authenticated' do
      context 'unable to create issue' do
        let(:issue) { create(:issue) }

        before(:each) do
          get "/issues/#{issue.id}",
               { headers: {'accept' => "application/json"} }
        end

        it 'returns not authorized error message' do
          expect(response.body)
            .to match(/You need to sign in or sign up before continuing./)
        end

        it 'returns status code 401' do
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end
