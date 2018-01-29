require "rails_helper"

RSpec.describe "Issues", type: :request do
  describe 'PATCH unassign' do
    context 'as authenticated' do
      let(:headers) do
        role.create_new_auth_token.merge('accept' => "application/json")
      end

      before(:each) do
        patch "/issues/#{issue.id}/unassign",
              { params: {}, headers: headers }
      end

      context 'user' do
        let(:user) { create(:user) }
        let(:role) { user }

        context 'get permission error' do
          let(:issue) { create(:issue)}

          before(:each) do
            patch "/issues/#{issue.id}/unassign",
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
        let(:user) { create(:user, :manager) }
        let(:role) { user }

        context 'unassigns issue from himself' do
          let(:issue) { create(:issue, manager: role) }

          it 'unassigns issue' do
            manager_id = JSON.parse(response.body)['issue']['manager_id']
            expect(manager_id).to be_nil
          end

          it 'returns status code 200' do
            expect(response).to have_http_status(:ok)
          end
        end

        context 'failed to unassign issue' do
          context 'if it`s not assigned to him' do
            let(:issue) { create(:issue) }

            it 'return error message' do
              expect(response.body).to match(/Not enough permissions/)
            end

            it 'returns status code 403' do
              expect(response).to have_http_status(:forbidden)
            end
          end

          context 'if issue status is' do
            context 'progress' do
              let(:issue) { create(:issue, manager: role, status: :progress) }

              it 'return error message' do
               expect(response.body)
                 .to match(/Manager can`t be unassigned from the issue/)
              end

              it 'returns status code 422' do
               expect(response).to have_http_status(:unprocessable_entity)
              end
            end

            context 'resolved' do
              let(:issue) { create(:issue, manager: role, status: :resolved) }
              it 'return error message' do
                expect(response.body)
                  .to match(/Manager can`t be unassigned from the issue/)
              end

              it 'returns status code 422' do
                 expect(response).to have_http_status(:unprocessable_entity)
              end
            end
          end
        end
      end
    end

    context 'as not authenticated' do
      context 'unable to unassign issue' do
        let(:issue) { create(:issue) }
        before(:each) do
          patch "/issues/#{issue.id}/unassign",
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
