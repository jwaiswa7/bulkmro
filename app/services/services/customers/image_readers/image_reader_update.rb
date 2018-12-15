class Services::Customers::ImageReaders::ImageReaderUpdate < Services::Shared::BaseService
  URL = 'https://api.playment.in/v1/project/fd3f4026-a21e-4191-9373-3e775c494d3e/feedline'

  def initialize(params)
    @params = params
  end

  def call
    response = {:success => false}
    begin
      ActiveRecord::Base.transaction do

        params["feed_line_units"].each do |image|
          flu_id = image[:flu_id]
          image_reader = ImageReader.find_by_flu_id(flu_id)

          if image_reader.present?
            image_reader.status = :completed
            if image[:result].present?
              image_reader.meter_number = image[:result][:meter_number] if image[:result][:meter_number].present?
              image_reader.meter_reading = image[:result][:meter_reading] if image[:result][:meter_reading].present?
            end

            if image_reader.save
              response[:success] = true
            end
          end
        end if params["feed_line_units"].present? && params["feed_line_units"].kind_of?(Array)

      end

    rescue ActiveRecord::RecordInvalid => exception
      puts exception.message
    end

    response
  end

  # private

  attr_reader :params
end