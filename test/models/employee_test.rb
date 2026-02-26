require "test_helper"

class EmployeeTest < ActiveSupport::TestCase
  should validate_presence_of(:first_name)
  should validate_presence_of(:last_name)
  should validate_presence_of(:ssn)
  should allow_value("admin").for(:role)
  should allow_value("manager").for(:role)
  should allow_value("employee").for(:role)

  should "test A" do
    assert_equal({"employee" => 1, "manager" => 2, "admin" => 3}, Employee.roles)
  end

  should "test B" do
    vy = Employee.new
    assert_equal "employee", vy.role
  end

  should "test C" do
    profh = Employee.new(role: "admin")
    assert profh.respond_to?(:admin_role?)
    assert profh.respond_to?(:manager_role?)
    assert profh.respond_to?(:employee_role?)
  end

  context "Given context" do
    setup do
      create_employees
    end

    should "test D" do
      steve = FactoryBot.build(:employee, first_name: "Steve",
      last_name: "Crawford", ssn: "084359822")
      deny steve.valid?
    end

    should "test E" do
      assert_equal ["Crawford", "Gruberman", "Heimann", "Waldo"],
      Employee.alphabetical.map{|e| e.last_name}
    end

    should "test F" do
      assert_equal 3, Employee.regulars.size
      assert_equal ["Crawford", "Gruberman", "Waldo"],
      Employee.regulars.map{|e| e.last_name}.sort
    end

    should "test G" do
      create_stores
      create_assignments
      assert_equal ["Waldo", "Heimann"], Employee.unassigned.map{|e| e.last_name}
      destroy_assignments
      destroy_stores
    end

    should "test H" do
      assert_equal "Heimann, Alex", @alex.name
    end

    should "test I" do
      assert @ed.over_18?
      deny @cindy.over_18?
    end

    should "test J" do
      create_stores
      create_assignments
      assert_equal @assign_ed, @ed.current_assignment
      assert_equal @promote_cindy, @cindy.current_assignment
      assert_nil @alex.current_assignment
      destroy_assignments
      destroy_stores
    end
  end
end
