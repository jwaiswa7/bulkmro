class Overseers::DownloadPolicy < Overseers::ApplicationPolicy

    def allowed?
      return false if ["superhuman@bulkmro.com"].include? overseer.email
      true
    end
end 