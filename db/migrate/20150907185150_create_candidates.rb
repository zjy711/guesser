class CreateCandidates < ActiveRecord::Migration
  def change
    create_table :candidates do |t|
      t.string :gender
      t.string :guess
      t.float :weight
      t.float :height

      t.timestamps null: false
    end
  end
end
