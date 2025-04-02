class CapturesController < ApplicationController
  before_action :set_company, only: :create

  def index
    @companies = Company.all
    @invoices = fetch_invoices
    @checks = fetch_check_invoices
  end

  def create
    ActiveRecord::Base.transaction do
      check = @company.checks.create!(check_params)

      flash[:success] = {
        company_name: @company.name,
        check_number: check.number,
        invoices: check.invoices.pluck(:number)
      }
      
      redirect_to root_path
    rescue ActiveRecord::RecordInvalid => e
      flash[:error] = e.message
      redirect_back(fallback_location: root_path)
    end
  end

  private

  def set_company
    @company = Company.find(params[:company_id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "Company not found"
    redirect_back(fallback_location: root_path)
  end

  def check_params
    params.require(:check).permit(:number, :image_data).merge(
      invoices_attributes: format_invoices
    )
  end

  def format_invoices
    return [] unless params[:invoice_numbers].present?

    params[:invoice_numbers].split(",").map(&:strip).reject(&:empty?).map { |num| { number: num, company_id: @company.id } }
  end

  def fetch_invoices
    Invoice
      .joins(:company, check_invoices: :check)
      .select('invoices.number AS invoice_number, companies.name AS company_name, checks.number AS check_number')
      .order('invoices.created_at DESC')
  end

  def fetch_check_invoices
    Check
      .includes(:image_attachment, :image_blob)
      .joins(:company, check_invoices: :invoice)
      .select('checks.id AS id, checks.number AS check_number, checks.created_at, companies.name, checks.image, STRING_AGG(invoices.number, \', \') AS invoice_numbers')
      .group('checks.id, companies.name, checks.image, checks.created_at')
      .order('checks.created_at DESC')
  end
end