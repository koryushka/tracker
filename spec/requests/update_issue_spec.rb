require "rails_helper"

RSpec.describe "Issues", type: :request do
  describe 'PATCH update' do
    context 'as authenticated' do
      let(:headers) do
        role.create_new_auth_token.merge('accept' => "application/json")
      end

      context 'manager' do
        let(:user) { create(:user, :manager) }
        let(:role) { user }

        context 'unable to update issue' do
          let(:issue) { create(:issue, manager: role)}

          let(:valid_params) do
            {
              issue: {
                title: 'Title',
                content: 'Content'
              }
            }
          end

          before(:each) do
            patch "/issues/#{issue.id}",
                  { params: valid_params, headers: headers }
          end

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

        context 'update only self issues' do
          let(:issue) { create(:issue, user: role) }

          context 'valid request' do
            let(:valid_params) do
              {
                issue: {
                  title: 'Updated Title',
                  content: 'Updated Content'
                }
              }
            end

            before(:each) do
              patch "/issues/#{issue.id}",
                    { params: valid_params, headers: headers }
            end

            it 'updates issue' do
              expect(response.body).to match(/Updated Title/)
            end

            it 'returns status code 200' do
              expect(response).to have_http_status(:ok)
            end
          end

          context 'unable to change assigned manager of self issues' do
            let(:initial_manager) { create(:user, :manager) }
            let(:issue_manager) { issue.manager }

            let(:valid_params) do
              {
                issue: {
                  title: 'Updated Title',
                  content: 'Updated Content',
                  manager_id: initial_manager.id
                }
              }
            end

            before(:each) do
              patch "/issues/#{issue.id}",
                    { params: valid_params, headers: headers }
            end

            it 'returns issue with initial manager' do
              manager_id = JSON.parse(response.body)['issue']['manager_id']
              expect(manager_id).to eq(issue_manager.id)
            end

            it 'doesn`t change issue`s manager' do
              expect(issue_manager).to eq(issue.manager)
            end
          end

          context 'invalid request' do
            context 'missed issue title' do
              let(:invalid_params) do
                {
                  issue: {
                    title: nil,
                    content: 'Content'
                  }
                }
              end

              before(:each) do
                patch "/issues/#{issue.id}",
                      { params: invalid_params, headers: headers }
              end

              it 'returns error message' do
                expect(response.body).to match(/Title can't be blank/)
              end

              it 'returns status code 400' do
                expect(response).to have_http_status(:bad_request)
              end
            end

            context 'missed issue content' do
              let(:invalid_params) do
                {
                  issue: {
                    title: 'Title',
                    content: nil
                  }
                }
              end

              before(:each) do
                patch "/issues/#{issue.id}",
                      { params: invalid_params, headers: headers }
              end

              it 'returns error message' do
                expect(response.body).to match(/Content can't be blank/)
              end

              it 'returns status code 400' do
                expect(response).to have_http_status(:bad_request)
              end
            end
          end
        end

        context 'unable to update other users` issues' do
          let(:issue) { create(:issue) }

          let(:valid_params) do
            {
              issue: {
                title: 'Updated Title',
                content: 'Updated Content'
              }
            }
          end

          before(:each) do
            patch "/issues/#{issue.id}",
                  { params: valid_params, headers: headers }
          end

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
        let(:valid_params) do
          {
            issue: {
              title: 'Title',
              content: 'Content'
            }
          }
        end

        before(:each) do
          post '/issues',

               { params: valid_params,
                headers: {'accept' => "application/json"} }
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
