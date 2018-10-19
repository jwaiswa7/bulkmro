class Services::Shared::Snippets < Services::Shared::BaseService

  def delete_all_inquiries
    SalesOrderRow.delete_all
    SalesOrderApproval.all.delete_all
    SalesOrderConfirmation.delete_all
    SalesOrderRejection.delete_all
    SalesOrderApproval.delete_all
    SalesOrder.delete_all
    SalesQuoteRow.delete_all
    SalesQuote.delete_all
    InquiryProductSupplier.delete_all
    InquiryImportRow.delete_all
    InquiryImport.delete_all
    InquiryProduct.delete_all
    ActivityOverseer.delete_all
    Activity.delete_all
    InquiryComment.delete_all
    Inquiry.delete_all
  end

  def check_es
    service = Services::Overseers::Finders::Products.new({})
    service.manage_failed_skus('Painting Spray Gun Type - 68, Cap - 140 M', 4, 1)
  end

  def copy_inquiry_number_into_project_uid
    Inquiry.where.not(:opportunity_uid => nil).each do |inquiry| inquiry.update_attributes(:project_uid => inquiry.inquiry_number) if inquiry.inquiry_number.present? && inquiry.project_uid.blank?; end
  end

  def delete_inquiry_products
    SalesQuoteRow.delete_all
    SalesQuote.delete_all
    InquiryProductSupplier.delete_all
    InquiryProduct.delete_all
  end

  def run_inquiry_details_migration
    PaperTrail.request(enabled: false) do
      Services::Shared::Migrations::Migrations.new(['activities']).call
    end
  end

  def set_roles
    [
        ['cataloging', 'creative@bulkmro.com'],
        ['outside_sales_team_leader', 'jeetendra.sharma@bulkmro.com'],
        ['inside_sales_executive', 'sarika.tanawade@bulkmro.com'],
        ['outside_sales_team_leader', 'swati.bhosale@bulkmro.com'],
        ['left', 'virendra.tiwari@bulkmro.com'],
        ['left', 'davinder.singh@bulkmro.com'],
        ['left', 'suvidha.shinde@bulkmro.com'],
        ['left', 'nisha.patil@bulkmro.com'],
        ['left', 'parveen.bano@bulkmro.com'],
        ['left', 'apeksha.khambe@bulkmro.com'],
        ['left', 'saqib.shaikh@bulkmro.com'],
        ['outside_sales_executive', 'ketan.makwana@bulkmro.com'],
        ['outside_sales_executive', 'rahul.dhanani@bulkmro.com'],
        ['left', 'tejasvi.bhosale@bulkmro.com'],
        ['left', 'mandakini.bhosale@bulkmro.com'],
        ['left', 'swapnil.bhogle@bulkmro.com'],
        ['outside_sales_executive', 'pune.sales@bulkmro.com'],
        ['left', 'mp.felix@bulkmro.com'],
        ['left', 'sukriti.ranjan@bulkmro.com'],
        ['left', 'swati.gaikwad@bulkmro.com'],
        ['left', 'rutuja.yadav@bulkmro.com'],
        ['left', 'vrushali.lawangare@bulkmro.com'],
        ['inside_sales_executive', 'jigar.joshi@bulkmro.com'],
        ['left', 'meenal.paradkar@bulkmro.com'],
        ['left', 'tenders@bulkmro.com'],
        ['left', 'paresh@dsnglobal.com'],
        ['left', 'pooja.egade@bulkmro.com'],
        ['left', 'mahendra.vaierkar@bulkmro.com'],
        ['left', 'sandeep.jannu@bulkmro.com'],
        ['outside_sales_executive', 'lalit.dhingra@bulkmro.com'],
        ['inside_sales_executive', 'neha.mundhe@bulkmro.com'],
        ['left', 'mohit.sardana@bulkmro.com'],
        ['left', 'madhuri.vaja@bulkmro.com'],
        ['left', 'ali.shaikh@bulkmro.com'],
        ['outside_sales_executive', 'atul.thakur@bulkmro.com'],
        ['outside_sales_executive', 'rajesh.sharma@bulkmro.com'],
        ['left', 'akbar.mukadam@bulkmro.com'],
        ['left', 'suresh.singh@bulkmro.com'],
        ['inside_sales_executive', 'prit.patel@bulkmro.com'],
        ['inside_sales_executive', 'supriya.govalkar@bulkmro.com'],
        ['left', 'swapnil.kadam@bulkmro.com'],
        ['left', 'nikhil.marathe@bulkmro.com'],
        ['outside_sales_executive', 'gourav.shinde@bulkmro.com'],
        ['inside_sales_executive', 'sajida.sayyed@bulkmro.com'],
        ['left', 'henisha.patel@bulkmro.com'],
        ['inside_sales_executive', 'avni.shah@bulkmro.com'],
        ['inside_sales_executive', 'dipali.ghanvat@bulkmro.com'],
        ['inside_sales_executive', 'sheeba.shaikh@bulkmro.com'],
        ['outside_sales_team_leader', 'piyush.yadav@bulkmro.com'],
        ['sales', 'sales@bulkmro.com'],
        ['outside_sales_executive', 'parth.patel@bulkmro.com'],
        ['outside_sales_executive', 'parvez.shaikh@bulkmro.com'],
        ['outside_sales_manager', 'ved.prakash@bulkmro.com'],
        ['outside_sales_team_leader', 'madan.sharma@bulkmro.com'],
        ['left', 'irshad.ahmed@bulkmro.com'],
        ['left', 'khan.noor@bulkmro.com'],
        ['left', 'hitesh.kumar@bulkmro.com'],
        ['left', 'rupesh.desai@bulkmro.com'],
        ['outside_sales_executive', 'vivek.syal@bulkmro.com'],
        ['left', 'shakti.sharan@bulkmro.com'],
        ['left', 'gurjeet.singh@bulkmro.com'],
        ['left', 'atul.bhartiya@bulkmro.com'],
        ['outside_sales_executive', 'harkesh.singh@bulkmro.com'],
        ['left', 'ajay.dave@bulkmro.com'],
        ['inside_sales_executive', 'komal.nagar@bulkmro.com'],
        ['left', 'triveni.gawand@bulkmro.com'],
        ['inside_sales_executive', 'rajani.kyatham@bulkmro.com'],
        ['left', 'rehana.mulani@bulkmro.com'],
        ['left', 'asif.rajwadkar@bulkmro.com'],
        ['left', 'vinayak.deshpande@bulkmro.com'],
        ['left', 'sachin.thakur@bulkmro.com'],
        ['inside_sales_executive', 'sandeep.pal@bulkmro.com'],
        ['inside_sales_executive', 'rahul.sonawane@bulkmro.com'],
        ['inside_sales_executive', 'kartik.pai@bulkmro.com'],
        ['outside_sales_team_leader', 'puja.pawar@bulkmro.com'],
        ['outside_sales_executive', 'nitish.srivastav@bulkmro.com'],
        ['inside_sales_executive', 'dhrumil.patel@bulkmro.com'],
        ['outside_sales_executive', 'mohammed.mujeebuddin@bulkmro.com'],
        ['inside_sales_executive', 'pravin.shinde@bulkmro.com'],
        ['outside_sales_executive', 'vishwajeet.chavan@bulkmro.com'],
        ['left', 'ranjit.kumar@bulkmro.com'],
        ['outside_sales_team_leader', 'aditya.andankar@bulkmro.com'],
        ['inside_sales_executive', 'husna.khan@bulkmro.com'],
        ['inside_sales_executive', 'srinivas.joshi@bulkmro.com'],
        ['inside_sales_executive', 'mayur.salunke@bulkmro.com'],
        ['left', 'sunil.shetty@bulkmro.com'],
        ['inside_sales_executive', 'mithun.trisule@bulkmro.com'],
        ['outside_sales_executive', 'jignesh.shah@bulkmro.com'],
        ['outside_sales_executive', 'vijay.narayan@bulkmro.com'],
        ['left', 'vinit.nadkarni@bulkmro.com'],
        ['outside_sales_team_leader', 'poonam.mohite@bulkmro.com'],
        ['left', 'sales.support@bulkmro.com'],
        ['left', 'logistics@bulkmro.com'],
        ['sales', 'diksha.tambe@bulkmro.com'],
        ['left', 'chiragl@bulkmro.com'],
        ['left', 'chirag.gohil@bulkmro.com'],
        ['left', 'ujalsandip@gmail.com'],
        ['left', 'Mamta.Shivaratri@bulkmro.com'],
        ['left', 'manish.singh@bulkmro.com'],
        ['sales', 'ovais.ansari@bulkmro.com'],
        ['sales', 'avinash.pillai@bulkmro.com'],
        ['left', 'kaushik.bangalorkar@bulkmro.com'],
        ['left', 'kaushik.banglorkar@bulkmro.com'],
        ['sales', 'ganesh.khade@bulkmro.com'],
        ['sales', 'ajay.rathod@bulkmro.com'],
        ['sales', 'prasad.hinge@bulkmro.com'],
        ['left', 'abid.shaikh@bulkmro.com'],
        ['sales', 'manoj.dakua@bulkmro.com'],
        ['inside_sales_executive', 'priyank.dosani@bulkmro.com'],
        ['inside_sales_executive', 'suhas.nair@bulkmro.com'],
        ['inside_sales_executive', 'jigar.patel@bulkmro.com'],
        ['inside_sales_executive', 'harsh.patel@bulkmro.com'],
        ['inside_sales_executive', 'neel.patel@bulkmro.com'],
        ['outside_sales_executive', 'ashish.dobariya@bulkmro.com'],
        ['left', 'mukund.sahay@bulkmro.com'],
        ['sales', 'farhan.ansari@bulkmro.com'],
        ['outside_sales_executive', 'ankit.shah@bulkmro.com'],
        ['outside_sales_executive', 'indore.sales@bulkmro.com'],
        ['sales', 'vijay.manjrekar@bulkmro.com'],
        ['sales', 'accounts@bulkmro.com'],
        ['sales', 'bhargav.trivedi@dsnglobal.com'],
        ['sales', 'akash.agarwal@bulkmro.com'],
        ['left', 'antim.patni@bulkmro.com'],
        ['sales', 'nitin.nabera@bulkmro.com'],
        ['sales', 'pravin.ganekar@bulkmro.com'],
        ['inside_sales_manager', 'lavanya.j@bulkmro.com'],
        ['left', 'samidha.dhongade@bulkmro.com'],
        ['sales', 'nida.khan@bulkmro.com'],
        ['sales', 'uday.salvi@bulkmro.com'],
        ['left', 'prashant.ramtekkar@bulkmro.com'],
        ['left', 'ithelpdesk@bulkmro.com'],
        ['procurement', 'kevin.kunnassery@bulkmro.com'],
        ['sales', 'hr@bulkmro.com'],
        ['procurement', 'subrata.baruah@bulkmro.com'],
        ['sales', 'asad.shaikh@bulkmro.com'],
        ['outside_sales_executive', 'vignesh.g@bulkmro.com'],
        ['outside_sales_executive', 'shahid.shaikh@bulkmro.com'],
        ['outside_sales_executive', 'rahul.dwivedi@bulkmro.com'],
        ['outside_sales_executive', 'syed.tajudin@bulkmro.com'],
        ['sales', 'dinesh.kumar1@bulkmro.com'],
        ['sales', 'dinesh.kumar@bulkmro.com'],
        ['cataloging', 'puja.tanawade@bulkmro.com'],
        ['cataloging', 'chetan.utekar@bulkmro.com'],
        ['sales', 'content@bulkmro.com'],
        ['admin', 'gaurang.shah@bulkmro.com'],
        ['left', 'abhishek.shingane@bulkmro.com'],
        ['sales', 'sumit.kumar@bulkmro.com'],
        ['left', 'sheetal.shinde@bulkmro.com'],
        ['sales', 'bhargav.trivedi@bulkmro.com'],
        ['admin', 'devang.shah@bulkmro.com'],
        ['sales', 'pradeep.ketkale@bulkmro.com'],
        ['left', 'ankit.upadhyay@bulkmro.com'],
        ['left', 'ravi.ranjan@bulkmro.com'],
        ['sales', 'dhaval.shah@bulkmro.com'],
        ['left', 'chaitanya.varma@bulkmro.com'],
        ['sales', 'store@bulkmro.com'],
        ['left', 'sarwar.rizvi@bulkmro.com'],
        ['sales', 'praxis@bulkmro.com'],
        ['sales', 'akshay.jindal@bulkmro.com'],
        ['sales', 'rahul.pandey@bulkmro.com'],
        ['sales', 'gaurav.sajjanhar@bulkmro.com'],
        ['sales', 'sanchit.sharma@bulkmro.com'],
        ['sales', 'hemal.lathia@bulkmro.com'],
        ['sales', 'nilesh.desai@bulkmro.com'],
        ['sales', 'vignesh.gounder@bulkmro.com'],
        ['sales', 'sandesh.raut@bulkmro.com'],
        ['admin', 'ashwin.goyal@bulkmro.com'],
        ['sales', 'ankur.gupta@bulkmro.com'],
        ['admin', 'prikesh.savla@bulkmro.com'],
        ['sales', 'paresh.suvarna@bulkmro.com'],
        ['outside_sales_executive', 'sandeep.saini@bulkmro.com'],
        ['sales', 'ashish.agarwal@bulkmro.com'],
        ['sales', 'gitesh.ganekar@bulkmro.com'],
        ['outside_sales_executive', 'chirag.arora@bulkmro.com'],
        ['admin', 'amit.goyal@bulkmro.com'],
        ['procurement', 'priyanka.rajpurkar@bulkmro.com'],
        ['inside_sales_executive', 'yash.gajjar@bulkmro.com'],
        ['outside_sales_executive', 'vinayak.degwekar@bulkmro.com'],
        ['outside_sales_executive', 'shishir.jain@bulkmro.com'],
        ['sales', 'sumit.sharma@bulkmro.com'],
        ['inside_sales_executive', 'mitesh.mandaliya@bulkmro.com'],
        ['inside_sales_executive', 'anand.negi@bulkmro.com'],
        ['left', 'shailendra.trivedi@bulkmro.com'],
        ['outside_sales_manager', 'shailender.agarwal@bulkmro.com'],
        ['admin', 'malav.desai@bulkmro.com'],
        ['admin', 'shravan.agarwal@bulkmro.com'],
        ['sales', 'oindrilla.paul@bulkmro.com'],
        ['sales', 'trunal.shah@bulkmro.com'],
        ['procurement', 'seller@bulkmro.com'],
        ['sales', 'marketing@bulkmro.com'],
        ['left', 'pooja.tirwadkar@bulkmro.com'],
        ['left', 'abhishek.dolle@bulkmro.com'],
        ['sales', 'sysadmin+test-api-user@bulkmro.com'],
        ['sales', 'sysadmin@bulkmro.com'],
        ['left', 'rajani.ong@bulkmro.com'],
    ].each do |kv|
      overseer = Overseer.find_by_email(kv[1])
      overseer.update_attributes(:role => kv[0].to_sym) if overseer.present?
    end
  end

  def approve_products
    PaperTrail.request(enabled: false) do
      Product.all.not_approved.each do |product|
        product.create_approval(:comment => product.comments.create!(:overseer => Overseer.default, message: 'Legacy product, being preapproved'), :overseer => Overseer.default) if product.approval.blank?
      end
    end
  end

  def add_column_dirty
    ActiveRecord::Base.connection.execute('ALTER TABLE products ADD COLUMN weight DECIMAL')
  end

  def change_column_type_db
    ActiveRecord::Base.connection.execute('ALTER TABLE inquiries ALTER COLUMN inquiry_number TYPE BIGINT USING inquiry_number::bigint')
  end

  def fix_product_brands
    PaperTrail.request(enabled: false) do
      service = Services::Shared::Spreadsheets::CsvImporter.new('products.csv')
      service.loop(nil) do |x|
        next if x.get_column('entity_id').to_i < 677812
        brand = Brand.where("legacy_metadata->>'option_id' = ?", x.get_column('product_brand')).first
        product = Product.find_by_legacy_id(x.get_column('entity_id'))
        product.update_attributes(:brand => brand) if product.present?
      end
    end
  end


  def activities_migration_fix
    Activity.where(:created_by => nil).each do |activity|
      activity_overseer = activity.activity_overseers.first

      ActiveRecord::Base.transaction do
        activity.update_attributes!(:overseer => activity_overseer.overseer)
        activity_overseer.destroy!
      end if activity_overseer.present?
    end
  end

  def activities_migration_fix_2
    service = Services::Shared::Spreadsheets::CsvImporter.new('activity_reports.csv')
    service.loop(nil) do |x|
      overseer_legacy_id = x.get_column('overseer_legacy_id')
      overseer = Overseer.find_by_legacy_id(overseer_legacy_id)
      activity = Activity.where(legacy_id: x.get_column('legacy_id')).first
      activity.update_attributes(:created_by => overseer, :updated_by => overseer) if activity.present?
    end
  end

  def product_brands_fix
    service = Services::Shared::Spreadsheets::CsvImporter.new('products.csv')
    service.loop(nil) do |x|
      brand = Brand.where("legacy_metadata->>'option_id' = ?", x.get_column('product_brand')).first
      product = Product.find_by_legacy_id(x.get_column('entity_id'))
      product.update_attributes(:brand => brand)
    end
  end

end