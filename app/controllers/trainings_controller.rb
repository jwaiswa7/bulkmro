class TrainingsController < ApplicationController
    layout 'trainings/layouts/application'

    before_action :get_trainings 
    before_action :get_training, only: :show

    def index 
    end

    def show 
    end

    def get_trainings 
        @trainings = YAML.load_file(Rails.root.join("config/trainings.yml"))
    end

    def get_training
        @training = @trainings.select {|training| training['slug'] == params[:id]}.first
    end
end