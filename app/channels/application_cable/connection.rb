# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_overseer

    def connect
      # self.current_overseer = find_verified_overseer
    end

    protected

      def find_verified_overseer
        if current_overseer = env['warden'].user('overseer')
          current_overseer
        else
          reject_unauthorized_connection
        end
      end
  end
end
