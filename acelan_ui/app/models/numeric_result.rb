class NumericResult < ApplicationRecord
  has_many_attached :images
  has_one_attached :solution
end