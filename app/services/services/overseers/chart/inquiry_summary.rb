class Services::Overseers::Chart::InquirySummary
    def initialize
      @start_of_financial_year = Date.today.beginning_of_financial_year
      @end_of_financial_year = Date.today.end_of_financial_year
      @inquiries = Inquiry.where(created_at: start_of_financial_year .. end_of_financial_year)
    end

    def call 
        {
            number_of_inquiries: inquiry_count, 
            conversion_rate: conversion_rate, 
            inquiry_lost_count: lost_count, 
            inquiry_regret_count: regret_count, 
            invoiced_count: invoiced_count, 
            inquiry_rejection_rate: inquiry_rejection_rate, 
            sales_quotes: count_sales_quotes, 
            inquiry_count_order_won: inquiry_count_order_won, 
        }
    end

    private 

    attr_accessor :start_of_financial_year, :end_of_financial_year, :inquiries

    def inquiry_count_order_won
        inquiries.where(status: 18).count
    end

    def inquiry_count
        inquiries.count
    end

    def regret_count
        inquiries.where(status: 10).count
    end

    def lost_count 
        inquiries.where(status: 9).count
    end

    def inquiry_rejected_count 
        # SO Rejected by Sales Manager + Rejected by Accounts
        inquiries.where(status: 17).count + inquiries.where(status: 19).count 
    end

    def inquiry_rejection_rate
        return nil if inquiry_rejected_count.zero?
        inquiry_count/inquiry_rejected_count
    end

    def conversion_rate 
        return nil if inquiry_count.zero?
        ((num_order_won/inquiry_count.to_f)*100).round(2)
    end

    def num_order_won 
        inquiries.where(status: 18).count
    end

    def invoiced_count 
        SalesInvoice.where(created_at: start_of_financial_year .. end_of_financial_year).not_cancelled_invoices.count
    end

    def count_sales_quotes 
        SalesQuote.where(created_at: start_of_financial_year .. end_of_financial_year).count
    end
end