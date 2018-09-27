class Overseers::DashboardController < Overseers::BaseController
	def show
		authorize :dashboard, :show?

	end

	def chewy
		# InquiryIndex.delete
		# InquiryIndex.create!
		# InquiryIndex.import
		InquiryIndex.reset!
		#
		Inquiry.search('asd')

		raise
	end
end
