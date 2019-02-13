

require "google/apis/compute_v1"
require "googleauth"

class Services::Shared::Gcloud::RunBackups < Services::Shared::BaseService
  def initialize(send_chat_message: true)
    @client = client = Google::Apis::ComputeV1::ComputeService.new
    @project = project = "bmsap-212015"
    @send_chat_message = send_chat_message
    scopes = %w(https://www.googleapis.com/auth/cloud-platform https://www.googleapis.com/auth/compute)
    authorizer = Google::Auth::ServiceAccountCredentials.make_creds(json_key_io: File.open(Rails.root.join("app", "services", "services", "shared", "gcloud", "bmsap-212015-e2b660dbd377.json")), scope: scopes)
    authorizer.fetch_access_token!
    client.authorization = authorizer

    client.list_snapshots(project)
  end

  def call
    run
  end

  def snapshot_exists?(name)
    begin
      client.get_snapshot(project, name)
    rescue Google::Apis::ClientError => e
      puts e
      false
    end
  end

  def backup_linux
    backup_name = ["linux", Date.today.to_s.parameterize].join("-")
    vm_name = "instance-1"
    zone = "asia-south1-c"
    snapshot = Google::Apis::ComputeV1::Snapshot.new
    snapshot.name = backup_name

    if snapshot_exists?(backup_name)
      "A backup named #{backup_name} already exists."
    else
      client.create_disk_snapshot(project, zone, vm_name, snapshot)
      "A new automatic backup #{backup_name} has been initialized."
    end
  end

  def backup_windows
    backup_name = ["windows", Date.today.to_s.parameterize].join("-")
    vm_name = "bm-prd-sap-windows-2"
    zone = "asia-south1-b"
    snapshot = Google::Apis::ComputeV1::Snapshot.new
    snapshot.name = backup_name

    if snapshot_exists?(backup_name)
      "A backup named #{backup_name} already exists."
    else
      client.create_disk_snapshot(project, zone, vm_name, snapshot)
      "A new automatic backup #{backup_name} has been initialized."
    end
  end

  def run
    if send_chat_message
      Services::Overseers::ChatMessages::SendChat.new.send_chat_message(
        "tech-backups",
          [
              backup_linux,
              backup_windows
          ].join("\n")
      )
    else
      backup_linux
      backup_windows
    end
  end

  attr_accessor :client, :project, :windows_backup_name, :linux_backup_name, :windows_vm_name, :linux_vm_name, :send_chat_message
end
