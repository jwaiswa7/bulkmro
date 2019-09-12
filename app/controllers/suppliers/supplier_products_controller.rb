class Suppliers::SupplierProductsController < Suppilers::BaseController
  before_action :set_supplier_product, only: [:show]

  def index
    authorize :supplier_product

    if params[:view] == 'list_view'
      params[:per] = 20
    else
      params[:page] = 1 unless params[:page].present?
      params[:per] = 24
    end

    @supplier_products = ApplyDatatableParams.to(InquiryProductSupplier.where(supplier_id: current_company.id).uniq.order(id: :desc), params)
    # service = Services::Suppliers::Finders::SupplierProducts.new(params, current_contact, current_company)
    # service.call
    # @indexed_supplier_products = service.indexed_records
    # @supplier_products = service.records.try(:reverse)
    # @default_quantity = nil
    # @supplier_products_paginate = @indexed_supplier_products.page(params[:page]) if params[:page].present?
  end

  # def autocomplete
  #   service = Services::Suppliers::Finders::SupplierProducts.new(params.merge(page: 1))
  #   service.call
  #
  #   @indexed_supplier_products = service.indexed_records
  #   @supplier_products = service.records
  #   authorize @supplier_products
  # end

  def show
    authorize @supplier_product
  end

  private

  def set_supplier_product
    @supplier_product ||= Product.find(params[:id])
  end
end
