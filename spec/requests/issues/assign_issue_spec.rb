require "rails_helper"

RSpec.describe "Issues", type: :request do
  describe 'PATCH assign' do
    context 'as authenticated' do
      let(:headers) do
        role.create_new_auth_token.merge('accept' => "application/json")
      end
      context 'user' do
        let(:user) { create(:user) }
        let(:role) { user }

        context 'get permission error' do
          let(:issue) { create(:issue, manager: nil)}

          before(:each) do
            patch "/issues/#{issue.id}/assign",
                  { params: {}, headers: headers }
          end

          it 'returns error message' do
            expect(response.body).to match(/Not enough permissions/)
          end

          it 'returns status code 403' do
            expect(response).to have_http_status(:forbidden)
          end
        end
      end

      context 'manager' do
        let(:manager) { create(:user, :manager) }
        let(:role) { manager }

        context 'assigns issue to himself' do
          context 'if it`s not assigned to someone else' do
            let(:issue) { create(:issue, manager: nil)}

            before(:each) do
              patch "/issues/#{issue.id}/assign",
                    { params: {}, headers: headers }
            end

            it 'assigns issue to manager' do
              manager_id = JSON.parse(response.body)['issue']['manager_id']
              expect(manager_id).to eq(role.id)
            end

            it 'returns status code 200' do
              expect(response).to have_http_status(:ok)
            end
          end
        end

        context 'failed to assign issue to himself' do
          context 'if issue is already assigned to someone else' do
            let(:issue) { create(:issue) }
            let(:manager) { issue.manager }

            before(:each) do
              patch "/issues/#{issue.id}/assign",
                    { params: {}, headers: headers }
            end

            it 'returns error message' do
              expect(response.body).to match(/Not enough permissions/)
            end

            it 'returns status code 403' do
              expect(response).to have_http_status(:forbidden)
            end

            it 'doesn`t change issue`s assignee' do
              expect(issue.manager).to eq(manager)
            end
          end
        end
      end
    end
  end

  context 'as not authenticated' do
    context 'unable to assign issue' do
      let(:issue) { create(:issue) }

      before(:each) do
        patch "/issues/#{issue.id}/assign",
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
