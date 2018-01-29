require "rails_helper"

RSpec.describe "Issues", type: :request do
  describe 'GET show' do
    context 'as authenticated' do
      let(:headers) do
        role.create_new_auth_token.merge('accept' => "application/json")
      end

      before(:each) { get "/issues/#{issue.id}", { headers: headers } }

      context 'manager' do
        let(:manager) { create(:user, :manager) }
        let(:role) { manager }

        context 'able to view any issue' do
          let(:issue) { create(:issue)}

          it 'returns issue' do
            issue = JSON.parse(response.body)['issue']
            expect(response).to match_response_schema('issue')
          end

          it 'returns appropriate issue' do
            issue_id = JSON.parse(response.body)['issue']['id']
            expect(issue_id).to eq(issue.id)
          end

          it 'returns status code 200' do
            expect(response).to have_http_status(:ok)
          end
        end
      end

      context 'user' do
        let(:user) { create(:user) }
        let(:role) { user }

        context 'able to view self issues' do
          let(:issue) { create(:issue, user: role)}

          it 'returns issue' do
            issue = JSON.parse(response.body)['issue']
            expect(response).to match_response_schema('issue')
          end

          it 'returns appropriate issue' do
            issue_id = JSON.parse(response.body)['issue']['id']
            expect(issue_id).to eq(issue.id)
          end

          it 'returns status code 200' do
            expect(response).to have_http_status(:ok)
          end
        end

        context 'unable to view other users` issues' do
          let(:issue) { create(:issue)}

          it 'returns permission error' do
            expect(response.body).to match(/Not enough permissions/)
          end

          it 'returns status code 403' do
            expect(response).to have_http_status(:forbidden)
          end
        end
      end
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
