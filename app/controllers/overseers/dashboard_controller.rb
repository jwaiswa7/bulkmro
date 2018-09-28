class Overseers::DashboardController < Overseers::BaseController
	def show
		authorize :dashboard, :show?

	end

	def chewy
		# InquiriesIndex.delete
		# InquiriesIndex.create!
		# InquiriesIndex.import
		InquiriesIndex.reset!
		#
		Inquiry.search('asd')

		raise
	end
end
