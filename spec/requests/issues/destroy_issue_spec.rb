require "rails_helper"

RSpec.describe "Issues", type: :request do
  describe 'PATCH update' do
    context 'as authenticated' do
      let(:headers) do
        role.create_new_auth_token.merge('accept' => "application/json")
      end

      before(:each) do
        delete "/issues/#{issue.id}", { headers: headers }
      end

      context 'manager' do
        let(:user) { create(:user, :manager) }
        let(:role) { user }

        context 'unable to destroy issue' do
          let(:issue) { create(:issue, manager: role)}

          it 'returns permission error message' do
            expect(response.body).to match(/Not enough permissions/)
          end

          it 'returns status code 403' do
            expect(response).to have_http_status(:forbidden)
          end
        end
      end

      context 'user' do
        let(:user) { create(:user) }
        let(:role) { user }

        context 'destroy only self issues' do
          let(:issue) { create(:issue, user: role) }

          it 'destroys issue' do
            expect(response.body).to be_empty
          end

          it 'returns status code 204' do
            expect(response).to have_http_status(:no_content)
          end

        end

        context 'unable to destroy other users` issues' do
          let(:issue) { create(:issue) }

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
      context 'unable to change issue status' do
        let(:issue) { create(:issue) }

        before(:each) do
          delete "/issues/#{issue.id}",
               { headers: {'accept' => "application/json"} }
        end

        it 'returns not authorized error' do
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
