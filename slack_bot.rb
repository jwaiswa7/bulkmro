# frozen_string_literal: true

require_relative './config/boot'
require_relative './config/environment'
include DisplayHelper

Services::Slack::Sita.run
