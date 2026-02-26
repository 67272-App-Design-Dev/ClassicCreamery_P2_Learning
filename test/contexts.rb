module Contexts
  # -- Store contexts --
  def create_stores
    @bethany    = Store.create!(name: "Bethany",    street: "300 College St",  city: "Bethany",    state: "WV", zip: "26032", phone: "3041234567", active: true)
    @cleveland  = Store.create!(name: "Cleveland",  street: "200 Euclid Ave",  city: "Cleveland",  state: "OH", zip: "44101", phone: "2161234567", active: false)
    @pittsburgh = Store.create!(name: "Pittsburgh", street: "100 Forbes Ave",  city: "Pittsburgh", state: "PA", zip: "15213", phone: "4121234567", active: true)
  end

  def destroy_stores
    Store.delete_all
  end
end
