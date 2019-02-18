# frozen_string_literal: true

class Overseers::AttachmentsController < Overseers::BaseController
  before_action :set_attachment, only: [:destroy]

  def destroy
    authorize :attachment

    blob = @attachment.blob
    if @attachment.destroy
      blob.purge
      redirect_back fallback_location: overseers_dashboard_path
    end
  end

  private

    def set_attachment
      @attachment = ActiveStorage::Attachment.find(params[:id])
    end
end
