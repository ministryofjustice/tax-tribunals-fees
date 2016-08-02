class CaseRequest < ApplicationRecord
  has_many :liabilities

  validates :case_reference, :case_title, :glimr_jurisdiction, presence: true

  def liabilities?
    liabilities.exists?
  end
end
