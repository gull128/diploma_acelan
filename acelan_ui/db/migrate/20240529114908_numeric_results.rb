class NumericResults < ActiveRecord::Migration[7.0]
  def change
    create_table :numeric_results do |t|
      t.timestamps
    end
  end
end
