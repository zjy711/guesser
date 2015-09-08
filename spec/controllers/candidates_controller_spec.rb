require "rails_helper"

RSpec.describe CandidatesController, :type => :controller do
  describe "GET #index" do
    it "responds successfully with 200 status code" do
      get :index
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
    end

    it "loads all of the posts into @candidates" do
      candidates1 = Candidate.create(guess: 'M', gender: 'F', height: 150, weight: 100)
      candidates2 = Candidate.create(guess: 'F', gender: 'F', height: 170, weight: 120)

      get :index
      expect(assigns(:candidates)).to match_array([candidates1, candidates2])
    end
  end

  describe "GET #show" do
    before do
      @candidate = Candidate.create(guess: 'M', gender: 'F', height: 150, weight: 100)
    end

    it "responds successfully with 200 status code" do
      get :show, 'id' => @candidate.id
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "renders the show template" do
      get :show, 'id' => @candidate.id
      expect(response).to render_template("show")
    end

    it "assigns the right candidate into @candidate" do
      get :show, 'id' => @candidate.id
      expect(assigns(:candidate).id).to eq @candidate.id
    end
  end

  describe "POST #create" do
    it "responds successfully with 200 status code" do
      allow(Candidate).to receive(:guess_gender).and_return 'F'
      expect(response).to be_success
      expect(response).to have_http_status(200)
      post :create, 'candidate' => { 'height' => 150, 'weight' => 100 }
    end

    it "redirects to the show page" do
      allow(Candidate).to receive(:guess_gender).and_return 'F'
      post :create, 'candidate' => { 'height' => 150, 'weight' => 100 }
      candidate_id = Candidate.where(weight: 100, height: 150, guess: 'F').first.id
      expect(response).to redirect_to action: :show, id: candidate_id
    end

    it "loads the correct candidate into @candidate" do
      allow(Candidate).to receive(:guess_gender).and_return 'F'
      post :create, 'candidate' => { 'height' => 150, 'weight' => 100 }

      candidate = assigns(:candidate)
      expect(candidate.guess).to eq 'F'
      expect(candidate.height).to eq 150
      expect(candidate.weight).to eq 100
    end

    it "guess gender based on weight and height" do
      expect(Candidate).to receive(:guess_gender).with( 100.to_f / 150.to_f )
      post :create, 'candidate' => { 'height' => 150, 'weight' => 100 }
    end
  end

  describe "POST #update" do
    before do
      @candidate = Candidate.create(guess: 'M', gender: 'M', height: 150, weight: 100)
    end

    it "responds successfully with 302 status code" do
      put :update, 'candidate' => { 'height' => 155, 'weight' => 98, 'gender' => 'F' }, 'id' => @candidate.id
      expect(response).to have_http_status(302)
    end

    it "redirects to the index page" do
      put :update, 'candidate' => { 'height' => 155, 'weight' => 98, 'gender' => 'F' }, 'id' => @candidate.id
      expect(response).to redirect_to action: :index
    end

    it "updates @candidate to the correct value" do
      put :update, 'candidate' => { 'height' => 155, 'weight' => 98, 'gender' => 'F' }, 'id' => @candidate.id

      candidate = assigns(:candidate)
      expect(candidate.gender).to eq 'F'
      expect(candidate.height).to eq 155
      expect(candidate.weight).to eq 98
    end
  end

  describe "DELETE #destroy" do
    before do
      @candidate = Candidate.create(guess: 'M', gender: 'M', height: 150, weight: 100)
    end

    it "responds successfully with 302 status code" do
      delete :destroy, 'id' => @candidate.id
      expect(response).to have_http_status(302)
    end

    it "redirects to the index page" do
      delete :destroy, 'id' => @candidate.id
      expect(response).to redirect_to action: :index
    end

    it "deleted the correct candidate" do
      delete :destroy, 'id' => @candidate.id
      expect(Candidate.all.size).to eq 0
    end
  end
end