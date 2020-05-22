require 'net/http'
require 'uri'

class Services::Shared::Chewy::RemoveOutdatedIndices < Services::Shared::BaseService
  def delete_outdated_indices
    es_url = ENV['FOUNDELASTICSEARCH_URL']
    # es_url = 'http://localhost:9200'
    indices_uri = URI.parse("#{es_url}/_cat/indices?h=index")
    ind_request = Net::HTTP::Get.new(indices_uri)
    ind_request.basic_auth(ENV['ELASTIC_USER_NAME'], ENV['ELASTIC_PASSWORD'])

    req_options = {
        use_ssl: indices_uri.scheme == 'https',
    }

    ind_response = Net::HTTP.start(indices_uri.hostname, indices_uri.port, req_options) do |http|
      http.request(ind_request)
    end

    data = ind_response.body
    indexes = data.split("\n")

    indexes.each do |index|
      timestamp = index.split('_').last.to_i
      date = Time.at(timestamp / 1000).to_date
      if date < Date.today - 5.days
        begin
          uri = URI.parse("#{es_url}/#{index}")
          request = Net::HTTP::Delete.new(uri)
          request.basic_auth(ENV['ELASTIC_USER_NAME'], ENV['ELASTIC_PASSWORD'])
          req_options = {
              use_ssl: uri.scheme == 'https',
          }
          response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
            http.request(request)
          end
          puts "Response----------#{response.body}----#{index}------------------"
        rescue StandardError => e
          puts "Error----------#{e}----------------------"
        end
      else
        puts "index----------#{index}----------------------"
      end
    end
  end
end
