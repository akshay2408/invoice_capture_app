class Company < ApplicationRecord
  has_many :invoices
  has_many :checks
  accepts_nested_attributes_for :checks

end
