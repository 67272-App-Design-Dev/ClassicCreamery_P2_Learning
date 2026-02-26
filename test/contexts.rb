module Contexts
  # -- Store contexts --
  def create_stores
    @bethany    = Store.create!(name: "Bethany",    street: "300 College St", city: "Bethany",    state: "WV", zip: "26032", phone: "3041234567", active: true)
    @cleveland  = Store.create!(name: "Cleveland",  street: "200 Euclid Ave", city: "Cleveland",  state: "OH", zip: "44101", phone: "2161234567", active: false)
    @pittsburgh = Store.create!(name: "Pittsburgh", street: "100 Forbes Ave", city: "Pittsburgh", state: "PA", zip: "15213", phone: "4121234567", active: true)
    @cmu        = FactoryBot.create(:store)
  end

  def destroy_stores
    Store.delete_all
  end

  def create_employees
    @ed = FactoryBot.create(:employee)
    @cindy = FactoryBot.create(:employee, first_name: "Cindy", last_name: "Crawford", ssn: "084-35-9822", date_of_birth: 17.years.ago.to_date)
    @chuck = FactoryBot.create(:employee, first_name: "Chuck", last_name: "Waldo", date_of_birth: 26.years.ago.to_date, active: false)
    @alex = FactoryBot.create(:employee, first_name: "Alex", last_name: "Heimann", role: "admin")
  end

  def create_assignments
    @assign_ed = FactoryBot.create(:assignment, employee: @ed, store: @cmu, end_date: nil)
    @assign_cindy = FactoryBot.create(:assignment, employee: @cindy, store: @cmu, start_date: 2.years.ago.to_date, end_date: 6.months.ago.to_date)
    @promote_cindy = FactoryBot.create(:assignment, employee: @cindy, store: @cmu, start_date: 6.months.ago.to_date, end_date: nil)
  end

  def destroy_assignments
    Assignment.delete_all
  end
end
