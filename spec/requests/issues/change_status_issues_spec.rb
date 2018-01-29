require "rails_helper"

RSpec.describe "Issues", type: :request do
  describe 'PATCH change_status' do
    context 'as authenticated' do
      let(:headers) do
        role.create_new_auth_token.merge('accept' => "application/json")
      end

      before(:each) do
        patch "/issues/#{issue.id}/change_status",
              { params: {issue: {status: status}}, headers: headers }
      end

      context 'user' do
        let(:user) { create(:user) }
        let(:role) { user }

        context 'get permission error' do
          let(:issue) { create(:issue, manager: nil)}

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

        context 'changes issue status if assigned to it' do
          let(:issue) { create(:issue, manager: role)}
          let(:status) { 'progress' }

          it 'returns issue with updated status' do
            updated_status = JSON.parse(response.body)['issue']['status']
            expect(updated_status).to eq(status)
          end

          it 'returns status code 200' do
            expect(response).to have_http_status(:ok)
          end
        end

        context 'doesn`t change issue status' do
          context 'unless assigned to it' do
            let(:issue) { create(:issue) }
            let(:status) { 'progress' }

            it 'returns permission error' do
              expect(response.body).to match(/Not enough permissions/)
            end

            it 'returns status code 403' do
              expect(response).to have_http_status(:forbidden)
            end
          end

          context 'unless status valid' do
            let(:issue) { create(:issue, manager: role) }
            let(:status) { 'invalid_status' }

            it 'returns validation error' do
              expect(response.body).to match(/Invalid status/)
            end

            it 'returns status code 400' do
              expect(response).to have_http_status(:bad_request)
            end
          end
        end
      end
    end

    context 'as not authenticated' do
      context 'unable to change issue status' do
        let(:issue) { create(:issue) }
        let(:valid_params) do
          {
            issue: {
              status: :progress
            }
          }
        end

        before(:each) do
          patch "/issues/#{issue.id}/change_status",
               { params: valid_params,
                headers: {'accept' => "application/json"} }
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
