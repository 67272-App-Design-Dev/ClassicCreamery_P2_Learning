FactoryBot.define do
  factory :employee do
    first_name { "MyString" }
    last_name { "MyString" }
    phone { "MyString" }
    ssn { "MyString" }
    date_of_birth { "2026-02-26" }
    role { "MyString" }
    active { false }
  end
end
