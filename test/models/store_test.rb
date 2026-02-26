require "test_helper"

class StoreTest < ActiveSupport::TestCase
  # -- Relationships --
  should have_many(:assignments)
  should have_many(:employees).through(:assignments)

  context "Within context" do
    setup do
      create_stores
    end

    teardown do
      destroy_stores
    end

    # -- Validations: name --
    context "Validating name" do
      should "be invalid without a name" do
        @pittsburgh.name = nil
        deny @pittsburgh.valid?
      end

      should "be invalid with a duplicate name (same case)" do
        dupe = Store.new(name: "Pittsburgh", street: "1 Penn Ave", city: "Pittsburgh",
                         state: "PA", zip: "15222", phone: "4122221111")
        deny dupe.valid?
      end

      should "be invalid with a duplicate name (different case)" do
        dupe = Store.new(name: "pittsburgh", street: "1 Penn Ave", city: "Pittsburgh",
                         state: "PA", zip: "15222", phone: "4122221111")
        deny dupe.valid?
      end

      should "be valid with a unique name" do
        new_store = Store.new(name: "Weirton", street: "1 Main St", city: "Weirton",
                              state: "WV", zip: "26062", phone: "3042221111")
        assert new_store.valid?
      end
    end

    # -- Validations: street --
    context "Validating street" do
      should "be invalid without a street" do
        @pittsburgh.street = nil
        deny @pittsburgh.valid?
      end
    end

    # -- Validations: city --
    context "Validating city" do
      should "be invalid without a city" do
        @pittsburgh.city = nil
        deny @pittsburgh.valid?
      end
    end

    # -- Validations: state --
    context "Validating state" do
      should "be invalid without a state" do
        @pittsburgh.state = nil
        deny @pittsburgh.valid?
      end

      should "accept PA as a valid state" do
        @pittsburgh.state = "PA"
        assert @pittsburgh.valid?
      end

      should "accept OH as a valid state" do
        @pittsburgh.state = "OH"
        assert @pittsburgh.valid?
      end

      should "accept WV as a valid state" do
        @pittsburgh.state = "WV"
        assert @pittsburgh.valid?
      end

      should "reject a state outside PA, OH, and WV" do
        @pittsburgh.state = "NY"
        deny @pittsburgh.valid?
      end
    end

    # -- Validations: zip --
    context "Validating zip" do
      should "be invalid without a zip" do
        @pittsburgh.zip = nil
        deny @pittsburgh.valid?
      end

      should "be invalid when zip is fewer than 5 digits" do
        @pittsburgh.zip = "1234"
        deny @pittsburgh.valid?
      end

      should "be invalid when zip is more than 5 digits" do
        @pittsburgh.zip = "123456"
        deny @pittsburgh.valid?
      end

      should "be invalid when zip contains non-digit characters" do
        @pittsburgh.zip = "1234a"
        deny @pittsburgh.valid?
      end

      should "be valid with a proper 5-digit zip" do
        @pittsburgh.zip = "15217"
        assert @pittsburgh.valid?
      end
    end

    # -- Validations: phone --
    context "Validating phone" do
      should "be invalid without a phone" do
        @pittsburgh.phone = nil
        deny @pittsburgh.valid?
      end

      should "be invalid when fewer than 10 digits are given" do
        @pittsburgh.phone = "412123456"
        deny @pittsburgh.valid?
      end

      should "be invalid when more than 10 digits are given" do
        @pittsburgh.phone = "41212345678"
        deny @pittsburgh.valid?
      end

      should "accept a plain 10-digit phone number" do
        store = Store.new(name: "Weirton", street: "1 Main St", city: "Weirton",
                          state: "WV", zip: "26062", phone: "3041234567")
        assert store.valid?
        assert_equal "3041234567", store.phone
      end

      should "accept phone with dashes and normalize to 10 digits" do
        store = Store.new(name: "Weirton", street: "1 Main St", city: "Weirton",
                          state: "WV", zip: "26062", phone: "304-123-4567")
        assert store.valid?
        assert_equal "3041234567", store.phone
      end

      should "accept phone with dots and normalize to 10 digits" do
        store = Store.new(name: "Weirton", street: "1 Main St", city: "Weirton",
                          state: "WV", zip: "26062", phone: "304.123.4567")
        assert store.valid?
        assert_equal "3041234567", store.phone
      end

      should "accept phone with parentheses and spaces and normalize to 10 digits" do
        store = Store.new(name: "Weirton", street: "1 Main St", city: "Weirton",
                          state: "WV", zip: "26062", phone: "(304) 123-4567")
        assert store.valid?
        assert_equal "3041234567", store.phone
      end
    end

    # -- Scopes --
    context "For scopes" do
      should "return only active stores with the active scope" do
        active = Store.active.to_a
        assert_includes active, @pittsburgh
        assert_includes active, @bethany
        assert_includes active, @cmu
        deny active.include?(@cleveland)
      end

      should "return only inactive stores with the inactive scope" do
        inactive = Store.inactive.to_a
        assert_includes inactive, @cleveland
        deny inactive.include?(@pittsburgh)
        deny inactive.include?(@bethany)
        deny inactive.include?(@cmu)
      end

      should "return all stores in alphabetical order by name" do
        # SQLite binary sort: uppercase letters (A-Z) sort before lowercase (a-z),
        # so "CMU" (C-M-U) comes before "Cleveland" (C-l-e...) because 'M' < 'l' in ASCII.
        assert_equal [@bethany, @cmu, @cleveland, @pittsburgh], Store.alphabetical.to_a
      end
    end

    # -- Methods --
    context "For make_active" do
      should "set active to true and persist the change" do
        @cleveland.make_active
        assert @cleveland.active
        assert Store.find(@cleveland.id).active
      end
    end

    context "For make_inactive" do
      should "set active to false and persist the change" do
        @pittsburgh.make_inactive
        deny @pittsburgh.active
        deny Store.find(@pittsburgh.id).active
      end
    end
  end
end
