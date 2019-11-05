class Services::Shared::Migrations::RemoveAclResources < Services::Shared::BaseService
  def remove_acl_access
    @export_ids = ["987", "1005", "1006", "1015", "1037", "1051", "1148", "1149", "1150", "1152", "1153", "1154", "1156", "1232", "1233", "1235", "1263", "1272", "1282", "1295", "1296", "1297", "1298", "1299", "1326", "1327", "1328", "1350", "1351", "1448", "1451", "1530", "1549"]
    @overseer_email = ["ved.prakash@bulkmro.com", "ankur.gupta@bulkmro.com", "subrata.baruah@bulkmro.com", "lavanya.j@bulkmro.com", "shailender.agarwal@bulkmro.com", "priyanka.rajpurkar@bulkmro.com"]
    @overseer_email.each do |user_email|
      overseer = Overseer.find_by_email(user_email)
      if overseer.present?
        overseer_resources = JSON.parse(overseer.acl_resources)
        @export_ids.each do |export_id|
          if overseer_resources.include?(export_id)
            overseer_resources.delete(export_id)
          end
        end

        new_acl_resources = overseer_resources.to_s
        overseer.acl_resources = new_acl_resources
        overseer.save!
      end
    end
  end
end