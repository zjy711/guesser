class CandidatesController < ApplicationController
  respond_to :html
  before_filter :build_ratios, only: [:new, :edit]

  def index
    @candidates = Candidate.all
  end

  def new
    @candidate = Candidate.new
  end

  def create
    ratio = params[:candidate][:weight].to_f / params[:candidate][:height].to_f
    guess = Candidate.guess_gender(ratio)
    @candidate = Candidate.create(new_candidate_params.merge(guess: guess))
    respond_with @candidate
  end

  def show
    @candidate = find_candidate
  end

  def edit
    @candidate = find_candidate
  end

  def update
    @candidate = find_candidate
    @candidate.update(update_candidate_params)
    redirect_to candidates_path
  end

  def destroy
    candidate = find_candidate
    candidate.destroy
    redirect_to candidates_path
  end

  private
    def find_candidate
      Candidate.find(params[:id])
    end

    def new_candidate_params
      params.require(:candidate).permit(:height, :weight)
    end

    def update_candidate_params
      params.require(:candidate).permit(:height, :weight, :gender)
    end

    def build_ratios
      Candidate.build_ratios
    end
end
