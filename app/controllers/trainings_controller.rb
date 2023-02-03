class TrainingsController < ApplicationController
  layout 'trainings/layouts/application'
  
  before_action :authenticate_overseer!
  before_action :get_trainings
  before_action :get_training, only: :show

  def index
  end

  def show
  end

  private

  def get_trainings
    @trainings = YAML.load_file(Rails.root.join('config/trainings.yml'))
    @categories = ["Catalog","Sales","Logistics","Reports","Customer Portal","Miscellaneous"]
    @training_ordered = Hash.new
    @categories.each do | category|
      @training_ordered[category] = @trainings.select {|training| training['category'] == category }
    end
  end

  def get_training
    @training = @trainings.select {|training| training['slug'] == params[:id]}.first
  end
  
end
