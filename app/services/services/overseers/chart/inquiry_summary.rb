class Services::Overseers::Chart::InquirySummary

    def call 
        {
            number_of_inquiries: inquiry_count, 
            conversion_rate: conversion_rate, 
            inquiry_lost_count: lost_count, 
            inquiry_regret_count: regret_count
        }
    end

    private 

    def inquiry_count
        Inquiry.count
    end

    def regret_count
      Inquiry.where(status: 22).count
    end

    def lost_count 
        Inquiry.where(status: 9).count
    end

    def rejected_count 
        
    end

    def conversion_rate 
        ((num_order_won/inquiry_count.to_f)*100).round(2)
    end

    def num_order_won 
        Inquiry.where(status: 18).count
    end
end