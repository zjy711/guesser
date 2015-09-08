require 'csv'

namespace :candidates do
  desc "Create sample data"
  task :create_sample_data => :environment do
    file_path = Rails.root.join('lib', 'assets', 'sample.csv')

    data = CSV.parse(File.open(file_path), headers: true)

    data.each do |row|
      Candidate.create(gender: row['gender'], height: row['height'].to_f, weight: row['weight'].to_f)
    end
  end
end
