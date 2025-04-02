class Check < ApplicationRecord
  belongs_to :company
  has_many :check_invoices, dependent: :destroy
  has_many :invoices, through: :check_invoices

  accepts_nested_attributes_for :invoices
  has_one_attached :image
  attr_accessor :image_data
  validates :number, presence: true, uniqueness: true

  before_save :attach_image

  private

  def attach_image
    return unless !image_data.nil? || image_data.include?(',')

    decoded_image = Base64.decode64(image_data.split(',')[1])
    io = StringIO.new(decoded_image)
    self.image.attach(io: io, filename: "check.png", content_type: "image/png")
  end
end
