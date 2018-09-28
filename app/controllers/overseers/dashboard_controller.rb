class Overseers::DashboardController < Overseers::BaseController
	def show
		authorize :dashboard, :show?

	end

	def chewy
		# InquiryIndex.delete
		# InquiryIndex.create!
		# InquiryIndex.import
		# InquiriesIndex.reset!
		ProductsIndex.reset!
		#
		# Inquiry.search('asd')
		#
		# raise
	end
end
