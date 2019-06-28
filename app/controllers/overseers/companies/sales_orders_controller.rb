# frozen_string_literal: true

class Overseers::Companies::SalesOrdersController < Overseers::Companies::BaseController
  def index
    @sales_orders = ApplyDatatableParams.to(@company.sales_orders.remote_approved, params.reject! { |k, _v| k == 'company_id' })
    authorize_acl @sales_orders
  end
end
