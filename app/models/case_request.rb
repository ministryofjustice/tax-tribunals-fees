class CaseRequest < ApplicationRecord
  has_many :fee_liabilities

  validates :case_reference, :case_title, :glimr_jurisdiction, presence: true

  def fee_liabilities?
    fee_liabilities.exists?
  end
end
