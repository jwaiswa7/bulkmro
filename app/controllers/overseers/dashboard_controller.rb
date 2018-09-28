class Overseers::DashboardController < Overseers::BaseController
	def show
		authorize :dashboard, :show?

	end

	def inquiry_serialize
		# InquiryIndex.delete
		# InquiryIndex.create!
		# InquiryIndex.import
		# InquiriesIndex.reset!
		# ProductsIndex.reset!
		#
		# Inquiry.search('asd')
		#
		#
		authorize :dashboard, :show?
		render json: Serializers::InquirySerializer.new(Inquiry.find(1), { include: [:account, :final_sales_quote] }).serialized_json
	end

	def chewy
		# InquiryIndex.delete
		# InquiryIndex.create!
		# InquiryIndex.import
		InquiriesIndex.reset!
		ProductsIndex.reset!
		#
		# Inquiry.search('asd')
		#
		#
	end
end
