require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  let(:valid_attributes) {
    { title: "Test Post", body: "This is a test post body" }
  }

  let(:invalid_attributes) {
    { title: "", body: "" }
  }

  let(:user) { User.create!(email: "user@example.com", password: "password", role: "user") }
  let(:admin) { User.create!(email: "admin@example.com", password: "password", role: "admin") }
  let(:post_owner) { User.create!(email: "owner@example.com", password: "password", role: "user") }
  
  let(:owned_post) do
    Post.create!(title: "Owner's Post", body: "Content", created_by: post_owner)
  end

  describe "JSON API endpoints" do
    describe "GET #index" do
      before do
        # Since API requests require authentication, let's sign in a user for index tests
        sign_in user
        # Reset any authentication errors by mocking the authenticate_with_token method
        allow(controller).to receive(:authenticate_with_token).and_return(true)
        request.headers['Authorization'] = 'Bearer dummy-token'
      end

      it "returns a success response" do
        post = Post.create! valid_attributes
        get :index, params: {}, format: :json
        expect(response).to be_successful
        expect(response.content_type).to include('application/json')
      end
      
      it "returns all posts" do
        post1 = Post.create! valid_attributes
        post2 = Post.create! title: "Another Post", body: "More content"
        
        get :index, params: {}, format: :json
        json_response = JSON.parse(response.body)
        puts "DEBUG: JSON response from index: #{json_response.inspect}"
        expect(json_response.size).to eq(2)
        expect(json_response.map { |p| p["title"] }).to include(post1.title, post2.title)
      end
    end

    describe "GET #show" do
      context "when authenticated" do
        before do
          sign_in user
          # By default, mock the token authentication to succeed
          allow(controller).to receive(:authenticate_with_token).and_return(true)
          request.headers['Authorization'] = 'Bearer dummy-token'
        end

        it "returns a success response" do
          post = Post.create! valid_attributes
          get :show, params: { id: post.to_param }, format: :json
          expect(response).to be_successful
          expect(response.content_type).to include('application/json')
        end
      end
      
      it "returns unauthorized without a logged in user" do
        post = Post.create! valid_attributes
        # Don't sign in or mock authentication here to test unauthorized access
        get :show, params: { id: post.to_param }, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "POST #create" do
      context "with valid params" do
        before do
          sign_in user
          # Mock token authentication
          allow(controller).to receive(:authenticate_with_token).and_return(true)
          request.headers['Authorization'] = 'Bearer dummy-token'
        end

        it "creates a new Post" do
          expect {
            post :create, params: { post: valid_attributes }, format: :json
          }.to change(Post, :count).by(1)
        end
        
        it "associates the post with the current user" do
          post :create, params: { post: valid_attributes }, format: :json
          expect(Post.last.created_by).to eq(user)
        end
      end
      
      context "when not authenticated" do
        it "returns unauthorized status" do
          # Don't mock authentication here to test the unauthorized scenario
          post :create, params: { post: valid_attributes }, format: :json
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    describe "PUT #update" do
      context "with valid params" do
        let(:new_attributes) {
          { title: "Updated Title", body: "Updated body content" }
        }

        before do
          # Set up request authentication headers
          request.headers['Authorization'] = 'Bearer dummy-token'
          allow(controller).to receive(:authenticate_with_token).and_return(true)
        end

        it "updates the requested post when user is owner" do
          sign_in post_owner
          put :update, params: { id: owned_post.to_param, post: new_attributes }, format: :json
          owned_post.reload
          expect(owned_post.title).to eq("Updated Title")
          expect(owned_post.body).to eq("Updated body content")
        end
        
        it "allows admin to update any post" do
          post = Post.create! valid_attributes
          sign_in admin
          put :update, params: { id: post.to_param, post: new_attributes }, format: :json
          expect(response).to have_http_status(:ok)
          post.reload
          expect(post.title).to eq(new_attributes[:title])
        end
        
        it "forbids non-owners from updating posts" do
          sign_in user # not the owner
          put :update, params: { id: owned_post.to_param, post: new_attributes }, format: :json
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    describe "DELETE #destroy" do
      before do
        # Set up request authentication headers for all destroy tests
        request.headers['Authorization'] = 'Bearer dummy-token'
        allow(controller).to receive(:authenticate_with_token).and_return(true)
      end

      it "returns a no_content response" do
        sign_in post_owner
        delete :destroy, params: { id: owned_post.to_param }, format: :json
        expect(response).to have_http_status(:no_content)
      end
      
      it "allows admin to destroy any post" do
        post = Post.create! valid_attributes
        sign_in admin
        expect {
          delete :destroy, params: { id: post.to_param }, format: :json
        }.to change(Post, :count).by(-1)
      end
      
      it "forbids non-owners from destroying posts" do
        owned_post # ensure post is created
        sign_in user # not the owner
        expect {
          delete :destroy, params: { id: owned_post.to_param }, format: :json
        }.not_to change(Post, :count)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
  
  # Helper method to simulate user login
  def sign_in(user)
    allow(controller).to receive(:current_user).and_return(user)
    # Set instance variable that would be set by authenticate_with_token
    controller.instance_variable_set(:@current_user, user)
  end
end