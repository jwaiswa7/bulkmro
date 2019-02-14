# frozen_string_literal: true

class Services::Overseers::Inquiries::SmartQueueSummary < Services::Shared::BaseService
  def initialize
  end

  def call
    @statuses = Hash.new
    @statuses['Quotation'] = {
        keys: [
            'New Inquiry',
            'Acknowledgement Mail',
            'Cross Reference',
            'Preparing Quotation',
            'Quotation Sent',
            'Follow Up on Quotation',
            'Expected Order',
            'SO Not Created-Customer PO Awaited'
        ],
        value: 0,
        color: 'dark'
    }

    @statuses['Order Won'] = { keys: ['Order Won'], value: 0, color: 'success' }
    @statuses['SO Draft'] = { keys: ['SO Rejected by Sales Manager', 'SO Draft: Pending Accounts Approval'], value: 0, color: 'warning' }
    @statuses['SO rejected'] = { keys: ['SO Rejected by Sales Manager'], value: 0, color: 'danger' }

    inquiry_statuses = Inquiry.group(:status).count

    Inquiry.statuses.each do |inquiry_status, v|
      @statuses.each do |title, status|
        status[:value] += inquiry_statuses[inquiry_status] if status[:keys].include? inquiry_status && inquiry_status.present?
      end
    end

    @statuses
  end
end
