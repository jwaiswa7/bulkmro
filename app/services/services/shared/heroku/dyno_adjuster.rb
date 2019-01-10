require 'platform-api'

class Services::Shared::Heroku::DynoAdjuster < Services::Shared::BaseService
  def initialize
    @client = PlatformAPI.connect_oauth(Settings.heroku.dyno_adjuster_token)
    @app_name = 'bulkmro'

    processes = client.formation.list(app_name)
    process = processes.select {|process| process['type'] == 'web'}[0]

    if Time.now.wday.in?(1..5) && '9:45 AM'.to_time < Time.now && Time.now < '7:30 PM'.to_time
      scale(process, 'Performance-M', 2)
    elsif Time.now.wday == 6 && '9:00 AM'.to_time < Time.now && Time.now < '4:30 PM'.to_time
      scale(process, 'Performance-M', 2)
    else
      scale(process, '2X', 1)
    end
  end

  def scale(process, size, quantity)
    if process['size'] == size && process['quantity'] == quantity
      puts "Process #{process['type']} is already #{size} sized."
    else
      client.formation.batch_update(app_name, {
          :updates => [
              {
                  :process => process['type'],
                  :quantity => quantity,
                  :size => size
              }
          ]}
      )
    end
  end

  attr_accessor :client, :app_name
end