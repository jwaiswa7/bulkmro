class Services::Customers::Playments::PlaymentCreate < Services::Shared::BaseService
  def initialize
  end

  def get_images
    [{blob: "blob1", image_url: "https://dummyimage.com/600x400/000/fff.jpg&text=Dummy+Image+1", image_name: "DummyImage1"},
     {blob: "blob2", image_url: "https://dummyimage.com/600x400/000/fff.jpg&text=Dummy+Image+2", image_name: "DummyImage2"},
     {blob: "blob3", image_url: "https://dummyimage.com/600x400/000/fff.jpg&text=Dummy+Image+3", image_name: "DummyImage3"}]
  end

  def call
    temp_array = get_images

    temp_array.each do |arr|
      reference_id = "#{arr[:blob]}"
      image_name = "#{arr[:image_name]}"
      image_url = "#{arr[:image_url]}"
      request = HTTParty.post("https://api.playment.in/v1/project/fd3f4026-a21e-4191-9373-3e775c494d3e/feedline",
                              body: {reference_id: reference_id, data: { image_url: image_url }, tag: "bulkmro"}.to_json)
      # request = HTTParty.get("http://localhost:3000/customers/playments/get_data", body: {reference_id: reference_id, data: { image_url: image_url }, tag: "bulkmro"}.to_json)
      response = request.parsed_response
      if response[:status] == "success"
        begin
          ActiveRecord::Base.transaction do
            Playment.where(image_name: image_name).first_or_create do |record|
              record.reference_id = response[:feed_line_unit][:reference_id]
              record.image_url = image_url
              record.status = response.status
              record.request = request.body
              record.response = response.parsed_response
              record.flu_id = response[:feed_line_unit][:flu_id]
            end
          end
        rescue ActiveRecord::RecordInvalid => exception
          puts exception.message
        end
      end
    end
  end

  # private

  # attr_reader :sales_order, :overseer, :comment
end