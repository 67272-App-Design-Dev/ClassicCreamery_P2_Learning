class CreateEmployees < ActiveRecord::Migration[8.1]
  def change
    create_table :employees do |t|
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :ssn
      t.date :date_of_birth
      t.string :role, default: 'employee'
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
