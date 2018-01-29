require "rails_helper"

RSpec.describe "Issues", type: :request do
  describe 'GET index' do
    context 'as authenticated' do
      let(:headers) do
        role.create_new_auth_token.merge('accept' => "application/json")
      end

      let!(:progress_issue) { create(:issue, user: role, status: 1) }
      let!(:resolved_issue) { create(:issue, user: role, status: 2) }
      let!(:pending_issue) { create(:issue, user: role) }

      let!(:extra_issues) { create_list(:issue, 3) }

      context 'user' do
        let(:user) { create(:user) }
        let(:role) { user }

        context "fetch all users` issues" do
          it do
            get "/issues", { params: {}, headers: headers}
            expect(response).to have_http_status(200)
            body = JSON.parse(response.body)['issues']

            expect(body.count).to eq(3)
            expect(response).to match_response_schema("issues")
          end
        end

        context "filtes" do
          context 'by statuses' do

            it 'pending' do
              get "/issues", { params: {status: 'pending'}, headers: headers}
              expect(response).to have_http_status(200)
              body = JSON.parse(response.body)['issues']

              expect(body.count).to eq(1)
              expect(response).to match_response_schema("issues")
              expect(body.first['title']).to eq(pending_issue.title)
            end

            it 'progress' do
              get "/issues", { params: {status: 'progress'}, headers: headers}
              expect(response).to have_http_status(200)
              body = JSON.parse(response.body)['issues']

              expect(body.count).to eq(1)
              expect(response).to match_response_schema("issues")
              expect(body.first['title']).to eq(progress_issue.title)
            end

            it 'resolved' do
              get "/issues", { params: {status: 'resolved'}, headers: headers}
              expect(response).to have_http_status(200)
              body = JSON.parse(response.body)['issues']

              expect(body.count).to eq(1)
              expect(response).to match_response_schema("issues")
              expect(body.first['title']).to eq(resolved_issue.title)
            end

            it 'pending and progress' do
              get "/issues",
                  { params: {status: 'pending,progress'}, headers: headers}
              expect(response).to have_http_status(200)
              body = JSON.parse(response.body)['issues']

              expect(body.count).to eq(2)
              expect(response).to match_response_schema("issues")
              expect(body.detect {|el| el['status'] == 'pending'}['title'])
                .to eq(pending_issue.title)
              expect(body.detect {|el| el['status'] == 'progress'}['title'])
                .to eq(progress_issue.title)
            end

            it 'pending and resolved' do
              get "/issues",
                  { params: {status: 'pending,resolved'}, headers: headers}
              expect(response).to have_http_status(200)
              body = JSON.parse(response.body)['issues']

              expect(body.count).to eq(2)
              expect(response).to match_response_schema("issues")
              expect(body.detect {|el| el['status'] == 'pending'}['title'])
                .to eq(pending_issue.title)
              expect(body.detect {|el| el['status'] == 'resolved'}['title'])
                .to eq(resolved_issue.title)
            end

            it 'progress and resolved' do
              get "/issues",
                  { params: { status: 'progress,resolved'}, headers: headers}
              expect(response).to have_http_status(200)
              body = JSON.parse(response.body)['issues']

              expect(body.count).to eq(2)
              expect(response).to match_response_schema("issues")
              expect(body.detect {|el| el['status'] == 'progress'}['title'])
                .to eq(progress_issue.title)
              expect(body.detect {|el| el['status'] == 'resolved'}['title'])
                .to eq(resolved_issue.title)
            end

            it 'progress and invalid' do
              get "/issues",
                  { params: { status: 'progress,invalid'}, headers: headers}
              expect(response).to have_http_status(200)
              body = JSON.parse(response.body)['issues']

              expect(body.count).to eq(1)
              expect(response).to match_response_schema("issues")
              expect(body.first['title']).to eq(progress_issue.title)
            end
          end
        end
      end

      context 'manager' do
        let(:manager) { create(:user, :manager) }
        let(:role) { manager }

        context "fetch all issues" do
          it do
            get "/issues", { params: {}, headers: headers}
            expect(response).to have_http_status(200)
            body = JSON.parse(response.body)['issues']

            expect(body.count).to eq(6)
            expect(response).to match_response_schema("issues")
          end
        end

        context "fetch all assigned to manager issues" do
          let!(:assigned_issue) { create(:issue, manager: manager) }
          it do
            get "/issues", { params: {assigned_to_me: true}, headers: headers }
            expect(response).to have_http_status(200)
            body = JSON.parse(response.body)['issues']

            expect(body.count).to eq(1)
            expect(response).to match_response_schema("issues")
            expect(body.first['title']).to eq(assigned_issue.title)
          end
        end

      end
    end

    context 'as not authenticated' do
      context 'unable to get list of issues' do
        let(:valid_params) do
          {
            issue: {
              title: 'Title',
              content: 'Content'
            }
          }
        end

        before(:each) do
          get '/issues', { headers: {'accept' => "application/json"} }
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
