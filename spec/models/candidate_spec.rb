require 'rails_helper'

RSpec.describe Candidate, type: :model do
  describe ".build_ratios" do
    it "should set @@ratios with correct values" do
      Candidate.create(guess: nil, gender: 'F', height: 150, weight: 100)
      Candidate.create(guess: nil, gender: 'F', height: 170, weight: 120)
      Candidate.create(guess: 'F', gender: 'F', height: 180, weight: 140)
      Candidate.create(guess: nil, gender: 'M', height: 170, weight: 150)
      Candidate.create(guess: nil, gender: 'M', height: 180, weight: 190)
      Candidate.create(guess: 'M', gender: 'F', height: 172, weight: 130)

      Candidate.build_ratios
      ratios = Candidate.class_variable_get(:@@ratios)

      expect(ratios[:female][0]).to eq (100.0 / 150.0).round(5)
      expect(ratios[:female][1]).to eq (120.0 / 170.0).round(5)

      expect(ratios[:male][0]).to eq (150.0 / 170.0).round(5)
      expect(ratios[:male][1]).to eq (190.0 / 180.0).round(5)
    end
  end

  describe ".after_save" do
    it "should rebuild ratios after new candidate is saved" do
      Candidate.should_receive :build_ratios
      Candidate.create(guess: nil, gender: 'F', height: 150, weight: 100)
    end

    it "should rebuild ratios after a candidate is updated" do
      Candidate.should_receive(:build_ratios).twice
      c = Candidate.create(guess: nil, gender: 'F', height: 150, weight: 100)
      c.update(gender: 'M')
    end
  end

  describe ".insufficient_sample_data" do
    it "returns true if ratios is empty" do
      Candidate.class_variable_set(:@@ratios, {})
      expect(Candidate.insufficient_sample_data?(0.8)).to eq true
    end

    it "returns true if ratio is outside of the only one ratio range" do
      Candidate.class_variable_set(:@@ratios, { female: [1, 1.2]})
      expect(Candidate.insufficient_sample_data?(0.8)).to eq true
    end

    it "returns false if both ratio ranges are set" do
      Candidate.class_variable_set(:@@ratios, { female: [1, 1.2], male: [1.4, 1.8]})
      expect(Candidate.insufficient_sample_data?(0.8)).to eq false
    end
  end

  describe ".guess_gender" do
    context "male ratio range and female ratio range overlaps" do
      it "should return the gender with less ratio difference" do
        ratios = { female: [1.1, 1.5], male: [1.2, 1.8]}
        Candidate.class_variable_set(:@@ratios, ratios)

        expect(Candidate.guess_gender(1.4)).to eq 'F'
      end

      it "should return the 'M' if the ratio difference to male and female are equal" do
        ratios = { female: [1.1, 1.5], male: [1.2, 1.8]}
        Candidate.class_variable_set(:@@ratios, ratios)

        expect(Candidate.guess_gender(1.35)).to eq 'M'
      end
    end

    context "male ratio range and female rato range don't overlap" do
      it "should return 'F' if ratio is greater than female max ratio" do
        ratios = { female: [1.1, 1.5], male: [1.7, 1.9]}
        Candidate.class_variable_set(:@@ratios, ratios)

        expect(Candidate.guess_gender(1.4)).to eq 'F'
      end

      it "should return 'M' if ratio is less than male min ratio" do
        ratios = { female: [1.1, 1.5], male: [1.7, 1.9]}
        Candidate.class_variable_set(:@@ratios, ratios)

        expect(Candidate.guess_gender(1.8)).to eq 'M'
      end

      it "should return the gender with less ratio difference if ratio is outside of feamle and male range" do
        ratios = { female: [1.1, 1.5], male: [1.7, 1.9]}
        Candidate.class_variable_set(:@@ratios, ratios)

        expect(Candidate.guess_gender(1.55)).to eq 'F'
      end

      it "should return the 'M' if the ratio difference to male and female are equal" do
        ratios = { female: [1.1, 1.5], male: [1.7, 1.9]}
        Candidate.class_variable_set(:@@ratios, ratios)

        expect(Candidate.guess_gender(1.6)).to eq 'M'
      end
    end
  end
end