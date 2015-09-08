class Candidate < ActiveRecord::Base
  validates :height, :weight, presence: true, numericality: true
  validates :gender, :guess, inclusion: { in: ['F', 'M']}, allow_nil: true

  @@ratios = {}

  after_save do
    Candidate.build_ratios
  end

  def self.build_ratios
    ratios_for_female = Candidate.where(guess: nil, gender: 'F').map {|c| (c.weight / c.height).round(5)}.sort
    ratios_for_male   = Candidate.where(guess: nil, gender: 'M').map {|c| (c.weight / c.height).round(5)}.sort

    @@ratios = { female: [ratios_for_female.min, ratios_for_female.max],
                 male:   [ratios_for_male.min,   ratios_for_male.max  ]
               }
  end

  def self.guess_gender(ratio)
    return "I don't have enough data to guess.." if self.insufficient_sample_data?(ratio)

    male_max_ratio,   male_min_ratio   = @@ratios[:male][1],   @@ratios[:male][0]
    female_max_ratio, female_min_ratio = @@ratios[:female][1], @@ratios[:female][0]

    d_to_female_max = (ratio - female_max_ratio).round(5).abs
    d_to_male_min   = (ratio - male_min_ratio).round(5).abs

    (d_to_female_max >= d_to_male_min) ? 'M' : 'F'
  end

  def self.insufficient_sample_data?(ratio)
    return true if @@ratios.empty?

    if @@ratios[:female].nil? || @@ratios[:female].empty?
      return true if (ratio < @@ratios[:male][0] || ratio > @@ratios[:male][1])
    end

    if @@ratios[:male].nil? || @@ratios[:male].empty?
      return true if (ratio < @@ratios[:female][0] || ratio > @@ratios[:female][1])
    end

    false
  end
end
