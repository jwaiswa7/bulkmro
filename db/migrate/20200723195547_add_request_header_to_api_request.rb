class AddRequestHeaderToApiRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :api_requests, :request_header, :string
  end
end
