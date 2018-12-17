class Services::Customers::ImageReaders::ImageReaderCreate < Services::Shared::BaseService
  if Rails.env.production?
    URL = 'https://api.playment.in/v1/project/fd3f4026-a21e-4191-9373-3e775c494d3e/feedline'
    CONTAINER = 'images'
    KEY = "Uhs8H1Qrkf0VsQM0Owz7nX5jFUc28rhSTlYPRUSXo5o"
  elsif Rails.env.staging?
    URL = 'https://api.playment.in/v1/project/10574135-d26d-4352-96e9-adffd9a032d8/feedline'
    CONTAINER = 'staging'
    KEY = "qJsaya4SP75m9Wtsz0hj+90PoROrTUlrOYmtmRAEZ0o"
  else
    URL = 'http://localhost:3002/catch'
    CONTAINER = 'staging'
    KEY = "qJsaya4SP75m9Wtsz0hj+90PoROrTUlrOYmtmRAEZ0o"
  end

  def initialize
    @images = []
    @azure_storage_config = {
        :name => 'imager',
        :key => 'wH/dYhTNW30yU8/3Bv+0cmZQz/y/8dMGMMLB/pL4/f5colupJTFicVcHd56JTa7f0ZJvrZDCYxU59WmdfvuOyg==',
        :container => CONTAINER,
        :base_url => 'https://imager.blob.core.windows.net/images/'
    }
  end

  def call
    call_later
  end

  def call_later
    read_images
    #remove_old_files
  end

  def read_images

    begin
      # Create a BlobService object
      blob_client = Azure::Storage::Blob::BlobService.create(
          storage_account_name: azure_storage_config[:name],
          storage_access_key: azure_storage_config[:key]
      )
      container_name = azure_storage_config[:container]

      # List the blobs in the container
      # puts "\nList blobs in the container following continuation token"

      nextMarker = nil
      # i = 0

      loop do
        @images = []

        blobs = blob_client.list_blobs(container_name, {marker: nextMarker, max_results: 1000})
        blobs.each do |blob|
          puts "\tBlob name #{blob.name} #{blob.properties[:last_modified]}"
          puts "\tLink #{[azure_storage_config[:base_url], blob.name].join}"
          images << {blob: blob.to_json, image_url: [azure_storage_config[:base_url], blob.name].join, image_name: blob.name}
        end

        # i += 1
        # puts "\t Iteration #{i} #{blobs.continuation_token}"

        nextMarker = blobs.continuation_token

        send_and_register_request(images)
        # puts images, images.size

        break unless (nextMarker && !nextMarker.empty?)
      end


    rescue Exception => e

      puts e.message

    ensure

      # Clean up resources. This includes the container and the temp files

    end


  end

  def send_and_register_request(images)

    images.each do |image|


      # request = HTTParty.post("https://api.playment.in/v1/project/fd3f4026-a21e-4191-9373-3e775c494d3e/feedline", body: {reference_id: reference_id, data: {image_url: image_url}, tag: "bulkmro"}.to_json)

=begin
       response = {
                    "feed_line_unit": {
                      "flu_id": "33abc3fe-9fbc-4d7c-b951-a1d1bfb6f80",
                      "reference_id": "ref_id_1",
                      "tag": "image_qc"
                    },
                    "success": true
                  }
=end
      begin
        ActiveRecord::Base.transaction do


          blob = image[:blob]
          image_name = image[:image_name]
          image_url = image[:image_url]

          if (ImageReader.find_by_image_url(image_url).blank?)


            image_reader = ImageReader.where(image_url: image_url).first_or_create! do |record|
              record.image_name = image_name
              record.status = :pending
            end
            reference_id = image_reader.to_sgid(expires_in: (24 * 7).hours, for: 'image_reader').to_s
            image_reader.reference_id = reference_id
            request = {reference_id: reference_id, data: {image_url: image_url}, tag: "bulkmro"}
            image_reader.request = request.merge({blob: blob})
            image_reader.save


            response = HTTParty.post(URL, body: request, headers: {:"x-client-key" => KEY})
            validated_response = get_validated_response(response)

            status = validated_response[:error_message].blank? ? :successful : :failed


            image_reader.status = status
            image_reader.response = validated_response
            image_reader.flu_id = status == :successful ? validated_response[:feed_line_unit][:flu_id] : nil
            image_reader.save
          end
        end
      rescue ActiveRecord::RecordInvalid => exception
        puts exception.message
      end
    end
  end

  def get_validated_response(raw_response)
    if raw_response['success'] == true
      OpenStruct.new(raw_response.parsed_response.deep_symbolize_keys)
    elsif raw_response['error']
      {raw_response: raw_response, error_message: raw_response['error']['message']}
    else
      {raw_response: raw_response, error_message: raw_response.to_s}
    end
  end

  # private

  attr_reader :azure_storage_config, :images
end