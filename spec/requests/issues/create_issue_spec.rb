require "rails_helper"

RSpec.describe "Issues", type: :request do
  describe 'POST create' do
    context 'as authenticated' do
      let(:headers) do
        role.create_new_auth_token.merge('accept' => "application/json")
      end
      context 'manager' do
        let(:user) { create(:user, :manager) }
        let(:role) { user }

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
            post '/issues', { params: valid_params, headers: headers }
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

        context 'valid request' do
          let(:valid_params) do
            {
              issue: {
                title: 'Title',
                content: 'Content'
              }
            }
          end

          before(:each) do
            post '/issues', { params: valid_params, headers: headers }
          end

          it 'creates issue' do
            expect(response.body).to match(/Title/)
          end

          it 'returns status code 201' do
            expect(response).to have_http_status(:created)
          end
        end

        context 'invalid request' do
          context 'missed issue title' do
            let(:invalid_params) do
              {
                issue: {
                  content: 'Content'
                }
              }
            end

            before(:each) do
              post '/issues', { params: invalid_params, headers: headers }
            end

            it 'returns error message' do
              expect(response.body).to match(/Title can't be blank/)
            end

            it 'returns status code 422' do
              expect(response).to have_http_status(:unprocessable_entity)
            end
          end

          context 'missed issue content' do
            let(:invalid_params) do
              {
                issue: {
                  title: 'Title'
                }
              }
            end

            before(:each) do
              post '/issues', { params: invalid_params, headers: headers }
            end

            it 'returns error message' do
              expect(response.body).to match(/Content can't be blank/)
            end

            it 'returns status code 422' do
              expect(response).to have_http_status(:unprocessable_entity)
            end
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
