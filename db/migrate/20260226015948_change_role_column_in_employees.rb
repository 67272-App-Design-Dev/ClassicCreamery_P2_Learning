class ChangeRoleColumnInEmployees < ActiveRecord::Migration[8.1]
  def up
    remove_column :employees, :role
    add_column :employees, :role, :integer, default: 1
  end

  def down
    remove_column :employees, :role
    add_column :employees, :role, :string, default: "employee"
  end
end
