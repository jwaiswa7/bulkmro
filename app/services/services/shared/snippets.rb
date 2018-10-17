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
    overseers = [
        ['cataloging', 'creative@bulkmro.com'],
        ['outside_sales_manager', 'jeetendra.sharma@bulkmro.com'],
        ['inside_sales', 'sarika.tanawade@bulkmro.com'],
        ['inside_sales_manager', 'swati.bhosale@bulkmro.com'],
        ['left', 'virendra.tiwari@bulkmro.com'],
        ['left', 'davinder.singh@bulkmro.com'],
        ['left', 'suvidha.shinde@bulkmro.com'],
        ['left', 'nisha.patil@bulkmro.com'],
        ['left', 'parveen.bano@bulkmro.com'],
        ['left', 'apeksha.khambe@bulkmro.com'],
        ['left', 'saqib.shaikh@bulkmro.com'],
        ['outside_sales', 'ketan.makwana@bulkmro.com'],
        ['outside_sales', 'rahul.dhanani@bulkmro.com'],
        ['left', 'tejasvi.bhosale@bulkmro.com'],
        ['left', 'mandakini.bhosale@bulkmro.com'],
        ['left', 'swapnil.bhogle@bulkmro.com'],
        ['outside_sales', 'pune.sales@bulkmro.com'],
        ['left', 'mp.felix@bulkmro.com'],
        ['left', 'sukriti.ranjan@bulkmro.com'],
        ['left', 'swati.gaikwad@bulkmro.com'],
        ['left', 'rutuja.yadav@bulkmro.com'],
        ['left', 'vrushali.lawangare@bulkmro.com'],
        ['inside_sales', 'jigar.joshi@bulkmro.com'],
        ['left', 'meenal.paradkar@bulkmro.com'],
        ['left', 'tenders@bulkmro.com'],
        ['left', 'paresh@dsnglobal.com'],
        ['left', 'pooja.egade@bulkmro.com'],
        ['left', 'mahendra.vaierkar@bulkmro.com'],
        ['left', 'sandeep.jannu@bulkmro.com'],
        ['outside_sales', 'lalit.dhingra@bulkmro.com'],
        ['inside_sales', 'neha.mundhe@bulkmro.com'],
        ['left', 'mohit.sardana@bulkmro.com'],
        ['left', 'madhuri.vaja@bulkmro.com'],
        ['left', 'ali.shaikh@bulkmro.com'],
        ['outside_sales', 'atul.thakur@bulkmro.com'],
        ['outside_sales', 'rajesh.sharma@bulkmro.com'],
        ['left', 'akbar.mukadam@bulkmro.com'],
        ['left', 'suresh.singh@bulkmro.com'],
        ['inside_sales', 'prit.patel@bulkmro.com'],
        ['inside_sales', 'supriya.govalkar@bulkmro.com'],
        ['left', 'swapnil.kadam@bulkmro.com'],
        ['left', 'nikhil.marathe@bulkmro.com'],
        ['outside_sales', 'gourav.shinde@bulkmro.com'],
        ['inside_sales', 'sajida.sayyed@bulkmro.com'],
        ['left', 'henisha.patel@bulkmro.com'],
        ['inside_sales', 'avni.shah@bulkmro.com'],
        ['inside_sales', 'dipali.ghanvat@bulkmro.com'],
        ['inside_sales', 'sheeba.shaikh@bulkmro.com'],
        ['inside_sales_manager', 'piyush.yadav@bulkmro.com'],
        ['sales', 'sales@bulkmro.com'],
        ['outside_sales', 'parth.patel@bulkmro.com'],
        ['outside_sales', 'parvez.shaikh@bulkmro.com'],
        ['outside_sales_head', 'ved.prakash@bulkmro.com'],
        ['outside_sales_manager', 'madan.sharma@bulkmro.com'],
        ['left', 'irshad.ahmed@bulkmro.com'],
        ['left', 'khan.noor@bulkmro.com'],
        ['left', 'hitesh.kumar@bulkmro.com'],
        ['left', 'rupesh.desai@bulkmro.com'],
        ['outside_sales', 'vivek.syal@bulkmro.com'],
        ['left', 'shakti.sharan@bulkmro.com'],
        ['left', 'gurjeet.singh@bulkmro.com'],
        ['left', 'atul.bhartiya@bulkmro.com'],
        ['outside_sales', 'harkesh.singh@bulkmro.com'],
        ['left', 'ajay.dave@bulkmro.com'],
        ['inside_sales', 'komal.nagar@bulkmro.com'],
        ['left', 'triveni.gawand@bulkmro.com'],
        ['inside_sales', 'rajani.kyatham@bulkmro.com'],
        ['left', 'rehana.mulani@bulkmro.com'],
        ['left', 'asif.rajwadkar@bulkmro.com'],
        ['left', 'vinayak.deshpande@bulkmro.com'],
        ['left', 'sachin.thakur@bulkmro.com'],
        ['inside_sales', 'sandeep.pal@bulkmro.com'],
        ['inside_sales', 'rahul.sonawane@bulkmro.com'],
        ['inside_sales', 'kartik.pai@bulkmro.com'],
        ['inside_sales_manager', 'puja.pawar@bulkmro.com'],
        ['outside_sales', 'nitish.srivastav@bulkmro.com'],
        ['inside_sales', 'dhrumil.patel@bulkmro.com'],
        ['outside_sales', 'mohammed.mujeebuddin@bulkmro.com'],
        ['inside_sales', 'pravin.shinde@bulkmro.com'],
        ['outside_sales', 'vishwajeet.chavan@bulkmro.com'],
        ['left', 'ranjit.kumar@bulkmro.com'],
        ['inside_sales_manager', 'aditya.andankar@bulkmro.com'],
        ['inside_sales', 'husna.khan@bulkmro.com'],
        ['inside_sales', 'srinivas.joshi@bulkmro.com'],
        ['inside_sales', 'mayur.salunke@bulkmro.com'],
        ['left', 'sunil.shetty@bulkmro.com'],
        ['inside_sales', 'mithun.trisule@bulkmro.com'],
        ['outside_sales', 'jignesh.shah@bulkmro.com'],
        ['outside_sales', 'vijay.narayan@bulkmro.com'],
        ['left', 'vinit.nadkarni@bulkmro.com'],
        ['inside_sales_manager', 'poonam.mohite@bulkmro.com'],
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
        ['inside_sales', 'priyank.dosani@bulkmro.com'],
        ['inside_sales', 'suhas.nair@bulkmro.com'],
        ['inside_sales', 'jigar.patel@bulkmro.com'],
        ['inside_sales', 'harsh.patel@bulkmro.com'],
        ['inside_sales', 'neel.patel@bulkmro.com'],
        ['outside_sales', 'ashish.dobariya@bulkmro.com'],
        ['left', 'mukund.sahay@bulkmro.com'],
        ['sales', 'farhan.ansari@bulkmro.com'],
        ['outside_sales', 'ankit.shah@bulkmro.com'],
        ['outside_sales', 'indore.sales@bulkmro.com'],
        ['sales', 'vijay.manjrekar@bulkmro.com'],
        ['sales', 'accounts@bulkmro.com'],
        ['sales', 'bhargav.trivedi@dsnglobal.com'],
        ['sales', 'akash.agarwal@bulkmro.com'],
        ['left', 'antim.patni@bulkmro.com'],
        ['sales', 'nitin.nabera@bulkmro.com'],
        ['sales', 'pravin.ganekar@bulkmro.com'],
        ['sales_manager', 'lavanya.j@bulkmro.com'],
        ['left', 'samidha.dhongade@bulkmro.com'],
        ['sales', 'nida.khan@bulkmro.com'],
        ['sales', 'uday.salvi@bulkmro.com'],
        ['left', 'prashant.ramtekkar@bulkmro.com'],
        ['left', 'ithelpdesk@bulkmro.com'],
        ['procurement', 'kevin.kunnassery@bulkmro.com'],
        ['sales', 'hr@bulkmro.com'],
        ['procurement', 'subrata.baruah@bulkmro.com'],
        ['sales', 'asad.shaikh@bulkmro.com'],
        ['outside_sales', 'vignesh.g@bulkmro.com'],
        ['outside_sales', 'shahid.shaikh@bulkmro.com'],
        ['outside_sales', 'rahul.dwivedi@bulkmro.com'],
        ['outside_sales', 'syed.tajudin@bulkmro.com'],
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
        ['outside_sales', 'sandeep.saini@bulkmro.com'],
        ['sales', 'ashish.agarwal@bulkmro.com'],
        ['sales', 'gitesh.ganekar@bulkmro.com'],
        ['outside_sales', 'chirag.arora@bulkmro.com'],
        ['admin', 'amit.goyal@bulkmro.com'],
        ['procurement', 'priyanka.rajpurkar@bulkmro.com'],
        ['inside_sales', 'yash.gajjar@bulkmro.com'],
        ['outside_sales', 'vinayak.degwekar@bulkmro.com'],
        ['outside_sales', 'shishir.jain@bulkmro.com'],
        ['sales', 'sumit.sharma@bulkmro.com'],
        ['inside_sales', 'mitesh.mandaliya@bulkmro.com'],
        ['inside_sales', 'anand.negi@bulkmro.com'],
        ['left', 'shailendra.trivedi@bulkmro.com'],
        ['outside_sales_head', 'shailender.agarwal@bulkmro.com'],
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
    ].each do |overseer|
      Overseer.find_by_email!(overseer[1]).update_attributes(:role => overseer[0])
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