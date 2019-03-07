class Services::Shared::Snippets < Services::Shared::BaseService
  def supplier_data_summary
    Account.is_supplier.size
    Company.acts_as_supplier.size
    ids = PurchaseOrder.all.map {|po| po.metadata['PoSupNum']}.compact.uniq
    ids.size
    nov_ids = Company.acts_as_supplier.where(created_at: Time.new(2018, 11, 1).beginning_of_month..Time.new(2018, 11, 1).end_of_month).pluck(:remote_uid)
    (ids & nov_ids).size
# # Accounts as suppliers
#     7
#
# # Total suppliers
#     6108
#
# # Total suppliers with purchase orders
#     2053
#
# # Suppliers added in November
#     214
#
# # Suppliers added in November with purchase orders
#     105
  end

  def paper_trail_find
    who = Product.find_by_sku('BM9R3F1').versions.last.whodunnit
    GlobalID::Locator.locate(who)
  end

  def delete_products_without_images
    Account.find('wBgfoW').companies.each do |c|
      c.customer_products.each do |cp|
        if cp.best_images.blank?
          cp.destroy
        end
      end
    end
  end

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

  def del_customer_orders
    CustomerOrderApproval.all.destroy_all
    CustomerOrder.all.destroy_all
  end

  def check_company
    company = Company.find_by_name('Flextronics Technologies India Pvt. Ltd.')

    company.sales_quotes.first

    SalesQuotesIndex::SalesQuote.import SalesQuote.all, update_fields: [:is_final]
  end

  def update_amat_statuses
    invoices = Contact.find_by_email('bhupali_pawar@contractor.amat.com').account.invoices

    invoices.all.each do |i|
      i.update_attributes(status: :Unpaid)
    end


    statuses = [
        ['0201/16.17', 'Paid'],
        ['0143/16.17', 'Paid'],
        ['0221/16.17', 'Paid'],
        ['0313/16.17', 'Paid'],
        ['Takeover', 'Paid'],
        ['200024', 'Paid'],
        ['200126', 'Paid'],
        ['200126-A', 'Paid'],
        ['201208', 'Paid'],
        ['300269', 'Paid'],
        ['300285', 'Paid'],
        ['300292', 'Paid'],
        ['300302', 'Paid'],
        ['300319', 'Paid'],
        ['300342', 'Paid'],
        ['300343', 'Paid'],
        ['300345', 'Paid'],
        ['300362', 'Paid'],
        ['300363', 'Paid'],
        ['300364', 'Paid'],
        ['3000275', 'Paid'],
        ['3000687', 'Paid'],
        ['3000717', 'Paid'],
        ['20200049', 'Paid'],
        ['20200064', 'Paid'],
        ['20200074', 'Paid'],
        ['20200084', 'Paid'],
        ['20200100', 'Paid'],
        ['20200108', 'Paid'],
        ['20200109', 'Paid'],
        ['20200120', 'Paid'],
        ['20210030', 'Paid'],
        ['20210066', 'Paid'],
        ['20210080', 'Paid'],
        ['20210081', 'Paid'],
        ['20210100', 'Paid'],
        ['20210126', 'Paid'],
        ['20210143', 'Paid'],
        ['20210145', 'Paid'],
        ['20210146', 'Paid'],
        ['20210147', 'Paid'],
        ['20210160', 'Paid'],
        ['20210177', 'Paid'],
        ['20210183', 'Paid'],
        ['20210186', 'Paid'],
        ['20210201', 'Paid'],
        ['20210215', 'Paid'],
        ['20210224', 'Paid'],
        ['20210225', 'Paid'],
        ['20210236', 'Paid'],
        ['20210237', 'Paid'],
        ['20210240', 'Paid'],
        ['20210245', 'Unpaid'],
        ['20210261', 'Paid'],
        ['20210303', 'Paid'],
        ['20210304', 'Paid'],
        ['20210319', 'Unpaid'],
        ['20210325', 'Paid'],
        ['20210326', 'Paid'],
        ['20210344', 'Paid'],
        ['20210350', 'Paid'],
        ['20210355', 'Paid'],
        ['20210356', 'Paid'],
        ['20210348', 'Paid'],
        ['20210391', 'Paid'],
        ['20210408', 'Paid'],
        ['20210428', 'Paid'],
        ['20210429', 'Paid'],
        ['20210430', 'Paid'],
        ['20210441', 'Paid'],
        ['20210462', 'Paid'],
        ['20210476', 'Paid'],
        ['20210493', 'Paid'],
        ['20210496', 'Paid'],
        ['20210500', 'Paid'],
        ['20210497', 'Paid'],
        ['20210498', 'Paid'],
        ['20210506', 'Paid'],
        ['20210536', 'Paid'],
        ['20210567', 'Paid'],
        ['20210584', 'Paid'],
        ['20210585', 'Paid'],
        ['20210597', 'Paid'],
        ['20210609', 'Paid'],
        ['20210614', 'Paid'],
        ['20210625', 'Paid'],
        ['20210626', 'Paid'],
        ['20210637', 'Paid'],
        ['20210639', 'Paid'],
        ['20210642', 'Paid'],
        ['20210651', 'Paid'],
        ['20210652', 'Paid'],
        ['20210673', 'Paid'],
        ['20210689', 'Paid'],
        ['20210688', 'Unpaid'],
        ['20210687', 'Paid'],
        ['20210690', 'Paid'],
        ['20210696', 'Paid'],
        ['20210701', 'Paid'],
        ['20210719', 'Paid'],
        ['20210731', 'Paid'],
        ['20210740', 'Paid'],
        ['20210744', 'Paid'],
        ['20210745', 'Paid'],
        ['20210751', 'Paid'],
        ['20210768', 'Paid'],
        ['20210770', 'Unpaid'],
        ['20210785', 'Paid'],
        ['20210789', 'Unpaid'],
        ['20210791', 'Paid'],
        ['20210801', 'Paid'],
        ['20210821', 'Paid'],
        ['20210826', 'Paid'],
        ['20210827', 'Paid'],
        ['20210830', 'Paid'],
        ['20210843', 'Paid'],
        ['20210855', 'Paid'],
        ['20210866', 'Paid'],
        ['20210871', 'Paid'],
        ['20210872', 'Paid'],
        ['20210874', 'Unpaid'],
        ['20210881', 'Paid'],
        ['20210891', 'Paid'],
        ['20210897', 'Unpaid'],
        ['20210898', 'Unpaid'],
        ['20210901', 'Paid'],
        ['20210906', 'Paid'],
        ['20210928', 'Paid'],
        ['20210929', 'Unpaid'],
        ['20210939', 'Paid'],
        ['20210940', 'Paid'],
        ['20210944', 'Paid'],
        ['20210952', 'Paid'],
        ['20210953', 'Paid'],
        ['20210978', 'Paid'],
        ['20210979', 'Paid'],
        ['20211025', 'Unpaid'],
        ['20211030', 'Unpaid'],
        ['20211084', 'Unpaid'],
        ['20211085', 'Unpaid'],
        ['20211099', 'Unpaid'],
        ['20211114', 'Unpaid'],
        ['20211117', 'Unpaid'],
        ['20211122', 'Unpaid'],
        ['20211125', 'Unpaid'],
        ['20211141', 'Unpaid'],
        ['20211150', 'Unpaid'],
        ['20211157', 'Unpaid'],
        ['20211158', 'Unpaid'],
        ['20211202', 'Unpaid'],
        ['20211247', 'Unpaid'],
        ['20211265', 'Unpaid'],
        ['20211271', 'Unpaid'],
        ['20211272', 'Unpaid'],
        ['20211273', 'Unpaid'],
        ['20211291', 'Unpaid'],
        ['20211298', 'Unpaid'],
        ['20211344', 'Unpaid'],
        ['20211345', 'Unpaid'],
    ]

    statuses.each do |status|
      invoice = invoices.find_by_invoice_number(status[0])
      invoice.update_attributes(status: status[1]) if invoice.present?
    end
  end

  def inquiry
    Inquiry.find_each(batch_size: 100) do |i|
      i.update_attributes(shipping_company: i.company) if i.shipping_company.blank?;
      i.update_attributes(shipping_contact: i.contact) if i.shipping_contact.blank?;
    end
  end

  def best_products
    inquiry_products = InquiryProduct.joins(:inquiry, :product).where('inquiries.company_id = ?', company.id)
    best_products = inquiry_products.top(:product_id, 5)
    best_product_ids = best_products.map {|best_product| best_product[0]}
    inquiry_products.where('products.id IN (?)', best_product_ids).select('inquiry_products.product_id, inquiry_products.bp_catalog_sku').distinct
  end

  def comments
    overseer = Overseer.find_by_first_name('Husna')
    Inquiry.find_by_inquiry_number('28597').comments.last.update_attributes(created_by: overseer, updated_by: overseer)
  end

  def tax_rate_migration
    TaxRate.where(tax_percentage: 0).first_or_create
    TaxRate.where(tax_percentage: 5).first_or_create
    TaxRate.where(tax_percentage: 12).first_or_create
    TaxRate.where(tax_percentage: 18).first_or_create
    TaxRate.where(tax_percentage: 28).first_or_create

    Category.all.each do |record|
      if record.tax_code.present? && record.tax_rate.blank?
        record.tax_rate = TaxRate.find_by_tax_percentage(record.tax_code.tax_percentage) || TaxRate.default
        record.save!
      end
    end

    Product.all.where(tax_rate_id: nil).where.not(tax_code_id: nil).each do |record|
      if record.tax_code.present? && record.tax_rate.blank?
        record.tax_rate = TaxRate.find_by_tax_percentage(record.tax_code.tax_percentage) || TaxRate.default
        record.save!
      end
    end

    SalesQuoteRow.where(tax_rate_id: nil).where.not(tax_code_id: nil).each do |record|
      if record.tax_code.present? && record.tax_rate.blank?
        record.tax_rate = TaxRate.find_by_tax_percentage(record.tax_code.tax_percentage) || TaxRate.default
        record.save!
      end
    end
  end

  def set_non_trade_accounts
    [
        ['SC-7894', 'InstaOffice Business Solutions Pvt. Ltd.'],
        ['SC-7952', 'Emtex Engineering Pvt. Ltd.'],
        ['SC-7954', 'Megan Impex Pvt. Ltd.'],
        ['SC-7960', 'TCI Express Limited'],
        ['SC-7964', 'Indigo Airlines'],
        ['SC-7969', 'VRL Logistics Ltd'],
        ['SC-7971', 'Attune Offitech'],
        ['SC-7972', 'Twenty First Century Techno Products Pvt Ltd (FA)'],
        ['SC-7975', 'Nagesh Enterprises'],
        ['SC-7976', 'Prakruti Projects Pvt. Ltd.'],
        ['SC-7978', 'Doshi & Shah'],
        ['SC-7979', 'Joule Consulting Pvt. Ltd.'],
        ['SC-7980', 'KDK Softwares India Pvt. Ltd.'],
        ['SC-7981', 'Membership Fee 18%'],
        ['SC-7982', 'Stone Wood Interior'],
        ['SC-7983', 'Vodafone Number 8291952385'],
        ['SC-7984', 'Advance-Vinod Shinde'],
        ['SC-8113', 'Shortlist Professional Services Pvt. Ltd.'],
        ['SC-8197', 'Expeditors International (India) Pvt. Ltd.'],
        ['SC-8198', 'Fedex Express Transportation And Supply Chain Services (India) Pvt. Ltd.'],
        ['SC-8199', 'Griffin Products Pvt. Ltd.'],
        ['SC-8200', 'Haqcom Software Pvt. Ltd.'],
        ['SC-8201', 'Innovative Engineers'],
        ['SC-8205', 'LTI - LumiTronic Industries B.V.'],
        ['SC-8207', 'Praxis Info Solutions Pvt. Ltd.'],
        ['SC-8208', 'R.K. Infosys'],
        ['SC-8212', 'Reliance Retail Ltd.'],
        ['SC-8215', 'Spine Technologies(I) Pvt. Ltd.'],
        ['SC-8218', 'Subodh Network'],
        ['SC-8219', 'TCI Express Ltd.'],
        ['SC-8220', 'The New India Assurance Company Ltd.'],
        ['SC-8222', 'United India Insurance Co. Ltd.'],
        ['SC-8223', 'V. A. Parikh & Co.'],
        ['SC-8384', 'Dell International Services India Pvt. Ltd.'],
        ['SC-8531', 'MothersonSumi Infotech & Designs Ltd.'],
        ['SC-8536', 'Piping World Projects'],
        ['SC-8540', 'Print Studio Planet'],
        ['SC-8541', 'Nandan Mukhiya - UrbanClap'],
        ['SC-8542', 'Parduman Enterprises'],
        ['SC-8549', 'Param Associates'],
        ['SC-8553', 'TCI House'],
        ['SC-8554', 'Environnement SA India Pvt. Ltd.'],
        ['SC-8557', 'Brainsearch Consulting Pvt. Ltd.'],
        ['SC-8925', 'Kishor Kamble'],
        ['SC-9288', 'Sure Resistors'],
    ].each do |company_array|
      Company.find_by_remote_uid(company_array[0]).update_attribute(:account_id, Account.non_trade.id)
    end
  end

  def set_is_customer_for_accounts
    Account.where.not(account_type: Account.account_types[:is_supplier]).update_all(account_type: :is_customer)
  end

  def update_password
    Overseer.find_by_email('neha.mundhe@bulkmro.com').update_attributes(password: 'abc123', password_confirmation: 'abc123')
  end

  def sync_unsynced_companies
    Company.where(created_at: 5.days.ago..Time.now).where(remote_uid: nil).where("pan IS NOT NULL AND pan != ''").each do |company|
      company.save_and_sync
    end

    company = Company.where(created_at: 5.days.ago..Time.now).where(remote_uid: nil).where("pan IS NOT NULL AND pan != ''").first
  end

  def make_admin
    Overseer.find_by_email('puja.tanawade@bulkmro.com').admin!
    Overseer.find_by_email('chetan.utekar@bulkmro.com').admin!
  end

  def check_es
    service = Services::Overseers::Finders::Products.new({})
    service.manage_failed_skus('Painting Spray Gun Type - 68, Cap - 140 M', 4, 1)
  end

  def copy_inquiry_number_into_project_uid
    Inquiry.where.not(opportunity_uid: nil).each do |inquiry|
      inquiry.update_attributes(project_uid: inquiry.inquiry_number) if inquiry.inquiry_number.present? && inquiry.project_uid.blank?;
    end
  end

  def find_business_partner_by_name
    ::Resources::BusinessPartner.custom_find('Subrata!!')
  end

  def delete_inquiry_products
    SalesQuoteRow.delete_all
    SalesQuote.delete_all
    InquiryProductSupplier.delete_all
    InquiryProduct.delete_all
  end

  def make_admins
    ['vignesh.gounder@bulkmro.com',
     'gitesh.ganekar@bulkmro.com',
     'ajay.rathod@bulkmro.com',
     'sanchit.sharma@bulkmro.com',
     'ovais.ansari@bulkmro.com',
     'diksha.tambe@bulkmro.com',
     'dinesh.kumar@bulkmro.com',
     'ankur.gupta@bulkmro.com',
     'sumit.sharma@bulkmro.com',
     'farhan.ansari@bulkmro.com',
     'bhargav.trivedi@bulkmro.com',
     'ajay.kondal@bulkmro.com',
     'pravin.ganekar@bulkmro.com',
     'nida.khan@bulkmro.com',
     'soni.pathre@bulkmro.com',
     'vijay.manjrekar@bulkmro.com',
    ].each do |email|
      Overseer.find_by_email(email).admin! if Overseer.find_by_email(email).present?
    end
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
      overseer.update_attributes(role: kv[0].to_sym) if overseer.present?
    end
  end

  def approve_products
    PaperTrail.request(enabled: false) do
      Product.all.not_approved.each do |product|
        product.create_approval(comment: product.comments.create!(overseer: Overseer.default, message: 'Legacy product, being preapproved'), overseer: Overseer.default) if product.approval.blank?
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
      service = Services::Shared::Spreadsheets::CsvImporter.new('products.csv', 'seed_files')
      service.loop(nil) do |x|
        next if x.get_column('entity_id').to_i < 677812
        brand = Brand.where("legacy_metadata->>'option_id' = ?", x.get_column('product_brand')).first
        product = Product.find_by_legacy_id(x.get_column('entity_id'))
        product.update_attributes(brand: brand) if product.present?
      end
    end
  end


  def activities_migration_fix
    Activity.where(created_by: nil).each do |activity|
      activity_overseer = activity.activity_overseers.first

      ActiveRecord::Base.transaction do
        activity.update_attributes!(overseer: activity_overseer.overseer)
        activity_overseer.destroy!
      end if activity_overseer.present?
    end
  end

  def activities_migration_fix_2
    service = Services::Shared::Spreadsheets::CsvImporter.new('activity_reports.csv', 'seed_files')
    service.loop(nil) do |x|
      overseer_legacy_id = x.get_column('overseer_legacy_id')
      overseer = Overseer.find_by_legacy_id(overseer_legacy_id)
      activity = Activity.where(legacy_id: x.get_column('legacy_id')).first
      activity.update_attributes(created_by: overseer, updated_by: overseer) if activity.present?
    end
  end

  def product_brands_fix
    service = Services::Shared::Spreadsheets::CsvImporter.new('products.csv', 'seed_files')
    service.loop(nil) do |x|
      brand = Brand.where("legacy_metadata->>'option_id' = ?", x.get_column('product_brand')).first
      product = Product.find_by_legacy_id(x.get_column('entity_id'))
      product.update_attributes(brand: brand)
    end
  end

  def gst_tax_rate_fix
    TaxCode.where('code LIKE ?', '%8424').size
  end

  def update_sales_managers_for_inquiries
    folders = ['seed_files', 'seed_files_2']
    folders.each do |folder|
      service = Services::Shared::Spreadsheets::CsvImporter.new('inquiries_without_amazon.csv', folder)
      service.loop(nil) do |x|
        inquiry_number = x.get_column('increment_id', downcase: true, remove_whitespace: true)
        inquiry = Inquiry.find_by_inquiry_number(inquiry_number)
        if inquiry.present?
          legacy_inside_sales_owner_username = x.get_column('manager', downcase: true).downcase.split(' ').join('.') if x.get_column('manager', downcase: true).present?
          inside_sales_owner_username = inquiry.inside_sales_owner.username if inquiry.inside_sales_owner.present?
          inquiry.inside_sales_owner = Overseer.find_by_username(legacy_inside_sales_owner_username) if legacy_inside_sales_owner_username != inside_sales_owner_username

          legacy_outside_sales_owner_username = x.get_column('outside', downcase: true).downcase.split(' ').join('.') if x.get_column('outside', downcase: true).present?
          outside_sales_owner_username = inquiry.outside_sales_owner.username if inquiry.outside_sales_owner.present?
          inquiry.outside_sales_owner = Overseer.find_by_username(legacy_outside_sales_owner_username) if legacy_outside_sales_owner_username != outside_sales_owner_username

          legacy_sales_manager_username = x.get_column('powermanager', downcase: true).downcase.split(' ').join('.') if x.get_column('powermanager', downcase: true).present?
          sales_manager_username = inquiry.sales_manager.username if inquiry.sales_manager.present?
          inquiry.sales_manager = Overseer.find_by_username(legacy_sales_manager_username) if legacy_sales_manager_username != sales_manager_username
          inquiry.save!
        end
      end
    end
  end

  def resend_failed_remote_requests(start_at: Date.yesterday.beginning_of_day, end_at: Date.yesterday.end_of_day, ignore_drafts: false)
    requests = RemoteRequest.where(created_at: start_at..end_at).failed

    if ignore_drafts
      requests.where.not(resource: 'Drafts')
    end

    requested = []
    requested_ids = []
    requests.each do |request|
      new_request = [request.subject]
      if !requested.include? new_request
        if request.subject_type.present? && request.subject_id.present? && request.latest_request.status == 'failed'
          begin
            Object.const_get(request.subject_type).find(request.subject_id).save_and_sync
            requested << new_request
            requested_ids << request.id
          rescue
            puts request
          end
        end
      end
    end
    ResyncRequest.create(request: requested_ids) if requested_ids.present?
    [requested_ids.sort, requested_ids.size]
  end

  def update_warehouse_and_inquiry
    update_if_exists = true

    service = Services::Shared::Spreadsheets::CsvImporter.new('warehouses.csv', 'seed_files')
    service.loop(nil) do |x|
      warehouse = Warehouse.where(name: x.get_column('Warehouse Name')).first_or_initialize
      if warehouse.new_record? || update_if_exists
        warehouse.remote_uid = x.get_column('Warehouse Code')
        warehouse.legacy_id = x.get_column('Warehouse Code')
        warehouse.location_uid = x.get_column('Location')
        warehouse.remote_branch_name = x.get_column('Warehouse Name')
        warehouse.remote_branch_code = x.get_column('Business Place ID')
        warehouse.legacy_metadata = x.get_row
        warehouse.build_address(
            name: x.get_column('Account Name'),
            street1: x.get_column('Street'),
            street2: x.get_column('Block'),
            pincode: x.get_column('Zip Code'),
            city_name: x.get_column('City'),
            country_code: x.get_column('Country'),
            gst: x.get_column('GST'),
            state: AddressState.find_by_region_code(x.get_column('State'))
        )
        warehouse.save!
      end
    end

    folders = ['seed_files', 'seed_files_2']
    folders.each do |folder|
      service = Services::Shared::Spreadsheets::CsvImporter.new('inquiries_without_amazon.csv', folder)
      service.loop(nil) do |x|
        inquiry_number = x.get_column('increment_id', downcase: true, remove_whitespace: true)
        next if inquiry_number.nil? || inquiry_number == '0' || inquiry_number == 0
        inquiry = Inquiry.where(inquiry_number: inquiry_number).first_or_initialize
        if inquiry.new_record? || update_if_exists
          inquiry.bill_from = Warehouse.find_by_legacy_id(x.get_column('warehouse'))
          inquiry.ship_from = Warehouse.find_by_legacy_id(x.get_column('ship_from_warehouse'))
          inquiry.save!
        end
      end
    end
  end


  def get_product_price(product_id, company)
    company_inquiries = company.inquiries.includes(:sales_quote_rows, :sales_order_rows)
    sales_order_rows = company_inquiries.map {|i| i.sales_order_rows.includes(:product).joins(:product).where('products.id = ?', product_id)}.flatten.compact
    sales_order_row_price = sales_order_rows.map {|r| r.unit_selling_price}.flatten if sales_order_rows.present?
    return sales_order_row_price.min if sales_order_row_price.present?
    sales_quote_rows = company_inquiries.map {|i| i.sales_quote_rows.includes(:product).joins(:product).where('products.id = ?', product_id)}.flatten.compact
    sales_quote_row_price = sales_quote_rows.pluck(:unit_selling_price)
    return sales_quote_row_price.min
  end

  def generate_customer_products_from_existing_products
    customers = Contact.all
    customers.each do |customer|
      customer_companies = customer.companies
      inquiry_products = Inquiry.includes(:inquiry_products, :products).where(company: customer_companies).map {|i| i.inquiry_products}.flatten if customer_companies.present?
      if inquiry_products.present?
        inquiry_products.each do |inquiry_product|
          CustomerProduct.where(company_id: inquiry_product.inquiry.company_id, sku: inquiry_product.product.sku).first_or_create do |customer_product|
            customer_product.product_id = inquiry_product.product_id
            customer_product.category_id = inquiry_product.product.category_id
            customer_product.brand_id = inquiry_product.product.brand_id
            customer_product.name = inquiry_product.product.name

            # customer_product.customer_price = get_product_price(inquiry_product.product_id, inquiry_product.inquiry.company)

            customer_product.created_by = customer
          end
        end
      end
    end
  end

  def update_and_remove_sales_quote_rows
    folders = ['seed_files', 'seed_files_2']
    folders.each do |folder|
      service = Services::Shared::Spreadsheets::CsvImporter.new('inquiry_items.csv', folder)
      service.loop(nil) do |x|
        # TODO: remove sales quote rows which are excluded in magento and not considered in total sales quote value
      end
    end
  end

  def update_sales_orders_for_legacy_inquiries
    folders = ['seed_files', 'seed_files_2']
    folders.each do |folder|
      legacy_request_status_mapping = {'requested' => 10, 'SAP Approval Pending' => 20, 'rejected' => 30, 'SAP Rejected' => 40, 'Cancelled' => 50, 'approved' => 60, 'Order Deleted' => 70}
      remote_status = {'Supplier PO: Request Pending' => 17, 'Supplier PO: Partially Created' => 18, 'Partially Shipped' => 19, 'Partially Invoiced' => 20, 'Partially Delivered: GRN Pending' => 21, 'Partially Delivered: GRN Received' => 22, 'Supplier PO: Created' => 23, 'Shipped' => 24, 'Invoiced' => 25, 'Delivered: GRN Pending' => 26, 'Delivered: GRN Received' => 27, 'Partial Payment Received' => 28, 'Payment Received (Closed)' => 29, 'Cancelled by SAP' => 30, 'Short Close' => 31, 'Processing' => 32, 'Material Ready For Dispatch' => 33, 'Order Deleted' => 70}
      service = Services::Shared::Spreadsheets::CsvImporter.new('sales_order_drafts.csv', folder)
      service.loop(nil) do |x|
        inquiry_number = x.get_column('inquiry_number').to_i
        next if inquiry_number == 11505
        inquiry = Inquiry.find_by_inquiry_number(inquiry_number)
        next if inquiry.blank?

        requested_by = Overseer.find_by_legacy_id!(x.get_column('requested_by')) || Overseer.default

        sales_quote = inquiry.sales_quotes.last
        next if sales_quote.blank?
        sales_orders_legacy_metadata = inquiry.sales_orders.pluck(:legacy_metadata)
        puts '<-------------------###########################33------------------>' if sales_orders_legacy_metadata.include?(x.get_row)
        # sales_order = sales_quote.sales_orders.where(remote_uid: x.get_column('remote_uid')).first_or_initialize
        # if sales_order.new_record? || update_if_exists
        #   sales_order.overseer = requested_by
        #   sales_order.order_number = x.get_column('order_number')
        #   sales_order.created_at = x.get_column('requested_time').to_datetime
        #   sales_order.draft_uid = x.get_column('doc_num')
        #   sales_order.legacy_request_status = legacy_request_status_mapping[x.get_column('request_status')]
        #   sales_order.remote_status = remote_status[x.get_column('remote_status')]
        #   sales_order.legacy_metadata = x.get_row
        #   sales_order.sent_at = sales_quote.created_at
        #   sales_order.save!
        # end
        #
        # product_skus = x.get_column('skus')
        #
        # sales_quote.rows.each do |row|
        #   if product_skus.include? row.product.sku
        #     sales_order.rows.where(:sales_quote_row => row).first_or_create!
        #   end
        # end
        #
        # todo handle cancellation, etc
        # request_status = x.get_column('request_status')
        #
        # if !sales_order.approved?
        #   if request_status.in? %w(approved requested)
        #     sales_order.create_approval(
        #         :comment => sales_order.inquiry.comments.create!(:overseer => Overseer.default, message: 'Legacy sales order, being preapproved'),
        #         :overseer => Overseer.default,
        #         :metadata => Serializers::InquirySerializer.new(sales_order.inquiry)
        #     )
        #   elsif request_status == 'rejected'
        #     sales_order.create_rejection(
        #         :comment => sales_order.inquiry.comments.create!(:overseer => Overseer.default, message: 'Legacy sales order, being rejected'),
        #         :overseer => Overseer.default
        #     )
        #   else
        #     sales_order.inquiry.comments.create(:overseer => Overseer.default, message: "Legacy sales order, being #{request_status}")
        #   end
        # end
      end
    end
  end

  def inquiry_status_update
    Inquiry.joins('LEFT JOIN inquiry_status_records ON inquiry_status_records.inquiry_id = inquiries.id').distinct.where(inquiry_status_records: {inquiry_id: nil}).with_includes.each do |inquiry|
      if inquiry.inquiry_status_records.blank?
        subject = inquiry
        status = inquiry.status
        if inquiry.final_sales_quote.present?
          subject = inquiry.final_sales_quote
          status = 'Quotation Sent'
        end

        if inquiry.sales_orders.any?
          subject = inquiry.sales_orders.last
          status = 'Expected Order'
        end

        if inquiry.sales_orders.remote_approved.any?
          subject = inquiry.sales_orders.remote_approved.last
          status = 'Order Won'
        end
        inquiry.update_attribute(:status, status)
        InquiryStatusRecord.where(status: status, inquiry: inquiry, subject_type: subject.class.name, subject_id: subject.try(:id)).first_or_create if inquiry.inquiry_status_records.blank?
      end
    end
  end

  def destroy_customer_products_variant
    CustomerProduct.with_attachments.each do |customer_product|
      customer_product.best_images.each do |image|
        image.service.delete(customer_product.watermarked_variation(image, 'tiny').key)
        image.service.delete(customer_product.watermarked_variation(image, 'small').key)
        image.service.delete(customer_product.watermarked_variation(image, 'medium').key)
      end
    end
  end

  def set_activity_date_and_create_approval
    Activity.where(activity_date: nil).each do |activity|
      activity.update_attribute('activity_date', activity.created_at)
    end

    Activity.not_approved.each do |activity|
      activity.create_approval(overseer: Overseer.default_approver)
    end
  end

  def set_tax_rate_and_tax_code_for_customer_order_rows
    CustomerOrderRow.all.each do |row|
      row.update_attributes(tax_rate_id: row.customer_product.best_tax_rate.id, tax_code_id: row.customer_product.best_tax_code.id)
      row.save
    end
  end

  def fetch_address
    service = Services::Shared::Spreadsheets::CsvImporter.new('sap_address1.csv', 'seed_files')
    mismatch = []
    missing = []
    service.loop() do |x|
      address_uid = x.get_column('address_uid')
      company_uid = x.get_column('company_uid')
      data = {company: company_uid, address: address_uid}
      address = Address.find_by_remote_uid(address_uid)
      if address.present?
        if address.company.remote_uid != company_uid
          # mismatch = []
          mismatch << data
        end
      else
        # missing << data
        # missing << company_uid
        company = Company.find_by_remote_uid(company_uid)
        if company.present?
          address = company.addresses.new(
              gst: x.get_column('gst'),
              country_code: x.get_column('country_code'),
              state: AddressState.find_by_region_code(x.get_column('State')),
              state_name: nil,
              city_name: x.get_column('city_name'),
              pincode: x.get_column('pincode'),
              street1: x.get_column('street1'),
              remote_uid: address_uid

          )
          address.save!
        else
          missing << data
        end
      end
    end
    return {missing: missing.uniq, mismatch: mismatch.uniq}
  end

  def add_logistics_owner_to_all_po
    PurchaseOrder.all.each do |po|
      po.update_attributes(logistics_owner: Services::Overseers::MaterialPickupRequests::SelectLogisticsOwner.new(po).call)
    end
  end

  def sync_last_synced_quote
    inquiries = Inquiry.where(last_synced_quote_id: nil).last(30)
    inquiries.each do |inquiry|
      inquiry.update_attribute(:last_synced_quote_id, inquiry.final_sales_quote.id) if inquiry.final_sales_quote.present?
    end
  end

  def update_sales_quote_remote_uid
    inquiries = Inquiry.where.not(last_synced_quote_id: nil)
    Inquiry.where.not(last_synced_quote_id: nil).each do |inquiry|
      inquiry.last_synced_quote.update_attribute(:remote_uid, inquiry.quotation_uid)
    end
  end

  def add_completed_po_to_material_followup_queue

    PurchaseOrder.all.where(created_at: Date.new(2019, 03, 05).beginning_of_day..Date.new(2019, 03, 06).end_of_day).each do |purchase_order|

      if purchase_order.po_request.present?
        if purchase_order.po_request != 'PO Created'
          purchase_order.po_request.assign_attributes(status: 'PO Created')
          purchase_order.po_request.save(validate: false)
        end

        if purchase_order.material_status == nil
          purchase_order.set_defaults
        end

        if purchase_order.material_status != 'Material Delivered'
          if purchase_order.email_messages.present? || !purchase_order.email_messages.where(purchase_order: purchase_order, email_type: 'Sending PO to Supplier').present?

            email_message = purchase_order.email_messages.build(
                overseer: Overseer.default_approver,
                inquiry: purchase_order.inquiry,
                purchase_order: purchase_order,
                sales_order: purchase_order.po_request.sales_order,
                email_type: 'Sending PO to Supplier'
            )
            email_message.assign_attributes(from: Overseer.default_approver.email, to: Overseer.default_approver.email, subject: "Internal Ref Inq ##{purchase_order.inquiry.inquiry_number} Purchase Order ##{purchase_order.po_number}")
            email_message.save!
          end
        end
      else
        puts "po request not available for #{purchase_order.po_number}"
      end
    end
  end

  def check_and_fix_sales_quote_row_margins

    invalid_sales_orders = Set.new
    invalid_sales_orders_rows = Set.new


    fixed_sales_orders_rows = Set.new

    SalesOrderRow.where(sales_order: SalesOrder.remote_approved).where.not(sales_quote_row: nil).includes(:sales_quote_row, :inquiry_product_supplier).each do |sales_order_row|
      is_not_valid = !sales_order_row.sales_quote_row.is_unit_selling_price_consistent_with_margin_percentage?

      if is_not_valid
        sales_quote_row = sales_order_row.sales_quote_row

        order_number = sales_order_row.sales_order.order_number
        invalid_sales_orders << "#{order_number}" if is_not_valid
        invalid_sales_orders_rows << "#{order_number}-#{sales_order_row.id}" if is_not_valid

        unit_cost_price_with_unit_freight_cost = sales_quote_row.unit_cost_price_with_unit_freight_cost
        unit_selling_price = sales_quote_row.unit_selling_price
        margin_percentage = 1 - (unit_cost_price_with_unit_freight_cost / unit_selling_price);

        if unit_cost_price_with_unit_freight_cost > 0
          margin_percentage = (margin_percentage * 100).round(2)
        else
          margin_percentage = 100
        end
        if unit_selling_price <= 0
          margin_percentage = -10000000
        end
        sales_quote_row.update_attribute(:margin_percentage, margin_percentage)


        is_valid = sales_order_row.sales_quote_row.is_unit_selling_price_consistent_with_margin_percentage?
        fixed_sales_orders_rows << "#{order_number}-#{sales_order_row.id}" if is_valid && is_not_valid
      end
    end

    [invalid_sales_orders.count, invalid_sales_orders_rows.count, fixed_sales_orders_rows.count]
  end



  def set_inside_sales_for_inquiries

    inquiries = [1, 2, 3, 10, 11, 12, 13, 14, 15, 16, 19, 20, 21, 22, 23, 25, 27, 28, 29, 30, 32, 33, 34, 38, 39, 40, 41, 43, 45, 46, 47, 48, 50, 51, 53, 54, 55, 56, 57, 58, 60, 61, 62, 63, 64, 66, 67, 70, 75, 76, 77, 81, 82, 84, 86, 88, 89, 90, 91, 92, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 106, 107, 108, 109, 110, 112, 113, 114, 115, 116, 117, 118, 119, 120, 122, 123, 124, 125, 127, 129, 130, 131, 133, 136, 137, 138, 140, 141, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 155, 156, 158, 159, 160, 162, 163, 166, 169, 171, 173, 175, 178, 180, 181, 182, 183, 184, 186, 187, 193, 194, 195, 196, 199, 200, 201, 203, 204, 205, 207, 211, 212, 213, 217, 218, 220, 222, 223, 225, 226, 229, 230, 235, 236, 238, 241, 243, 246, 248, 249, 250, 252, 253, 254, 257, 260, 268, 269, 272, 282, 286, 287, 288, 289, 294, 301, 305, 309, 318, 323, 350, 391, 393, 395, 421, 424, 425, 426, 427, 453, 469, 470, 482, 484, 508, 514, 523, 532, 540, 545, 554, 568, 588, 606, 607, 611, 617, 623, 624, 625, 632, 633, 638, 644, 646, 648, 651, 652, 661, 663, 665, 667, 675, 684, 688, 690, 707, 714, 715, 716, 730, 732, 733, 737, 742, 746, 751, 752, 763, 765, 766, 767, 772, 782, 784, 791, 794, 798, 799, 801, 803, 809, 813, 814, 817, 819, 820, 821, 834, 847, 849, 852, 859, 865, 868, 881, 892, 893, 894, 895, 896, 897, 901, 903, 918, 919, 920, 931, 932, 943, 949, 957, 959, 960, 966, 967, 968, 969, 970, 971, 972, 975, 980, 993, 994, 998, 999, 1000, 1007, 1008, 1009, 1017, 1021, 1025, 1028, 1030, 1033, 1034, 1042, 1044, 1050, 1052, 1054, 1055, 1057, 1060, 1061, 1063, 1064, 1065, 1066, 1070, 1071, 1072, 1073, 1083, 1087, 1095, 1096, 1097, 1100, 1108, 1119, 1125, 1127, 1129, 1133, 1134, 1138, 1146, 1158, 1162, 1163, 1173, 1174, 1176, 1178, 1184, 1196, 1197, 1200, 1201, 1214, 1217, 1218, 1227, 1228, 1234, 1237, 1238, 1242, 1243, 1244, 1253, 1261, 1269, 1270, 1273, 1280, 1285, 1286, 1306, 1308, 1310, 1311, 1312, 1313, 1318, 1320, 1327, 1331, 1339, 1341, 1364, 1373, 1374, 1376, 1381, 1383, 1384, 1385, 1387, 1395, 1396, 1397, 1402, 1406, 1420, 1421, 1424, 1426, 1430, 1431, 1432, 1433, 1434, 1443, 1447, 1451, 1452, 1454, 1456, 1461, 1463, 1474, 1476, 1480, 1481, 1483, 1485, 1486, 1487, 1493, 1494, 1496, 1497, 1499, 1504, 1511, 1512, 1517, 1519, 1523, 1537, 1540, 1555, 1558, 1560, 1563, 1565, 1566, 1568, 1570, 1573, 1575, 1578, 1579, 1586, 1588, 1594, 1596, 1615, 1618, 1621, 1624, 1640, 1642, 1646, 1649, 1650, 1662, 1665, 1671, 1672, 1674, 1675, 1691, 1713, 1721, 1724, 1740, 1742, 1763, 1770, 1773, 1778, 1779, 1805, 1806, 1807, 1824, 1829, 1831, 1840, 1844, 1846, 1848, 1851, 1852, 1859, 1860, 1861, 1862, 1864, 1868, 1869, 1871, 1872, 1874, 1876, 1881, 1882, 1887, 1888, 1889, 1895, 1900, 1901, 1905, 1908, 1915, 1917, 1918, 1919, 1922, 1923, 1927, 1929, 1931, 1932, 1935, 1937, 1940, 1941, 1945, 1950, 1957, 1960, 1962, 1964, 1965, 1967, 1971, 1986, 1987, 1989, 1991, 1993, 1995, 2001, 2002, 2005, 2006, 2007, 2009, 2010, 2013, 2015, 2018, 2019, 2022, 2023, 2024, 2029, 2031, 2033, 2034, 2036, 2037, 2039, 2043, 2045, 2048, 2049, 2050, 2051, 2052, 2055, 2056, 2060, 2061, 2062, 2064, 2065, 2069, 2079, 2080, 2082, 2086, 2087, 2090, 2094, 2097, 2099, 2101, 2102, 2103, 2105, 2108, 2112, 2117, 2120, 2123, 2137, 2143, 2151, 2152, 2156, 2159, 2161, 2163, 2164, 2166, 2170, 2174, 2175, 2180, 2185, 2186, 2187, 2202, 2203, 2208, 2210, 2211, 2212, 2213, 2215, 2216, 2217, 2221, 2223, 2226, 2230, 2235, 2236, 2237, 2239, 2240, 2245, 2249, 2253, 2258, 2261, 2265, 2266, 2268, 2271, 2289, 2291, 2292, 2294, 2298, 2302, 2306, 2307, 2311, 2315, 2328, 2335, 2336, 2345, 2362, 2365, 2408, 2420, 2423, 2428, 2429, 2430, 2431, 2438, 2445, 2446, 2448, 2459, 2460, 2462, 2465, 2469, 2479, 2481, 2482, 2494, 2495, 2507, 2512, 2520, 2522, 2528, 2534, 2539, 2543, 2584, 2590, 2600, 2602, 2611, 2613, 2614, 2627, 2632, 2658, 2660, 2678, 2680, 2682, 2690, 2725, 2729, 2742, 2745, 2746, 2770, 2773, 2781, 2782, 2798, 2800, 2812, 2834, 2840, 2841, 2846, 2861, 2867, 2902, 2941, 2947, 2953, 2992, 2995, 2997, 2998, 2999, 3006, 3025, 3028, 3035, 3120, 3238, 3242, 3257, 3304, 3307, 3310, 3358, 3359, 3360, 3380, 3397, 3450, 3451, 3453, 3459, 3468, 3478, 3481, 3491, 3505, 3509, 3514, 3520, 3526, 3530, 3548, 3553, 3555, 3556, 3562, 3568, 3586, 3587, 3590, 3601, 3611, 4020, 4021, 4161, 4172, 4241, 4366, 4377, 4382, 4392, 4493, 4495, 4496, 4497, 4500, 4502, 4503, 4504, 4506, 4508, 4511, 4512, 4513, 4514, 4515, 4516, 4517, 4518, 4519, 4520, 4522, 4526, 4527, 4529, 4530, 4534, 4535, 4536, 4537, 4538, 4539, 4542, 4544, 4545, 4546, 4547, 4548, 4549, 4550, 4551, 4552, 4553, 4554, 4555, 4556, 4557, 4558, 4562, 4563, 4564, 4568, 4569, 4570, 4571, 4574, 4576, 4577, 4578, 4580, 4581, 4584, 4585, 4586, 4587, 4591, 4593, 4594, 4595, 4596, 4597, 4599, 4601, 4602, 4603, 4604, 4607, 4611, 4612, 4613, 4614, 4615, 4617, 4619, 4623, 4624, 4626, 4627, 4628, 4629, 4630, 4632, 4633, 4634, 4635, 4636, 4637, 4638, 4639, 4640, 4641, 4642, 4643, 4644, 4645, 4651, 4653, 4654, 4655, 4657, 4664, 4665, 4666, 4673, 4675, 4677, 4678, 4679, 4680, 4683, 4686, 4688, 4689, 4691, 4692, 4694, 4695, 4696, 4698, 4699, 4700, 4701, 4703, 4704, 4705, 4707, 4708, 4709, 4711, 4712, 4713, 4715, 4716, 4717, 4718, 4719, 4720, 4723, 4724, 4726, 4728, 4729, 4730, 4731, 4732, 4735, 4736, 4737, 4738, 4740, 4741, 4742, 4743, 4746, 4748, 4749, 4750, 4751, 4753, 4760, 4761, 4762, 4763, 4764, 4766, 4767, 4768, 4769, 4770, 4793, 4796, 4797, 4802, 4809, 4821, 4822, 4825, 4830, 4831, 4832, 4833, 4834, 4835, 4844, 4851, 4864, 4867, 4869, 4871, 4872, 4901, 4902, 4907, 4911, 4912, 4921, 4923, 4941, 4944, 4945, 4946, 4956, 4960, 4965, 4976, 4980, 4981, 4988, 4995, 4997, 5031, 5048, 5053, 5069, 5070, 5072, 5074, 5081, 5082, 5093, 5101, 5104, 5107, 5111, 5115, 5116, 5140, 5141, 5142, 5143, 5144, 5161, 5171, 5204, 5205, 5210, 5211, 5228, 5235, 5241, 5243, 5247, 5250, 5251, 5256, 5262, 5270, 5275, 5276, 5284, 5291, 5292, 5299, 5302, 5334, 5346, 5373, 5385, 5402, 5418, 5421, 5422, 5428, 5445, 5446, 5459, 5462, 5467, 5473, 5474, 5486, 5489, 5491, 5498, 5499, 5515, 5527, 5531, 5554, 5565, 5568, 5571, 5580, 5581, 5599, 5601, 5617, 5619, 5622, 5652, 5668, 5670, 5728, 5732, 5747, 5748, 5764, 5783, 5788, 5850, 5854, 5872, 5883, 5893, 5896, 5904, 5905, 5911, 5939, 5949, 5963, 6040, 6041, 6099, 6105, 6126, 6163, 6185, 6188, 6192, 6203, 6204, 6224, 6227, 6239, 6281, 6285, 6286, 6289, 6294, 6319, 6321, 6344, 6347, 6351, 6358, 6369, 6373, 6379, 6381, 6385, 6390, 6391, 6401, 6406, 6409, 6414, 6420, 6423, 6426, 6427, 6428, 6430, 6431, 6433, 6436, 6445, 6454, 6455, 6457, 6458, 6466, 6473, 6476, 6479, 6481, 6486, 6499, 6502, 6508, 6518, 6521, 6530, 6534, 6536, 6542, 6543, 6545, 6552, 6554, 6555, 6556, 6557, 6577, 6584, 6589, 6596, 6605, 6606, 6607, 6608, 6609, 6610, 6612, 6613, 6617, 6618, 6624, 6625, 6627, 6629, 6636, 6637, 6638, 6642, 6656, 6659, 6665, 6666, 6674, 6675, 6676, 6677, 6680, 6683, 6684, 6695, 6697, 6700, 6701, 6702, 6703, 6704, 6716, 6721, 6725, 6730, 6732, 6736, 6740, 6744, 6747, 6748, 6749, 6750, 6751, 6752, 6753, 6756, 6757, 6759, 6760, 6770, 6779, 6782, 6799, 6811, 6812, 6820, 6829, 6830, 6831, 6832, 6833, 6839, 6840, 6841, 6857, 6862, 6863, 6866, 6905, 6911, 6912, 6927, 6928, 6932, 6937, 6940, 6941, 6944, 6952, 6966, 6967, 6968, 6972, 6973, 6974, 6977, 6979, 6984, 6986, 6996, 7006, 7024, 7025, 7027, 7032, 7042, 7051, 7052, 7058, 7059, 7061, 7065, 7067, 7068, 7069, 7078, 7079, 7080, 7082, 7088, 7089, 7097, 7106, 7111, 7115, 7121, 7122, 7125, 7146, 7159, 7180, 7183, 7198, 7199, 7200, 7202, 7206, 7217, 7232, 7235, 7236, 7245, 7255, 7270, 7275, 7277, 7279, 7280, 7286, 7298, 7304, 7306, 7321, 7336, 7337, 7338, 7339, 7341, 7342, 7349, 7353, 7357, 7382, 7383, 7384, 7385, 7386, 7388, 7389, 7401, 7403, 7404, 7410, 7411, 7412, 7414, 7416, 7422, 7432, 7440, 7461, 7471, 7472, 7473, 7474, 7475, 7482, 7490, 7509, 7511, 7524, 7525, 7555, 7556, 7585, 7586, 7607, 7608, 7610, 7625, 7626, 7636, 7652, 7666, 7674, 7675, 7678, 7679, 7680, 7704, 7707, 7710, 7712, 7713, 7715, 7716, 7718, 7738, 7739, 7758, 7761, 7762, 7763, 7764, 7765, 7766, 7767, 7768, 7769, 7770, 7788, 7800, 7807, 7812, 7813, 7835, 7836, 7837, 7838, 7839, 7840, 7842, 7843, 7844, 7845, 7847, 7848, 7849, 7850, 7854, 7855, 7858, 7864, 7883, 7891, 7900, 7901, 7902, 7903, 7904, 7906, 7922, 7936, 7946, 7947, 7949, 7950, 7951, 7952, 7954, 7955, 7957, 7958, 7959, 7960, 7962, 7963, 7964, 7965, 7967, 8015, 8030, 8037, 8054, 8055, 8056, 8057, 8059, 8060, 8079, 8080, 8081, 8093, 8094, 8095, 8099, 8118, 8123, 8149, 8151, 8152, 8179, 8180, 8181, 8182, 8183, 8184, 8185, 8186, 8187, 8201, 8248, 8255, 8256, 8257, 8260, 8261, 8263, 8266, 8269, 8316, 8379, 8437, 8438, 8454, 8456, 8496, 8508, 8547, 8558, 8774, 8775, 8786, 8791, 8792, 8793, 8794, 8797, 8884, 8913, 8976, 8998, 9066, 9164, 9191, 9192, 9320, 9369, 9378, 9388, 9426, 9455, 9459, 9483, 9495, 9496, 9498, 9519, 9546, 9585, 9638, 9641, 9676, 9749, 9846, 9912, 10094, 10321, 10322, 10410, 10474, 10482, 10484, 10544, 10577, 10630, 10675, 10711, 10714, 10758, 10777, 10798, 10812, 10841, 10861, 11058, 11061, 11117, 11137, 11182, 11186, 11187, 11188, 11189, 11201, 11208, 11212, 11215, 11221, 11238, 11245, 11246, 11247, 11249, 11258, 11259, 11274, 11279, 11280, 11281, 11282, 11283, 11284, 11285, 11286, 11287, 11288, 11292, 11294, 11295, 11301, 11302, 11311, 11322, 11325, 11332, 11333, 11337, 11338, 11339, 11340, 11341, 11342, 11343, 11344, 11345, 11347, 11349, 11355, 11361, 11370, 11372, 11373, 11382, 11385, 11386, 11387, 11388, 11389, 11391, 11392, 11393, 11394, 11395, 11397, 11403, 11404, 11405, 11412, 11413, 11418, 11419, 11423, 11426, 11427, 11429, 11433, 11450, 11452, 11453, 11454, 11456, 11458, 11460, 11463, 11464, 11465, 11466, 11467, 11468, 11474, 11475, 11479, 11484, 11496, 11512, 11514, 11515, 11519, 11521, 11524, 11526, 11527, 11528, 11529, 11530, 11531, 11534, 11536, 11537, 11538, 11543, 11549, 11550, 11559, 11565, 11566, 11576, 11582, 11588, 11589, 11590, 11591, 11592, 11593, 11597, 11598, 11599, 11600, 11601, 11609, 11642, 11646, 11647, 11648, 11649, 11650, 11657, 11659, 11661, 11666, 11669, 11692, 11693, 11694, 11695, 11696, 11699, 11700, 11701, 11703, 11704, 11705, 11737, 11739, 11740, 11744, 11745, 11746, 11747, 11748, 11752, 11760, 11763, 11767, 11772, 11777, 11780, 11781, 11782, 11783, 11784, 11785, 11786, 11787, 11788, 11825, 11840, 11865, 11866, 11871, 11874, 11876, 11879, 11880, 11881, 11882, 11883, 11884, 11886, 11893, 11900, 11907, 11908, 11916, 11933, 11934, 11935, 11936, 11937, 11939, 11940, 11941, 11942, 11943, 11944, 11949, 11950, 11954, 11965, 11970, 11994, 11995, 11997, 12006, 12017, 12018, 12020, 12029, 12030, 12031, 12032, 12033, 12034, 12040, 12064, 12085, 12086, 12103, 12104, 12105, 12107, 12108, 12109, 12110, 12111, 12112, 12120, 12121, 12124, 12137, 12139, 12140, 12145, 12148, 12154, 12166, 12169, 12170, 12171, 12173, 12174, 12177, 12178, 12179, 12182, 12183, 12184, 12185, 12186, 12187, 12188, 12189, 12202, 12214, 12216, 12218, 12219, 12222, 12223, 12224, 12225, 12251, 12252, 12253, 12255, 12257, 12258, 12259, 12260, 12261, 12265, 12280, 12294, 12295, 12296, 12297, 12298, 12308, 12309, 12310, 12311, 12339, 12344, 12346, 12348, 12349, 12351, 12353, 12354, 12358, 12364, 12370, 12371, 12392, 12435, 12437, 12438, 12439, 12440, 12447, 12448, 12449, 12453, 12454, 12486, 12505, 12522, 12534, 12542, 12543, 12555, 12556, 12557, 12558, 12559, 12609, 12610, 12611, 12625, 12643, 12674, 12676, 12678, 12680, 12681, 12682, 12685, 12687, 12688, 12689, 12705, 12707, 12710, 12712, 12743, 12747, 12750, 12751, 12752, 12753, 12754, 12755, 12757, 12780, 12782, 12786, 12797, 12798, 12799, 12800, 12812, 12813, 12814, 12815, 12819, 12827, 12839, 12846, 12847, 12854, 12858, 12861, 12862, 12868, 12869, 12870, 12871, 12872, 12873, 12881, 12884, 12886, 12890, 12894, 12896, 12898, 12902, 12903, 12904, 12905, 12906, 12907, 12911, 12912, 12913, 12914, 12915, 12916, 12923, 12938, 12940, 12941, 12942, 12944, 12945, 12946, 12950, 12968, 12980, 12984, 13010, 13011, 13012, 13013, 13014, 13015, 13017, 13018, 13019, 13025, 13026, 13027, 13028, 13029, 13043, 13047, 13048, 13049, 13050, 13051, 13052, 13053, 13054, 13055, 13056, 13057, 13058, 13059, 13060, 13281, 13331, 13341, 13342, 13346, 13347, 13348, 13349, 13350, 13351, 13352, 13353, 13354, 13355, 13370, 13372, 13374, 13385, 13389, 13390, 13391, 13396, 13397, 13398, 13399, 13400, 13401, 13402, 13403, 13404, 13407, 13408, 13409, 13410, 13411, 13412, 13413, 13414, 13415, 13416, 13417, 13418, 13419, 13420, 13421, 13422, 13423, 13424, 13425, 13426, 13427, 13441, 13442, 13443, 13445, 13455, 13459, 13460, 13466, 13467, 13469, 13470, 13471, 13474, 13475, 13476, 13477, 13478, 13479, 13480, 13481, 13482, 13483, 13484, 13485, 13498, 13505, 13508, 13511, 13513, 13514, 13515, 13520, 13521, 13522, 13523, 13524, 13525, 13526, 13527, 13528, 13529, 13530, 13532, 13533, 13534, 13535, 13536, 13541, 13558, 13560, 13569, 13570, 13571, 13572, 13573, 13576, 13577, 13579, 13584, 13585, 13587, 13590, 13593, 13594, 13595, 13596, 13597, 13598, 13599, 13600, 13601, 13602, 13603, 13604, 13605, 13606, 13607, 13608, 13609, 13610, 13623, 13624, 13625, 13626, 13627, 13628, 13629, 13630, 13631, 13632, 13633, 13634, 13670, 13671, 13672, 13673, 13674, 13675, 13676, 13677, 13679, 13680, 13681, 13682, 13683, 13684, 13685, 13686, 13687, 13688, 13689, 13690, 13691, 13692, 13693, 13695, 13696, 13697, 13698, 13699, 13700, 13701, 13703, 13721, 13723, 13726, 13727, 13728, 13729, 13730, 13738, 13741, 13743, 13744, 13746, 13747, 13748, 13749, 13750, 13751, 13752, 13753, 13754, 13755, 13756, 13757, 13758, 13759, 13760, 13761, 13763, 13766, 13769, 13774, 13776, 13783, 13792, 13794, 13795, 13796, 13797, 13799, 13800, 13801, 13802, 13804, 13805, 13806, 13807, 13808, 13809, 13810, 13812, 13813, 13814, 13815, 13816, 13817, 13821, 13822, 13823, 13828, 13842, 13849, 13850, 13851, 13852, 13854, 13855, 13856, 13857, 13858, 13859, 13860, 13861, 13862, 13863, 13864, 13866, 13867, 13868, 13870, 13871, 13872, 13873, 13874, 13875, 13876, 13894, 13899, 13907, 13927, 13928, 13929, 13930, 13931, 13932, 13933, 13934, 13935, 13936, 13937, 13938, 13939, 13940, 13941, 13942, 13943, 13944, 13945, 13946, 13947, 13948, 13949, 13950, 13951, 13952, 13953, 13954, 13955, 13956, 13957, 13958, 13971, 13972, 13973, 13974, 13975, 13976, 13977, 14009, 14011, 14015, 14016, 14027, 14034, 14038, 14039, 14040, 14041, 14042, 14043, 14044, 14045, 14046, 14047, 14048, 14049, 14050, 14051, 14052, 14053, 14054, 14055, 14056, 14057, 14058, 14062, 14063, 14074, 14075, 14089, 14090, 14091, 14092, 14093, 14094, 14097, 14099, 14101, 14102, 14105, 14106, 14107, 14108, 14109, 14110, 14111, 14112, 14113, 14114, 14131, 14143, 14146, 14147, 14148, 14149, 14150, 14151, 14152, 14153, 14154, 14155, 14156, 14157, 14158, 14159, 14160, 14161, 14162, 14163, 14164, 14165, 14166, 14167, 14211, 14212, 14213, 14216, 14217, 14219, 14220, 14221, 14222, 14223, 14224, 14225, 14226, 14227, 14231, 14232, 14253, 14279, 14280, 14281, 14282, 14283, 14284, 14285, 14286, 14287, 14288, 14289, 14290, 14291, 14292, 14293, 14295, 14298, 14299, 14304, 14305, 14306, 14366, 14368, 14369, 14370, 14371, 14373, 14374, 14375, 14376, 14377, 14378, 14379, 14381, 14383, 14393, 14394, 14395, 14401, 14415, 14416, 14424, 14425, 14430, 14432, 14434, 14438, 14439, 14441, 14442, 14444, 14445, 14447, 14448, 14449, 14450, 14451, 14452, 14453, 14454, 14455, 14456, 14457, 14460, 14466, 14491, 14492, 14493, 14494, 14496, 14497, 14498, 14499, 14501, 14502, 14503, 14504, 14505, 14506, 14507, 14508, 14509, 14513, 14514, 14515, 14516, 14517, 14563, 14565, 14566, 14567, 14568, 14569, 14573, 14574, 14575, 14576, 14577, 14578, 14579, 14580, 14581, 14582, 14583, 14584, 14589, 14590, 14591, 14592, 14593, 14620, 14621, 14622, 14623, 14634, 14635, 14636, 14637, 14639, 14640, 14641, 14642, 14643, 14644, 14647, 14648, 14649, 14665, 14671, 14672, 14673, 14674, 14675, 14676, 14677, 14678, 14679, 14680, 14681, 14682, 14683, 14684, 14687, 14688, 14700, 14701, 14702, 14719, 14721, 14722, 14723, 14724, 14725, 14726, 14727, 14728, 14729, 14730, 14731, 14732, 14733, 14734, 14735, 14736, 14737, 14738, 14739, 14746, 14747, 14748, 14749, 14765, 14766, 14771, 14775, 14777, 14778, 14779, 14780, 14782, 14783, 14784, 14785, 14786, 14787, 14788, 14789, 14790, 14791, 14792, 14793, 14794, 14814, 14818, 14822, 14823, 14824, 14825, 14844, 14859, 14860, 14861, 14862, 14863, 14865, 14866, 14867, 14868, 14869, 14870, 14871, 14872, 14873, 14874, 14875, 14876, 14906, 14907, 14908, 14909, 14910, 14911, 14912, 14913, 14914, 14915, 14916, 14917, 14918, 14919, 14920, 14921, 14922, 14923, 14924, 14932, 14933, 14934, 14935, 14974, 14975, 14991, 14992, 14993, 14994, 14995, 14996, 14997, 14998, 14999, 15000, 15001, 15002, 15003, 15004, 15006, 15035, 15036, 15037, 15038, 15039, 15046, 15047, 15049, 15052, 15053, 15054, 15057, 15058, 15059, 15060, 15061, 15062, 15063, 15065, 15076, 15090, 15105, 15108, 15109, 15110, 15111, 15112, 15113, 15114, 15143, 15144, 15145, 15146, 15147, 15148, 15149, 15150, 15151, 15152, 15153, 15154, 15155, 15156, 15159, 15160, 15161, 15162, 15163, 15164, 15165, 15177, 15178, 15179, 15181, 15182, 15184, 15185, 15186, 15187, 15189, 15191, 15193, 15195, 15196, 15197, 15198, 15199, 15200, 15225, 15226, 15233, 15234, 15235, 15236, 15237, 15238, 15239, 15240, 15241, 15242, 15243, 15244, 15245, 15246, 15247, 15248, 15249, 15393, 15394, 15395, 15396, 15397, 15487, 15490, 15491, 15492, 15493, 15494, 15495, 15496, 15497, 15498, 15499, 15527, 15528, 15533, 15534, 15535, 15536, 15537, 15538, 15539, 15540, 15541, 15542, 15543, 15544, 15578, 15579, 15580, 15581, 15582, 15583, 15584, 15585, 15587, 15589, 15590, 15591, 15592, 15593, 15594, 15595, 15597, 15598, 15599, 15600, 15601, 15602, 15645, 15647, 15648, 15649, 15650, 15651, 15652, 15653, 15654, 15655, 15656, 15657, 15658, 15659, 15660, 15661, 15662, 15663, 15664, 15665, 15696, 15697, 15698, 15699, 15700, 15701, 15702, 15703, 15704, 15705, 15706, 15707, 15717, 15718, 15721, 15722, 15723, 15724, 15725, 15772, 15773, 15774, 15775, 15779, 15781, 15782, 15783, 15784, 15785, 15786, 15787, 15788, 15789, 15790, 15791, 15794, 15807, 15808, 15823, 15824, 15825, 15826, 15827, 15828, 15829, 15830, 15833, 15834, 15835, 15836, 15837, 15838, 15839, 15840, 15873, 15874, 15875, 15876, 15877, 15878, 15879, 15880, 15881, 15882, 15883, 15884, 15885, 15886, 15887, 15888, 15889, 15890, 15891, 15892, 15918, 15919, 15925, 15926, 15927, 15928, 15929, 15930, 15931, 15932, 15933, 15934, 15935, 15936, 15937, 15938, 15939, 15940, 15941, 15942, 15943, 15944, 15945, 15946, 15947, 15948, 15949, 15950, 15951, 15952, 15953, 15955, 15974, 15978, 15983, 15994, 15995, 15998, 15999, 16000, 16001, 16002, 16003, 16004, 16005, 16006, 16007, 16008, 16009, 16022, 16023, 16024, 16025, 16026, 16027, 16028, 16063, 16064, 16065, 16071, 16072, 16074, 16075, 16076, 16111, 16112, 16113, 16114, 16115, 16125, 16132, 16140, 16145, 16146, 16147, 16161, 16164, 16187, 16188, 16189, 16190, 16191, 16192, 16193, 16194, 16222, 16223, 16224, 16225, 16227, 16228, 16229, 16230, 16231, 16238, 16239, 16240, 16244, 16245, 16246, 16247, 16248, 16250, 16251, 16310, 16311, 16312, 16313, 16314, 16319, 16349, 16350, 16351, 16354, 16368, 16387, 16388, 16389, 16390, 16391, 16392, 16393, 16394, 16408, 16415, 16418, 16419, 16420, 16421, 16422, 16426, 16427, 16428, 16532, 16533, 16534, 16535, 16536, 16537, 16538, 16551, 16564, 16565, 16573, 16577, 16580, 16582, 16583, 16586, 16620, 16621, 16622, 16623, 16624, 16625, 16626, 16627, 16629, 16630, 16631, 16632, 16669, 16670, 16671, 16673, 16674, 16676, 16678, 16697, 16704, 16705, 16706, 16707, 16767, 16768, 16769, 16770, 16771, 16772, 16773, 16774, 16785, 16786, 16841, 16843, 16845, 16846, 16847, 16849, 16871, 16872, 16878, 16879, 16880, 16881, 16882, 16883, 16916, 16917, 16918, 16919, 16923, 16924, 16928, 16929, 16930, 16931, 16932, 16933, 16934, 16935, 16936, 16966, 16968, 16974, 16976, 16977, 16979, 16980, 16981, 17073, 17074, 17075, 17076, 17077, 17078, 17079, 17080, 17110, 17111, 17112, 17113, 17114, 17115, 17117, 17154, 17155, 17156, 17157, 17158, 17159, 17161, 17162, 17163, 17195, 17196, 17197, 17198, 17199, 17201, 17219, 17223, 17224, 17225, 17229, 17265, 17266, 17268, 17314, 17316, 17317, 17318, 17320, 17363, 17365, 17366, 17367, 17368, 17369, 17370, 17371, 17389, 17390, 17391, 17392, 17394, 17418, 17426, 17427, 17428, 17429, 17430, 17443, 17452, 17456, 17459, 17460, 17461, 17462, 17464, 17465, 17466, 17467, 17468, 17472, 17473, 17509, 17510, 17515, 17517, 17518, 17519, 17520, 17523, 17545, 17556, 17558, 17564, 17565, 17566, 17567, 17568, 17597, 17612, 17613, 17614, 17615, 17616, 17648, 17649, 17650, 17651, 17714, 17736, 17737, 17760, 17762, 17776, 17779, 17782, 17818, 17819, 17820, 17828, 17858, 17865, 17866, 17868, 17869, 17906, 17930, 18067, 18121, 18141, 18142, 18180, 18235, 18250, 18298, 18304, 18409, 18495, 18581, 18584, 18585, 18702, 18807, 18833, 18923, 19173, 19214, 19308, 19309, 19310, 19419, 19422, 19436, 19463, 19532, 19536, 19583, 19704, 19739, 19796, 19908, 19930, 20618, 20619, 20620, 20624, 20625, 20626, 20634, 20637, 20644, 20645, 20648, 20649, 20655, 20668, 20669, 20696, 20697, 20698, 20699, 20701, 20739, 20740, 20742, 20743, 20744, 20752, 20757, 20761, 20768, 20771, 20772, 20782, 20805, 20824, 20834, 20842, 20845, 20850, 20859, 20860, 20884, 20960, 20970, 20976, 20977, 20978, 21012, 21047, 21062, 21072, 21081, 21086, 21095, 21096, 21101, 21138, 21155, 21169, 21196, 21206, 21211, 21217, 21227, 21233, 21267, 21289, 21309, 21328, 21424, 21432, 21433, 21434, 21435, 21436, 21437, 21438, 21504, 25026, 25055, 25056, 25057, 25058, 25059, 25060, 25061, 25062, 25063, 25064, 25065, 25066, 25086, 25091, 25123, 25148, 25168, 25169, 25175, 25179, 25202, 25203, 25204, 25209, 25217, 25220, 25223, 25233, 25267, 25281, 25294, 25345, 25365, 25368, 25390, 25434, 25435, 25436, 25467, 25493, 25517, 25539, 25541, 25582, 25608, 25617, 25618, 25623, 25636, 25649, 25652, 25663, 25667, 25677, 25716, 25718, 25726, 25755, 25759, 25760, 25816, 25826, 25846, 25857, 25871, 25874, 25877, 25895, 25897, 25911, 25962, 25966, 25972, 25991, 26008, 26080, 26149, 26154, 26164, 26189, 26219, 26227, 26244, 26254, 26266, 26327, 26328, 26329, 26330, 26331, 26347, 26354, 26435, 26464, 26504, 26528, 26546, 26549, 26568, 26594, 26601, 26613, 26620, 26697, 26723, 26743, 26755, 26763, 26807, 26815, 26816, 26817, 26818, 26819, 26820, 26821, 26824, 26825, 26826, 26828, 26829, 26830, 26831, 26832, 26833, 26849, 26851, 26854, 26871, 26898, 26931, 26941, 27008, 27010, 27024, 27031, 27032, 27038, 27054, 27061, 27065, 27073, 27083, 27084, 27086, 27096, 27102, 27135, 27141, 27142, 27150, 27185, 27193, 27214, 27215, 27243, 27252, 27253, 27254, 27262, 27292, 27304, 27308, 27310, 27351, 27354, 27359, 27383, 27396, 27397, 27454, 27476, 27480, 27482, 27483, 27485, 27486, 27525, 27555, 27567, 27581, 27588, 27625, 27633, 27642, 27645, 27646, 27682, 27683, 27686, 27727, 27728, 27756, 27775, 27814, 27820, 27821, 27822, 27830, 27833, 27846, 27863, 27877, 27879, 27886, 27900, 27920, 27943, 27944, 27978, 28000, 28002, 28004, 28033, 28067, 28074, 28084, 28089, 28105, 28115, 28116, 28117, 28142, 28172, 28174, 28176, 28190, 28191, 28197, 28241, 28244, 28248]

    overseer = Overseer.find_by_email('lavanya.j@bulkmro.com')
    Inquiry.where(inquiry_number: inquiries).update_all(inside_sales_owner_id: overseer.id)


    [inquiries.count, Inquiry.where(inquiry_number: inquiries).count]
  end


  def set_outside_sales_for_inquiries
    inquiries = [1515,1491,6001,155,894,1882,7411,5187,187,7983,4835,38,64,1244,763,1108,1331,624,5020,798,58,1989,391,1618,7971,3530,25434,2180,1424,7556,2834,1575,7436,1941,41,7438,1488,3617,1477,1060,1061,7447,11481,10470,1234,765,6027,2423,7459,33,3553,183,102,57,10539,1320,163,1238,611,7473,6047,1184,16343,7892,508,1387,6953,7477,7484,318,2221,3611,4872,3514,7860,2590,1415,5353,4348,1596,1052,95,7503,7505,7824,4324,1650,6139,7812,6958,6137,6132,2798,7804,6128,56,62,119,6124,7798,4220,76,4204,4196,7549,7552,2024,523,849,2022,1347,2029,2007,226,7561,1311,4178,1336,1307,133,1396,7762,7575,4148,7576,25281,881,2102,2061,7584,6101,1303,1070,6098,4104,2001,1917,1915,1929,1923,11112,1773,1278,1995,4931,1895,4912,1862,1931,1009,11270,4083,1642,4981,1267,1255,999,350,25513,7742,1889,7618,7620,5265,4079,25514,7626,4072,4068,7726,1248,4063,2051,4051,1237,7714,1246,25517,1987,3169,424,1245,1724,4028,1665,1568,1566,1565,1570,2043,732,130,7696,1162,4026,7646,7650,7666,7675,1158,1134,746,7679,4013,7680,1172,77,1115,1074,2002,7758,6971,3664,7689,1486,7656,10395,5161,1196,7645,801,606,289,1579,6973,1485,12810,931,229,173,160,5204,175,3638,110,109,140,136,16342,2338,2033,7710,11196,2015,623,250,1119,684,1586,1649,903,3607,3604,7731,1919,5459,1869,5210,3598,1499,100,3596,230,5330,1285,1280,1261,868,1286,7739,847,236,1940,834,218,1038,632,10708,3582,6980,1519,1511,1905,1523,1024,1313,3567,1493,1312,1306,1540,633,1560,1480,943,7747,733,12328,5334,1573,1010,2090,2010,872,2101,1402,1381,1578,1452,1146,1129,949,249,1374,201,193,50,7560,821,158,7763,115,6983,7770,9600,3531,43,3529,3073,6826,7776,6240,2166,2760,3513,5710,2163,5823,3498,7782,7786,2151,7528,3488,61,800,7522,740,3486,569,7799,17813,3480,714,707,665,484,32,268,5467,10684,3466,294,6390,7816,3460,253,3447,7825,116,3433,7501,1034,3418,1096,3416,7842,859,2611,7495,122,7854,1385,301,112,6829,25618,3587,2430,2902,7862,51,21,730,3395,7877,7487,124,2543,166,6991,486,5831,89,2335,2174,766,5709,6629,7888,204,7895,7901,7907,2469,2682,2728,1974,2118,7922,25345,6202,434,2718,6832,2716,5768,3556,6199,10748,3468,7951,2711,2704,2052,6833,2705,7959,2614,2699,2700,2099,2746,2697,7974,151,22,2693,346,149,970,127,98,1512,137,25649,2217,3548,2328,194,5474,144,1675,2315,2097,5622,2520,19,7437,3590,25663,2687,2431,7431,2187,12211,285,11327,267,4495,1000,1710,7425,104,3344,7424,3330,405,8038,6381,21332,5863,3360,3359,3358,4506,150,661,588,2082,113,2428,4512,2686,2613,26898,4515,2676,2683,8057,8061,2539,2438,2670,8064,2143,8072,3302,4526,1932,220,4544,4550,8075,2665,2662,4831,11204,2663,3282,25708,3295,8080,8086,3294,5848,7002,4551,4554,8091,6835,9442,8095,4377,25718,4562,4568,9437,5850,4570,2838,4315,2618,4301,4306,2843,11495,11377,9409,3228,4271,6172,4256,2601,4251,2595,3221,4215,2585,2587,6169,4209,2579,6168,6167,4945,4195,2573,2574,4180,2568,7010,2557,2563,2549,6159,4147,2556,4118,6151,12740,6354,2541,4098,6839,2533,4088,2530,2518,1885,2525,2516,4067,4065,10904,2509,2732,2510,4045,4043,2498,3162,3135,25368,4030,2474,6339,4027,2490,6329,4012,2477,2480,2476,6322,4008,9316,6315,4001,2463,6840,10452,27073,2442,3637,2434,2435,7023,3113,6306,2409,2421,3606,2388,3599,6298,5865,6286,9252,3585,6368,3580,3581,2368,9250,2364,3571,3565,3563,2363,3558,3557,3547,25791,3545,3097,2358,2356,2360,7036,2354,6273,3524,9205,3519,3510,5872,2334,3493,2320,2333,3487,2318,9167,2319,25816,2313,3485,2317,7047,2310,14542,4946,2304,2301,3462,9143,2299,5618,3089,3081,7362,3449,2288,3443,5876,4965,3075,2281,3437,3436,3430,3070,3434,2274,3421,2269,7351,2264,3413,5877,2262,3064,19262,2250,3048,5878,3392,7326,3374,3368,3362,3363,2231,3349,2224,25846,3185,2227,6844,2218,3328,2209,3313,3296,2201,7064,3298,3288,2199,7293,1430,3251,2198,2191,3226,9802,6845,9788,25871,6571,2178,2177,9783,3175,11308,3165,2168,3157,9775,3032,2165,2167,5884,2150,25895,18395,3108,5893,2145,12324,2139,3005,3087,9743,7257,2133,2127,3000,2122,2126,3060,2115,2109,2113,1175,9697,7243,2978,2104,2096,5896,2948,2940,2085,2943,7104,2934,2078,7234,7230,2073,2072,2930,2920,9634,5667,2895,7108,2067,7215,2900,13440,2898,2882,2883,2877,2057,2021,2878,2868,2047,6707,2038,7209,2857,2851,13457,2003,2000,2844,2835,1996,2837,1994,6734,2825,7120,10655,1985,7175,7126,16330,1984,2808,1981,1980,7168,2792,1955,1959,1952,1933,1939,1930,1912,1903,1867,1884,7160,7156,1845,1854,6774,25539,7153,3645,2962,1708,1693,1681,6391,1697,5141,1666,1660,1654,6406,1673,1644,1643,1641,6414,1647,1628,1636,1625,6436,1638,1608,1606,1605,6486,1609,6783,1598,6789,7144,1600,7139,1583,1549,6849,1559,1542,1538,7137,7133,1535,1533,1529,1527,1514,6805,6499,1518,1509,1495,6534,1500,1490,1479,1275,1469,1458,1445,6536,1471,1442,1438,1436,7110,1414,1413,1411,1408,6589,1390,1394,1386,1382,6617,1393,1362,1354,7105,1346,7095,1322,13490,6618,1332,1326,1305,1319,1301,1298,1296,1283,18779,6636,1277,7060,7054,1252,1251,1250,1241,1233,1231,1226,1225,7029,1215,1192,1190,1188,1168,7015,6637,7005,1151,1150,7000,1139,1131,25990,6992,1091,8872,1082,10010,8856,1068,1047,7223,1046,1045,1040,2945,6638,1029,26008,1003,6969,990,988,987,6961,984,951,948,6959,941,926,6955,6949,907,906,905,13582,816,867,848,815,2935,807,7253,795,6939,789,786,785,6642,790,768,761,760,6770,775,753,744,694,6811,754,719,6930,701,697,8843,693,671,678,627,619,613,6922,596,593,13044,6919,572,570,551,534,6812,539,524,7296,11072,505,8780,499,497,492,483,408,487,477,473,445,2933,436,435,7180,439,431,428,418,7339,415,8858,411,6900,7345,8859,2932,404,390,389,388,7341,394,386,376,6885,26033,7354,7358,366,4534,349,345,4541,4802,336,328,6870,308,273,6862,6850,293,280,6851,6848,266,8722,6837,258,256,233,7419,210,79,139,7430,4496,2919,5901,4502,5902,6822,2908,4514,4513,4516,5905,4519,16162,6802,6796,5906,6853,6795,6792,4527,2901,6787,5908,5909,2899,8691,5910,2897,4536,8885,4537,5911,6785,6780,4542,7486,2885,5915,4546,4547,6765,4549,2881,4553,6859,8890,4556,4557,2869,7498,5919,5142,6860,2866,4563,7502,2865,8897,4569,6861,4571,2861,5925,2863,6729,4578,6723,6717,4581,7529,6863,4587,4592,4593,4595,4599,5931,4597,8906,2856,8557,7553,4640,4602,6866,6693,4607,2853,6686,4612,6867,5744,8514,4616,2842,12325,6673,4624,4627,4629,6670,5087,4632,4633,4634,4832,2836,4637,4638,6661,6658,7591,4643,4692,4644,8920,8476,5945,6653,4653,4654,4657,5947,2831,6872,8435,4694,4666,5951,4677,6619,4680,2827,2824,6614,12138,4689,4695,4697,4698,6875,4700,6601,6592,4704,4705,4708,2822,3260,4711,6574,6570,2408,4715,2809,4717,4718,2802,4720,3586,4723,26154,4728,5967,4749,4613,4731,11009,6879,4738,4741,4746,11154,4752,6513,2791,11180,4761,4764,8967,7759,4769,6483,5976,4773,10969,7779,2787,5979,2786,6471,6468,2785,8697,4790,4794,4793,4725,2507,4797,6451,4830,6886,2778,7827,4819,5143,4822,6435,2766,2763,6889,6417,4839,2762,5996,6411,5999,6890,5190,6000,7896,6398,7908,5216,4861,4858,6395,6394,6016,6393,2761,4869,5094,4874,6382,7973,6017,6377,4891,6376,6375,4895,6371,6020,4900,2754,6365,6021,7987,5791,213,2749,8431,4917,6023,5347,6024,4919,4921,4775,4944,4941,4943,2748,9025,11265,8034,6031,6937,10083,8051,10434,6035,6905,8062,10896,9040,8375,2743,8074,2992,6041,8360,8077,11131,1373,8358,4469,11628,26266,4968,10795,6049,6911,4973,4974,6912,8340,9058,4976,6053,6057,8712,8130,4995,2738,6062,5002,6061,11176,6065,8274,5048,11304,8266,8261,5031,6073,5037,6074,10630,2726,5043,4883,8219,8208,5858,5069,2666,8184,5072,5073,26330,2721,6083,5081,6086,5084,5086,8675,12026,5099,9080,10138,6099,5111,8172,6097,5116,26367,16067,5123,5125,5136,5139,5140,5147,5149,5181,6104,8149,26384,5154,5156,8140,6107,6108,2652,8119,5171,6111,5176,6112,6113,6114,5183,8105,10817,8066,8275,6120,6121,5196,8033,5202,6123,6125,4272,5218,6942,8003,5228,7996,6943,5230,6944,5235,6134,5238,7932,6135,12059,6136,4239,7944,5247,5250,5251,4203,2639,6140,8282,8280,5262,7919,2638,4915,5275,7918,6950,2636,2623,4120,7887,4107,8309,5292,6952,7342,26821,5295,6149,7878,7875,5299,7868,26817,6954,6152,6153,7859,7841,12228,8323,5315,5318,2617,8336,5329,5332,5337,12541,2606,5343,5418,5345,5346,4029,2605,2588,5354,6165,2581,6166,2576,3500,7793,2572,7789,6962,5421,7780,3439,5376,6173,5389,14215,5391,2501,5392,6965,2493,5400,3287,5404,6179,2492,2485,12190,7733,7735,2483,6182,25638,3202,6185,6204,7699,6192,2473,5428,5430,7695,2456,7692,5486,2433,3142,7654,7631,2394,5445,5446,2448,5451,6200,2367,5457,5460,5462,12892,26464,8352,66,6203,2312,5473,67,3124,6976,7609,2290,7603,7388,5485,6977,2286,5489,2278,7592,5493,8371,5499,6979,7389,2420,7579,11668,7570,2241,7566,2336,2238,5516,6401,5517,7545,2138,2270,5521,5522,5523,5524,2030,5526,7541,6984,3079,2134,5531,6224,12951,6226,7531,5536,6227,6986,7518,2130,5547,6987,5552,1976,7512,6988,7496,5563,1946,7494,5571,13370,1934,5580,7492,6239,1916,7481,2999,5596,1907,7466,1886,311,5602,1849,1865,13377,5614,5617,5621,6994,6248,7452,5632,5642,6426,1726,2014,5660,5661,5665,1204,5668,7427,6998,1652,5679,7415,1623,5685,6261,5689,1601,5693,5694,6262,5695,5697,6265,1528,6266,1986,9468,1587,2870,5727,6285,1576,5734,7004,2848,5737,1572,1545,1541,1534,9418,1536,5746,9417,5752,1530,5756,6281,1524,1508,1507,9388,5762,5764,6287,1492,2678,5098,5774,1444,12806,12824,9369,1399,9356,9353,6295,5801,5802,1377,13659,5808,5814,5815,7014,1361,6303,26613,6309,1334,1302,6318,16080,6321,7021,9311,1299,1292,1274,1268,9303,1260,26620,9296,7024,1831,7025,7027,1232,6348,1229,9273,6355,1222,6427,9259,1202,9251,6369,1170,6373,1161,9248,6379,6380,9243,12213,7034,1149,6400,6389,809,9225,9223,6402,1111,9213,1092,6407,6409,6428,1078,1077,9173,9171,9166,1049,6424,6518,6431,1639,6454,1041,26655,6439,7050,6443,6444,10659,1591,12335,6455,6458,8412,6466,1013,7067,7069,6481,962,6490,7057,8419,6493,7058,7059,947,16085,13829,929,7080,7062,6507,8424,13803,7063,886,6516,9832,856,9830,7410,6524,6538,810,6545,792,9792,6551,7079,6556,6557,7082,755,777,9471,736,9778,9777,1081,1073,6588,1272,735,1097,9769,729,7089,7090,26697,9757,703,6695,9244,6610,698,679,7092,9740,6622,628,6625,626,6631,6635,7097,6647,516,7098,583,594,8433,6654,6655,6659,571,6662,6664,6665,18026,9670,6668,527,9654,511,6675,6679,510,500,4824,6685,6690,10836,6694,495,8797,14003,7111,481,6702,6703,6704,9594,16089,13652,9592,6714,6718,6721,6724,6725,6727,472,6732,468,9515,6739,6740,7121,7122,7125,441,6744,6749,6751,6754,6757,6760,7416,440,433,6762,429,9106,6766,414,7132,409,406,403,387,6778,14950,7136,373,18442,367,356,6793,6794,344,6799,6806,7142,6820,6823,7146,317,10683,297,7164,5573,7184,8532,276,7279,262,7280,8928,7173,10545,7178,214,10211,7187,7190,8916,4682,7199,7200,7202,7298,7206,4759,7207,4497,7213,5105,4500,4216,18562,7225,8835,13330,8834,8831,7232,18747,8824,7241,7242,4511,8819,5027,7255,4517,7259,7261,4518,4520,8804,7422,7270,7275,8789,7284,7286,4525,7432,8781,7291,4529,7306,7313,7317,8764,14006,7328,4966,7337,7475,4535,4538,7417,7349,5110,7353,7355,7363,3618,2094,4548,7368,7370,2253,4552,30,4555,7379,7384,7385,7386,8728,8726,4561,3505,7391,4382,7395,7397,7398,4564,4230,7401,7403,40,8723,28,8618,7412,7414,7420,7418,4566,8716,8876,8705,7440,8702,7439,14240,7449,7450,4574,7490,7454,7456,7457,7458,7461,14144,7465,4580,7464,7469,7468,7472,7474,8688,207,7479,7482,3304,8888,8889,4591,7493,7636,4971,7499,7500,14329,8666,7585,7504,8653,7509,8895,3242,2867,7511,4603,9165,8646,7515,7516,7678,7519,7517,7521,7524,7525,7526,8901,8622,8902,8621,7532,4619,7534,7536,4620,8905,7538,8569,4623,8563,7542,4626,7544,7546,8541,2777,8909,7551,8910,4639,7564,7568,4641,8513,4642,7573,2742,7578,7580,8917,7610,260,7586,7587,4655,7593,7597,7598,7599,7600,7601,7604,5155,3453,2495,7613,8457,7614,7615,8437,7625,196,7628,7632,26815,7640,7637,11068,7641,16128,7652,7651,11062,26819,11060,7659,7662,26828,26829,7663,7668,2258,26831,7667,7672,7674,26832,26833,4686,7686,4691,7687,7690,4696,8944,11042,11038,2947,7700,8947,7704,11033,7707,11027,7712,7713,7715,14535,7716,7718,7724,784,7837,25,7738,11006,8963,2249,13547,7748,7751,4709,7754,10983,7757,171,7760,7761,7764,7765,7766,7767,7768,7769,7771,12803,4713,7778,7784,7788,7791,7794,7797,4054,7806,10759,7802,4722,26854,7813,14601,8985,7819,4726,7828,4729,7830,7835,7289,7836,7838,7839,7840,7843,7844,7845,7847,7848,7849,7850,7851,7853,7855,7858,10881,2729,7863,7867,3509,26871,8994,7876,7880,4732,5294,7883,7885,7891,1308,13378,7894,4733,7897,7902,7898,7900,7903,7904,7906,13551,10825,7912,4740,7914,1859,7920,9008,7921,7923,7925,16286,5145,7442,4750,7931,10781,7936,5316,4751,10769,7945,4760,7946,4762,7947,7949,7950,7952,7954,7955,7957,7958,7960,7962,7963,7964,7965,7967,9017,1881,5348,7979,7984,9019,10758,7989,7994,7995,4774,540,5357,8000,10752,7263,5363,4777,8010,8012,12,8014,4780,14333,8027,4781,8030,8031,8032,8037,8040,10738,4796,8046,8048,8049,4814,3006,8054,8055,8056,8059,8060,8093,8063,8065,4823,1057,1868,10723,1494,1459,1133,309,9054,10794,8092,4828,8094,10717,26931,8099,4840,10714,4843,4844,9062,12483,4846,8118,8120,8122,10798,8127,9065,1200,8133,10707,4856,9222,8135,8151,4860,8143,10702,10701,10700,8153,8160,5320,9072,4868,16282,8170,8169,8183,8182,8181,8180,8179,8187,8256,8186,8185,13905,8197,4156,8203,1720,8210,8218,8217,8224,13734,957,12791,5151,8233,4894,8237,4898,235,1050,8248,4902,9085,8255,8257,8263,8260,8269,8268,4907,10660,8277,9090,10656,1173,8286,9091,8291,9092,10654,4911,8300,9093,8304,10879,9094,9095,8312,1824,10648,10647,8316,4933,10646,8320,8321,10645,4942,8328,10644,9100,10643,8335,8330,8333,8332,10,8337,10483,5177,2239,1242,9102,17339,8347,8356,13843,4992,8366,14607,8377,9107,8379,9108,9230,8384,3085,4459,9123,8398,9179,10626,8397,10622,8407,9130,9131,10620,9132,8421,8428,8432,27031,514,9136,8438,10615,8449,8454,9258,9138,8456,8461,8459,1456,9141,8464,8467,8469,10610,8479,10841,8485,8483,1100,8493,1432,8496,8494,8499,8502,8508,5576,9150,3625,4297,8516,27083,8519,8522,9152,10557,8526,27086,8528,27092,8533,8540,8537,10544,8547,8551,2223,8554,10535,8556,2164,8561,2156,3555,10526,8601,8607,8610,8614,11586,3401,8634,131,8637,14175,27141,16202,5914,14343,10509,13552,10504,6342,3053,9199,2311,9200,146,9203,15028,27150,1030,9218,9217,16207,3475,10442,9221,2690,1431,14081,9235,10433,9242,9246,1672,11065,14252,1487,4090,1451,1463,9269,11,919,767,9274,9289,9283,9288,1011,1273,9291,9297,9304,9299,34,27185,9301,9306,5284,288,9314,9317,1807,15180,4478,27193,4380,4351,4233,4234,4232,2680,4231,2185,9355,9354,2062,3088,3244,3248,39,29,5688,3495,141,9382,2632,15124,16271,9400,10321,9401,9408,9411,2644,2289,2643,10302,1323,7006,3451,542,9438,14433,10917,4589,4693,10297,4757,9457,14190,545,4801,1017,896,9895,4803,9492,4988,9491,9498,4805,4806,4807,10225,9547,9545,4813,9550,4426,4815,9558,4386,5778,4875,4366,9573,9570,18692,27256,9361,4876,9588,4877,4314,10939,4881,9603,4888,4920,4228,5809,27262,9615,4171,9625,14670,4103,4924,9633,14422,9637,4925,10331,9646,4032,5849,4926,9648,4023,9651,4010,4927,10037,9396,10952,4002,14759,9669,4929,10011,3659,3656,9683,3644,9692,4930,9695,9694,9693,5022,9700,9707,9712,9711,3614,4939,9718,9723,14712,9727,4940,3595,9737,9738,3589,9746,25358,3572,27292,9753,4990,3566,9765,4994,3560,3552,16275,9779,12291,10130,5017,5019,5054,2064,12290,5035,5055,9814,3523,12282,9822,9454,5056,5057,2203,2459,5058,9462,3465,9836,5059,2781,9841,3457,9847,9852,794,9857,5060,12254,9861,2362,5061,2119,5172,9871,12242,12239,4923,5121,2812,9900,9899,10247,9902,10985,12227,9908,3400,12220,3382,5960,3379,9921,3373,12214,10989,9926,12212,9931,3331,5129,10180,9934,2660,12199,5130,10008,3324,10007,10013,184,323,5131,10995,10023,10027,1028,10032,1025,14411,10040,10039,5170,106,10050,10054,5175,2307,2240,11002,5186,10071,5178,5984,10077,2245,10234,162,15750,97,12136,5093,15746,148,10099,10106,15079,212,10114,5266,5297,5290,2019,10129,5296,12117,14946,46,10153,5742,4972,5222,10159,2917,12094,2915,2887,4376,2884,5406,10182,2859,5407,10188,10187,10189,12068,2494,5408,9581,12066,1,2795,6076,246,10212,10209,228,254,2783,281,5796,998,283,2759,18680,307,103,395,469,432,5810,452,478,5252,426,12036,6663,2600,425,453,672,407,8790,791,585,1018,419,532,2731,915,901,1071,10274,2512,10280,12027,554,10283,971,1033,1066,1117,2302,2715,12019,257,10299,2709,1053,1008,1044,832,10308,1039,10313,1015,5273,648,968,2291,520,820,10344,667,2694,13325,1350,10367,10379,11999,11053,1083,2271,10391,5301,11977,961,10394,4176,1228,1353,980,796,10410,10085,1674,10423,10427,1376,1476,1778,14203,1727,1805,4040,2268,1788,5314,1406,10459,2675,11067,1779,4031,1827,10474,1315,15128,10480,5323,1687,15798,4018,1740,892,813,819,893,2108,2208,10513,2210,2265,2298,1900,10523,3663,15976,2236,11077,2005,2195,2550,817,2211,16344,11945,1851,10543,11086,11085,2667,2439,10550,10555,2137,2522,10561,2058,5356,2691,2503,2668,10577,11091,10581,2049,10580,1765,814,1054,11118,2794,11122,11121,55,11125,2800,12106,5366,2826,16358,2036,11139,932,3609,2914,2864,5369,2105,16272,12210,2050,5104,2846,11161,11160,11166,14842,11171,11169,3025,11174,11173,178,11178,3021,9747,9749,16367,3092,3115,3225,3190,9758,3178,3041,5384,3270,3159,11216,3305,3152,3361,3245,3367,2266,12221,2547,1398,16376,3234,16377,16051,3163,9773,3428,3058,11257,3539,11261,16084,16384,17175,3423,11815,2486,11274,3515,1760,11291,11290,3616,16368,3624,4280,11805,120,4167,4006,9782,3577,4130,2384,3592,5422,16405,4192,11796,11791,4267,3544,9744,11348,11346,4243,9913,11779,4193,4365,4368,4375,11370,4162,4390,118,11411,7106,11399,4572,11406,12285,555,27482,27483,4468,479,16433,393,2292,11425,4277,11750,5205,12278,14410,11444,2070,9824,4507,4308,11451,11455,4532,9748,11460,11459,4505,11473,11472,11471,1992,4373,3461,4659,4610,11488,11708,11491,4745,91,4950,11499,15742,5053,11702,5078,5169,4346,14709,11525,4789,9750,11535,9855,11542,11541,4862,2528,4864,27525,11571,9870,16456,5291,9745,3419,5026,5378,11603,11602,5439,9887,11619,11616,12234,5063,11625,16462,4565,16463,5496,9752,9754,5484,11663,11662,9755,11667,11666,11665,11626,9756,11671,1728,5470,5953,9915,11691,5634,5653,4670,11707,11706,11608,11713,6347,2482,5680,16531,5455,5533,11736,11743,11742,12215,11749,5929,11753,11751,11768,11587,5507,5701,11207,5786,3450,5817,12209,11776,11775,11774,11773,6063,11790,11789,11795,11794,11793,11792,5267,5913,5978,225,11806,16546,6087,182,6044,11822,5806,5922,11579,10020,11856,11851,6046,6156,6176,11885,6085,11888,11887,6423,5535,10043,11951,6138,6158,27555,20,6247,11929,6249,11540,11931,6148,6245,180,6330,2215,11953,11523,6712,11522,5554,6523,6425,143,5557,6144,14616,6292,27588,14653,12012,12023,6378,12035,6632,6539,6735,6183,12067,6824,852,1329,12114,6410,12118,12116,12122,6590,12139,715,6521,6738,11497,12152,6809,6584,12160,6814,12167,12172,12181,16266,1343,6856,6902,6903,27625,7019,7031,7038,6029,7055,7008,12217,12226,7128,16309,10094,6807,92,6037,10104,6957,799,12257,12256,12264,12263,12262,7003,7483,123,2782,2,3397,12288,12292,12293,4439,12307,994,2627,2237,12312,12314,4170,12321,7467,12326,7463,12337,2306,12347,12345,2087,12352,12350,1284,2037,12377,8144,6526,1846,11438,7582,2086,7583,269,2186,3478,12429,7792,16651,12446,7866,12444,12451,12450,12460,7943,16672,12474,12472,248,8206,8211,617,3562,2080,2841,16656,1007,7540,7453,217,11420,12567,7732,2534,7809,12587,12593,53,7941,12608,12607,12612,7993,8029,63,3043,1517,107,7818,1829,2294,8083,16666,10128,12675,12673,12672,12677,12684,12683,12689,1871,7942,12693,12692,12691,1844,7980,12738,3310,8082,5214,2658,8137,1042,1219,1770,1447,1182,8162,12789,8165,1189,8166,12796,16689,11410,8167,8173,1840,1901,7826,10096,12809,12811,238,16692,421,10184,2045,16400,12832,1426,1137,16697,8154,1120,8129,8313,7336,8194,967,8232,8249,27877,8251,8191,8270,1615,2479,2462,27900,8299,27926,8301,8302,8303,1454,16748,8305,959,1563,8306,12967,12966,2997,8288,11402,8212,8325,13048,8283,1962,15993,8385,1178,8386,13042,16754,8388,8390,8391,8393,3257,8395,1383,8394,9853,9856,1341,1927,13332,2772,7999,8334,17576,70,16761,8382,8353,8427,3238,15121,8196,8399,13371,8430,8364,1860,8434,8142,222,8445,2048,8446,969,1035,1887,8361,1397,8455,75,8500,1197,8506,13458,975,8548,8278,8633,13472,28084,652,16448,1691,8568,28105,2060,2804,2170,8491,8615,13554,7899,1483,2739,4452,8517,8579,2161,8631,8640,8665,8667,8668,13591,8671,4423,14707,4420,13622,8818,8701,11382,1163,992,7367,13657,4384,985,13664,8486,17938,8605,8721,17953,8731,8740,924,4330,15425,8755,4316,2213,18041,13742,18058,8788,8854,16850,8900,13774,8865,8986,13779,8124,4238,2034,2013,2365,8823,8852,4191,1558,18132,8138,851,18136,8827,8965,4153,4136,4024,13844,4020,2941,11364,4124,8934,2123,2009,13883,18222,2345,4099,9003,9012,9016,1960,9039,13904,4080,2840,4076,18265,205,9011,11361,9073,18342,9078,18345,2446,18367,14001,10055,4011,10057,10059,10060,1993,1967,18392,8948,18402,16886,11349,9075,16887,1806,18440,8844,8927,2175,3613,3612,1937,3594,8970,8549,9148,14082,3564,7246,610,1876,7250,3528,9181,16896,18574,14124,14201,9197,592,9227,3474,14133,14137,18619,3458,8429,18647,9022,1922,9224,498,9254,3425,3412,8939,14192,3411,8145,18714,16907,14197,5684,3403,18738,16909,18760,3391,5698,9337,2465,16912,18774,420,3383,14253,14251,14254,14259,10371,9389,9390,18807,14266,8602,416,9429,9502,7630,18863,9190,18887,18900,16926,14349,9435,9478,14365,9479,9481,19176,9482,19179,9885,8742,19188,2069,14402,5750,16945,19201,2039,9490,9517,9543,9321,5307,9818,8857,2023,19223,5765,28197,14479,2730,9579,11299,19258,19264,19267,14500,19269,9628,2616,8369,2424,9465,19304,1893,9381,397,5795,9668,9671,16953,9662,2006,14546,1640,1389,223,16957,14561,19334,16958,1621,9412,9451,9714,14598,1147,9667,11289,9690,9770,9787,19372,16973,1872,1016,995,16975,9713,19393,353,9838,10454,9183,9851,15903,351,515,14847,26331,1950,9647,9925,9875,9928,28241,28244,337,14758,28248,14773,19497,5281,1918,17007,11268,4510,17008,4521,5917,11271,14840,17011,298,14887,19565,4540,14896,14898,14948,19583,4622,14957,14956,4649,1713,10519,15022,16825,4672,1176,4710,4503,15071,15076,4504,15084,17038,19625,4508,4837,4509,15132,15142,8297,11025,15175,4882,1594,16364,1588,15209,17059,19663,4522,17066,4530,4951,3662,6143,4440,4531,4223,17016,16038,19695,4447,15553,6050,15561,17086,17070,4959,17165,1217,15586,2056,15632,4539,15635,4986,1127,1957,15899,15677,4545,15688,6084,607,15736,5016,10582,4558,5032,15753,19773,15756,5051,5077,252,17106,1174,15801,4567,4688,1072,6117,5152,1461,5180,5219,1624,15851,17120,5223,3648,15859,5321,15858,15869,17122,15896,782,4576,5257,19834,19835,16357,15962,4577,716,19869,1227,15977,4582,17133,19873,5360,5364,11144,5368,4719,4584,6808,19900,16036,16041,5424,16043,5432,18142,5450,17169,5463,14663,17172,11863,5502,17182,6188,17193,19919,4586,4594,5562,17233,6209,17241,1364,5575,4596,11849,6215,17249,1095,4601,17274,772,5598,17297,17301,17308,6234,6241,4604,5615,17323,5341,5350,5633,625,6259,17353,17356,5672,19999,5673,17406,482,94,4611,17417,4614,1395,25294,5676,17431,4615,4617,11123,5704,4618,1991,4628,4630,1646,20021,17505,4635,17512,4636,5733,243,1065,17545,17535,5748,6308,4645,17561,1064,17575,17580,17584,5780,11823,17586,17591,5875,5787,17596,17748,4651,4652,742,5797,1908,6331,17592,20071,6335,20079,16119,8710,4662,4664,4665,1253,17750,5857,16134,6352,16285,17769,6358,803,17776,4673,26329,5355,4675,6360,5920,272,6367,17812,17817,4679,6374,4683,17835,5938,17844,5940,6385,5954,16346,17878,6399,17882,11809,5971,5981,1537,17892,4699,4701,17932,4703,11217,4707,17942,17952,11211,4712,4716,23,11202,17974,17977,4724,11181,6437,4730,1971,16401,18001,6449,1861,6452,11172,4737,6457,18028,11798,1852,11167,6461,4742,4743,11163,11162,6469,11158,4747,2055,4748,11155,2112,18065,5359,18073,18074,663,11152,11151,11148,18084,18091,1888,17570,11141,18093,1243,11138,11136,18106,4766,6503,18105,4768,18113,1270,18121,11126,4771,11119,6515,11115,11114,18137,11110,427,11108,11106,11100,18153,11098,1474,11095,11093,6543,26347,4776,11084,6558,4782,1662,6578,25467,6581,18196,6587,25260,241,18214,6593,6595,4798,17623,4809,18215,18220,6605,4811,18235,4812,4816,16408,6857,4817,6627,26807,2257,18259,18283,20144,6656,4827,18309,4829,18289,18286,4833,18288,13776,18310,4834,4836,18318,6682,18040,6680,4842,18340,4847,6697,13739,4852,2079,18361,6731,25524,6736,20150,6747,6752,18398,13714,6759,6781,4857,6790,18418,6798,6800,18441,13660,6830,156,4867,18481,14068,4871,125,6847,18466,4873,18476,13621,18494,10067,18500,6899,16442,108,20698,18535,4885,11480,4886,6938,18560,6946,18557,4890,18573,6974,20699,11725,13546,4901,19542,2031,1975,4913,4910,1965,1964,18652,5453,4914,25511,18661,7028,4916,18669,18681,13499,18674,17136,4918,4922,18687,7044,18704,1721,18709,7061,1504,13463,18707,4937,4938,7078,18727,18733,7109,7112,751,14480,25220,26818,1125,7129,1935,18790,752,7150,18781,1269,7157,18799,18805,26820,18809,7183,18825,13376,18829,18833,21436,21437,18862,7231,9893,7233,18846,2584,7252,10089,10072,13336,4389,3028,14892,18865,18867,10140,18869,18874,18875,18876,18878,26825,17574,18883,18885,1848,18890,10203,18891,18898,10223,18902,18903,7330,20506,13047,7334,18923,7338,18924,19173,7218,19178,4956,19234,19181,20596,13034,7239,7361,7235,7366,4367,7256,7371,7378,7383,9626,7393,7394,19227,7396,7404,4352,4340,10257,9786,18221,2103,4953,4955,7281,4960,651,646,12965,4962,5466,644,638,4967,4975,4977,4978,15048,4980,199,4982,4984,12929,4987,4989,10111,4991,4997,4998,20619,25623,5000,1497,1496,5003,1421,1384,12891,5012,7314,5011,1339,12887,1327,1310,690,5013,5018,5021,20624,5036,25203,6487,5038,25202,5045,5052,10139,5062,1513,1434,1433,1775,12850,5065,5068,5070,20625,5074,5079,5082,5083,920,286,5085,5091,5095,20637,5097,6649,12827,5102,5106,5107,25652,5109,7372,5113,5115,7421,282,10549,3380,27683,5134,5135,5137,54,195,20641,5138,5144,10720,169,181,20644,5146,12790,4727,5158,5157,5159,25667,5168,10107,2159,2152,10490,5495,2770,2481,4936,5182,5185,7485,2445,114,5193,10463,5191,5192,10554,5194,101,1874,5195,5197,5199,12419,5200,5201,5203,5207,5208,88,45,129,5211,5213,5215,20697,5217,5227,12690,5226,7569,5232,5234,5231,12670,2230,2745,5237,2722,12663,5241,19629,3481,25582,5242,5243,4739,5245,47,4021,1087,20668,1021,18356,3568,2602,5253,4034,1293,7647,918,5258,5034,5263,12582,5268,5269,1055,1945,12570,5270,5272,12560,5278,5280,7697,4284,5285,5044,117,5300,12540,5302,20696,5305,5309,1342,5317,1443,3520,20701,1742,7685,2216,2645,2776,12452,5326,7750,18423,12445,5335,5331,152,186,5338,7749,4430,5351,7745,1063,3459,8354,5352,5358,6319,12413,2903,5361,5362,7803,8401,5365,5367,5370,5371,12384,5372,5373,5374,5375,18467,5064,7814,2773,60,27142,12369,5385,5386,5388,2117,81,5390,25436,3542,18083,7787,5393,5399,26328,5396,5397,5398,5401,12343,5402,5405,2950,20739,2235,12340,5411,12338,5412,5413,12334,4608,5414,2261,7865,737,20744,7693,20757,5415,18590,4275,5420,5423,7800,19930,5066,2958,5425,5426,6970,5429,7861,12313,5433,5431,5435,4799,5436,5437,5438,7911,5442,5440,5441,5443,7968,20761,5444,5447,25066,7928,5448,7975,5452,5454,25063,25062,25061,19969,5456,25059,7992,2967,20768,5465,25056,5468,18801,8004,5472,5476,5478,5480,15033,20771,5481,5520,7969,15021,8011,18482,5490,5491,18606,8035,5492,5494,5498,5497,5500,7879,5504,4702,7927,8081,5506,8088,1574,4073,1401,5510,5513,5515,25410,18712,5518,5519,5525,5527,11875,14958,5537,8136,8076,5538,8131,5544,18527,5546,5542,5550,5548,5555,5556,5558,2998,5560,5559,8115,5561,5565,5568,18126,5570,5572,5574,1546,8168,5577,7001,5578,8084,18563,5581,5590,5592,7048,5597,2925,7924,8146,11903,8241,5613,5644,5619,14833,5624,18734,8220,5626,5627,18179,11911,20834,5636,5640,2649,8279,5646,3086,5650,5651,5659,14810,20842,5663,5666,18794,18841,14803,8329,8289,8281,5682,5683,5687,5690,8319,5691,5692,5696,5699,26164,5700,20645,5702,3496,8363,5708,5711,5712,5716,5718,5719,8413,5721,5725,5726,5729,5740,5735,5739,5749,3526,5755,5753,5757,5761,5766,5769,5767,8470,5770,5771,8492,8442,5773,5775,5777,5779,5782,8463,5783,5784,5785,20742,5788,18828,5790,5792,14691,5798,8531,5799,5804,5811,8523,5812,4985,5813,8550,5819,5820,5824,5825,5847,5832,20782,8559,5854,5864,8530,5871,4342,5879,3573,5881,20805,5883,25365,3351,18848,4590,4543,8396,5904,8578,4003,5918,14611,20833,5924,5927,8552,20845,5930,5933,5942,5939,5941,8484,5944,5949,5950,5956,5957,5959,14571,1105,5966,7318,5968,5970,10150,5974,5973,5977,5980,5983,3550,20884,5985,14543,20885,16969,5991,5992,14537,5997,5993,14533,895,8670,8529,6008,14523,6015,5188,14524,8690,6022,8357,3399,8524,6043,6028,6030,20977,6033,2966,6034,8687,6038,6040,5189,6045,8651,6051,21470,8838,6054,6055,6056,21086,6066,6067,6071,21096,6077,6082,6089,6088,6093,6092,6095,6094,4804,6096,8882,14473,19524,8930,20940,6100,6103,6109,6115,8886,6122,6118,8973,6127,6131,6129,8977,6133,4808,20960,8221,6142,6146,6150,6155,6154,8938,8849,25972,6160,26144,6163,6162,4800,9124,6178,6180,9098,6181,6194,6195,6197,6201,20976,9083,6208,9020,4928,6214,6222,25991,9177,6223,6228,20999,6229,9191,21196,21169,6236,6235,9201,9253,6254,6253,6258,6257,6263,6267,6264,6270,15908,6271,21206,9263,6276,6277,6280,6284,6288,3601,9185,6290,6296,6294,6297,8821,9325,6300,14397,9292,4932,6301,6304,21047,3187,6310,7510,16035,9398,9414,21062,6314,6316,9410,6326,6324,21072,6323,16068,25276,6328,6338,6337,6351,6350,1532,6359,6357,6356,6362,8898,3333,6370,6364,6363,21095,6366,6372,9500,4948,17808,9508,6386,6383,9511,9514,9489,6397,9552,6403,9509,2765,6405,14338,3126,4964,6412,9568,6415,14336,6416,21138,25267,4996,16164,2956,6418,9551,21432,21433,6420,6421,21101,6430,2923,2916,6433,6438,6441,6447,6450,11494,26189,6460,26546,6462,6465,6473,6470,2862,6474,26227,2854,6480,25435,9645,6488,6491,6932,6492,6495,20970,6613,6497,6498,6501,6502,6506,14321,6504,6510,26549,6519,6522,5033,25091,6529,6528,6537,26327,6531,25493,11487,6542,6541,6546,20850,6547,2818,2816,2788,6550,18556,6552,6555,26354,6572,12191,18605,6576,6580,12194,6583,6586,6585,6594,6596,16269,6598,6600,27032,14262,6602,21211,5067,6608,6606,13039,25541,27054,20752,6615,21213,6620,20740,6621,21217,2747,6624,21227,2741,2737,9698,21230,2727,6630,21233,203,6633,6650,6660,6667,18926,6672,20655,6676,20648,25209,6684,26504,25617,6683,5118,20634,26528,6689,6692,20626,2669,2653,5206,6698,6699,6709,20620,2637,2630,6726,6716,6719,26568,19324,2628,21292,2624,2596,6743,6737,16283,6750,6753,6761,6756,6769,6773,6763,6775,6771,2577,2545,19396,6777,12231,6782,21309,6786,6791,5120,6797,21328,20095,6818,6831,6838,6834,6846,6843,6855,16061,20047,6871,6883,25168,6887,6897,6894,2471,2385,6914,5124,25148,19594,9604,5127,26743,6920,6925,9709,6924,6927,6928,19627,26763,6940,26849,2370,2355,19906,6964,6966,6968,2347,6972,26941,26824,6982,6981,6996,27,26830,19874,3148,19872,21155,19868,19870,2297,2267,2246,21434,19854,26851,7009,10118,7013,7011,21435,21438,7032,7030,7039,7040,7042,7051,7052,7065,7068,2160,2169,7159,7088,7099,19890,7113,7114,19726,9701,2784,90,7119,7130,19701,7135,7143,7145,2075,27024,20023,2068,15,7158,2040,1988,1972,25826,7162,7167,25086,7169,10194,25054,25055,25057,1958,25058,7181,25060,25064,25065,25026,7189,7194,19574,7204,5128,7217,14218,7214,7219,84,7224,7222,27135,7227,19536,7236,19516,2429,19502,1730,3491,1734,19479,25123,19463,21504,1719,7254,1683,1704,20649,7269,20618,19416,7273,7277,7276,20669,27243,7292,7294,1599,7300,7304,21471,1592,7312,7316,1589,19335,7321,7327,19278,7333,20743,25179,7344,7347,25885,20772,21465,7364,25195,19205,25204,19195,7399,20824,1525,19184,7405,9835,9622,4455,20859,14198,7616,4470,9821,14196,4392,7670,14187,9868,4290,3667,9881,7684,3630,7723,14141,14140,7491,14136,7489,25217,4184,4177,25223,4168,25226,9911,1266,4150,9920,2226,14076,4062,9935,7741,25233,3532,20138,82,3456,3467,3308,3347,3329,8227,5132,6448,5133,16,13968,9889,3120,13962,27633,138,10056,10012,10049,7805,27682,20005,5174,26244,7365,20016,159,4161,211,16558,26826,2460,10093,21289,3455,10095,3033,4033,10100,2188,274,19965,2120,16653,21267,86,2995,16374,2918,7829,16366,9613,10201,2008,27830,27833,2505,2597,27879,27843,5119,21081,16220,7872,16212,16205,10177,16201,4765,8222,27886,16161,16182,10191,16181,16168,7881,21424,16158,16153,16154,7893,16150,27920,5166,16129,5167,16127,10311,10296,10235,1037,21456,16106,10362,1763,1746,1218,28142,28002,28000,28004,5114,7934,16069,28033,16047,16044,1122,1318,28067,7940,1481,5225,17337,15964,28089,7926,10428,10431,7817,7933,10445,7978,10450,3541,20978,15901,1696,10457,7796,15864,15843,1473,10157,7917,28190,10516,5249,1358,13,15764,7319,10432,1864,15744,15741,15692,15682,27038,898,27310,15577,27278,15562,15516,27084,15510,15505,26594,15427,7198,12848,1214,865,25755,96,15215,1555,16402,15135,16403,26816,15080,17828,960,17814,1138,17758,17756,17724,12930,17654,17632,17608,17607,17563,858,12952,17525,17511,1201,17488,3,17439,17424,7195,470,15967,17303,17302,2065,688,3035,17283,1671,2953,17276,2011,17646,26149,26137,48,200,16756,14,17209,17205,305,16529,26080,2018,17171,17137,17128,17103,17097,17088,17039,17021,16993,966,16959,4053,287,16643,2212,25897,16920,25877,16913,25874,16866,16863,16862,25857,16853,16760,25806,13438,25726,16664,16641,13369,972,16601,25716,16602,897,99,568,2725,5089,25636,993,25608,4435,25544,4479,7991,5311,7986,4461,5324,4396,7869,8007,8005,8019,10618,8008,7730,4465,8017,1020,5344,7673,4448,7948,7910,5108,8068,10662,8079,5427,10734,5340,5469,4437,5479,5487,8047,8090,8071,3291,7890,8102,8097,5471,8073,8021,4903,7935,8117,5534,8114,8128,5539,5543,8126,8152,5279,4671,13649,8148,5584,5594,3452,8158,5588,7977,5475,17629,8164,8175,4381,4349,8200,8242,8240,8226,8293,8271,4336,8310,8264,8315,8327,8265,8276,7938,8338,8376,8326,8016,17351,8387,8389,8420,17963,8426,8436,8462,8468,8448,8471,17930,8498,8565,4327,6711,8545,8472,17791,6091,8085,5869,8560,8573,4299,8612,4296,8630,4294,8600,17979,8650,4289,8682,8678,8629,8660,8715,8692,4266,8150,8776,8525,8745,6102,4245,8800,675,4242,8737,17891,8535,8802,8911,8847,8935,8828,8239,8893,8891,8862,8990,8846,8989,9027,8747,8913,4194,9079,9184,9206,9209,9161,4166,9231,9241,9233,5076,3263,9271,9286,5604,9033,18187,18156,18172,9333,8822,9047,9280,9376,9404,18128,4114,9364,9458,18173,9480,9488,9262,9385,4106,1032,9472,6422,4096,18161,4093,9614,9557,9632,9583,9636,4087,9640,9644,9673,13915,4064,9687,9704,9655,18331,3261,4050,9720,4044,9721,9764,4042,4017,18343,2202,14002,3635,18741,3632,9742,9776,2952,9772,9784,9780,1420,9774,9771,18433,9699,9800,9656,9798,3626,9710,18474,9565,9867,9866,9907,9914,18498,9927,9883,3605,9310,10022,9891,10058,10018,10014,10216,3540,18511,10248,3535,3534,10305,10091,3494,10208,10113,10121,18565,19214,3483,10168,8718,10229,1152,9912,3473,10253,660,3463,10115,3444,10295,3429,14179,11331,3404,3402,18743,12143,3355,3289,3285,8171,3252,3186,3158,3141,3117,14355,14364,14367,3105,3098,3099,3074,3068,2981,2963,2957,2942,2927,2833,2801,2755,2744,14485,2734,14481,2685,2674,15900,2647,7228,16950,2361,1834,1667,1417,1221,1159,1116,8163,1048,8156,11801,7577,6935,6936,4407,19199,831,818,722,480,476,19235,19272,14888,19230,402,8106,352,377,321,314,270,19270,19320,255,4494,4498,4523,14848,4524,19555,19554,4528,14891,19452,4573,12660,14939,4588,4621,271,14961,4631,7688,4656,4663,4667,4499,4690,5964,4721,4734,4779,4783,16955,4854,4870,4893,4905,4906,4909,15407,4307,4211,4140,4132,15513,4477,4434,3426,15575,4961,17005,4983,6068,15668,6078,11228,3138,4559,17102,5049,4560,5088,5092,5126,5246,5261,5289,5303,5308,5312,5325,19879,4583,18892,5377,16045,4585,17310,5461,17174,5514,5528,5532,5540,5545,5567,5569,5579,4598,5585,17610,5595,5599,5601,5608,5610,5611,5623,17333,4606,5635,5637,5639,5643,5645,5652,5669,4609,5674,10206,5675,12900,5678,5681,5686,5707,5717,5720,5722,5730,5731,5738,5736,5741,12897,5751,5754,17513,5759,5763,5781,4648,5793,5803,5805,5807,5816,5822,5830,17594,5852,5853,5868,5873,5882,5894,4668,2912,5899,5903,3354,5926,4678,5932,19817,5934,5936,5943,4684,5958,4338,5961,19828,4685,5986,5008,19823,4403,6440,16891,16203,10131,6472,13333,18864,4753,4755,4763,13328,20137,6609,4767,6509,4770,4772,5009,6941,11089,18165,6549,6573,4792,4795,13845,6591,6597,4810,6607,18226,18229,18253,6626,5015,19730,6651,5024,19713,13778,13777,6671,19731,4848,18044,6688,4850,6722,7267,6745,6741,10127,6758,6767,6772,6776,6788,4661,6801,6803,6817,4865,6842,6865,6878,17653,4880,17656,6916,18558,6933,8867,3639,19568,13556,4897,6990,6995,6993,4908,7016,9071,7033,7045,4949,7100,7102,4485,9234,8044,4422,13394,4226,4483,13384,9631,4458,147,7171,19297,5998,6005,6007,6010,7441,6018,6019,6026,10525,6036,6042,4405,7476,6145,6141,6130,7523,4278,10695,7533,145,6119,6116,6110,6106,4112,4081,6081,6075,7642,6256,10686,3651,7698,6251,6252,7736,6250,6246,6244,6242,10326,6238,6232,6230,6225,6217,6216,6213,6211,6210,6207,6206,18872,7982,7997,11244,6196,10703,10435,6184,10765,6175,3250,6177,3224,6171,6170,6164,6161,3341,6157,6340,5859,6353,6349,6346,6345,6344,6333,6327,6325,6320,6317,6307,3627,3111,6305,6302,6299,6291,6283,6279,6278,6275,7390,6274,2349,6272,6269,7402,7380,7375,7374,7360,7352,7343,7320,7322,7315,7303,7290,6508,7285,7283,7282,7274,7272,3136,7268,7264,7260,3083,7245,7240,7221,7220,7205,7191,7185,7174,7170,7165,7163,7151,7148,7140,7138,10893,10947,7131,7116,7101,7091,7053,7046,7035,7020,7017,6999,6985,6956,6975,6967,6960,6948,6947,6945,6931,6929,6923,6921,6917,6915,6913,6873,6908,6906,6891,6881,6880,6858,6836,6828,6827,10621,6816,6815,6810,6804,11149,6854,5912,6784,6764,6715,8686,6706,6733,6728,6705,6696,6554,6691,10736,6681,6868,6869,6634,6623,6874,6612,6611,6603,6876,6579,6575,6559,6544,6533,6527,6520,6514,4758,6500,6496,6489,5975,6484,6482,6478,6464,17055,6884,6459,6456,2779,11569,6442,5989,17069,5990,6888,6429,6396,6404,6392,6895,4899,6898,6025,8422,8405,8392,8381,8380,8365,11159,4963,5040,8023,8020,4292,2723,4958,8025,11544,8018,19265,4311,19192,10312,18162,7348,7331,5041,10422,9157,5160,5165,7507,10314,5221,18370,6730,7648,7664,5304,5306,7703]
    overseer = Overseer.find_by_email('devang.shah@bulkmro.com')

    Inquiry.where(inquiry_number: inquiries).update_all(outside_sales_owner_id: overseer.id)
    [inquiries.count, Inquiry.where(inquiry_number: inquiries).count]
  end


  def set_sales_manager_for_inquiries
    inquiries = [1515,1491,6001,155,10641,894,1882,7411,187,7983,4835,38,7423,64,1244,7981,763,1108,1331,624,798,58,1989,391,1618,7971,3530,25434,2180,1424,7556,2834,1575,7436,1941,41,7438,1488,3617,1477,1060,1061,7447,10470,1234,7537,765,6027,2423,7459,33,3553,183,102,57,10539,1320,163,1238,611,7473,6047,1184,7892,508,1387,6953,7480,7477,7484,318,2221,3611,4872,3514,7860,2590,1415,4348,1596,1052,7831,95,7503,7505,21312,7824,4324,1650,6139,7815,7812,6958,6137,7810,6132,2798,7804,6128,56,62,119,6124,7798,4220,76,4204,4196,7549,7552,2024,523,849,2022,1347,2029,7777,2007,226,7561,1311,4178,1336,1307,133,1396,7762,7575,4148,7576,25281,881,2102,7756,2061,7584,7588,6101,1303,25495,1070,6098,4104,2001,25496,1917,1915,1929,1923,7744,1773,6090,1278,1995,1895,4912,1862,1931,1009,4083,1642,4981,1267,1255,999,350,25513,7742,7729,1889,7618,7620,4079,25514,7626,7623,4072,4068,7726,1248,25292,4063,2051,7725,4051,1237,7714,1246,25517,1987,3169,424,1245,1724,4028,1665,1568,1566,1565,1570,2043,732,130,7696,1162,4026,7646,7650,7666,7675,1158,1134,746,7679,4013,7680,1172,77,1115,1074,2002,7758,6971,3664,7689,1486,7656,5161,10690,1196,7645,801,606,289,1579,6973,1485,10713,931,229,7629,173,160,5204,175,3638,110,109,140,136,7624,2338,7606,2033,7710,2015,623,10363,250,1119,684,1586,1649,903,7595,3607,3604,7731,1919,5459,1869,5210,3598,1499,100,3596,230,1285,1280,1261,868,1286,7589,7739,847,236,1940,834,218,1038,632,10708,3582,6980,1519,1511,1905,1523,1024,1313,3567,1493,7746,7563,1312,1306,1540,633,1560,1480,943,7747,733,5334,1573,1010,2090,2010,872,2101,1402,1381,1578,1452,1146,1129,949,249,1374,201,193,50,7560,821,7554,158,7763,25314,115,6983,7770,9600,3531,43,3529,3073,6826,7776,25583,7539,6240,2166,2760,3513,2163,5823,3498,7535,7782,7786,7530,2151,25318,7528,3488,61,800,7522,740,3486,569,7799,3480,714,707,665,484,7513,32,268,5467,3466,294,6390,7816,3460,253,3447,25319,7508,7825,116,3433,25320,7501,1034,3418,1096,3416,7842,859,2611,7495,122,7854,1385,301,112,6829,25618,3587,2430,2902,7862,51,21,730,3395,7877,7487,124,2543,166,6991,486,5831,89,2335,2174,766,6629,7888,204,7895,25335,7901,7907,2469,2682,2728,7470,1974,7916,2118,7922,7460,25345,6202,434,2718,6832,2716,3556,6199,10748,3468,7951,2711,2704,2052,6833,2705,7959,7448,2614,2699,2700,2099,2746,2697,7974,151,22,2693,346,149,970,127,98,1512,137,25649,2217,3548,2328,194,5474,144,1675,2315,2097,5622,2520,19,7437,3590,25663,8673,2687,2431,7435,7431,2187,285,267,4495,1000,1710,7425,104,3344,7424,3330,405,8038,6381,21332,3360,3359,3358,4506,150,661,588,2082,19814,113,2428,4512,2686,2613,26898,4515,2676,2683,8057,8061,2539,2438,2670,8064,2143,8072,3302,4526,1932,220,4544,4550,7408,8075,2665,2662,4831,2663,3282,25708,3295,8080,8086,3294,5848,7002,4551,4554,8091,6835,9442,8095,4377,25718,4562,4568,9437,5850,4570,2838,4315,2618,4301,4306,2843,9427,9409,3228,8108,9405,4271,6172,4256,2601,4251,9397,2595,3221,4215,2585,2587,6169,4209,2579,6168,6167,4945,4195,2573,2574,18917,4180,2568,7010,2557,2563,2549,6159,25756,4147,2556,4118,6151,12740,6354,9373,2541,4098,6839,2533,4088,2530,2518,1885,2525,2516,10448,4067,4065,2509,2732,2510,4045,4043,2498,3162,3135,25368,4030,2474,25758,6339,4027,2490,6329,19630,9345,4012,2477,2480,2476,6322,4008,9316,6315,4001,2463,6840,27073,2442,3637,2434,2435,7023,3113,9293,6306,2409,2421,3606,2388,3599,9268,6298,5865,6286,3585,6282,6368,3580,3581,2368,9250,2364,3571,3565,3563,2363,25788,25790,3558,3557,3547,25791,3545,3097,2358,2356,2360,7036,2354,6273,9216,3524,9205,3519,25384,3510,5872,2334,3493,2320,2333,25812,3487,2318,9167,2319,25816,2313,3485,2317,7047,2310,4946,2304,2301,3462,9143,2299,25828,5618,3089,3081,7362,3449,7049,2288,3443,5876,4965,3075,2281,3437,3436,3430,3070,3434,2274,3421,2269,7351,2264,7346,3413,7056,5877,2262,3064,2250,3048,5878,3392,7326,3374,3368,3362,3363,25393,2231,3349,2224,25846,3185,2227,6844,2218,3328,2209,3313,3296,2201,7064,3298,7066,3288,7301,2199,7293,1430,3251,2198,2191,3226,9802,6845,25871,6560,6571,2178,2177,7083,3175,7084,3165,2168,3157,3032,2165,2167,5884,2150,25895,3108,6604,5893,2145,2139,3005,3087,9743,7257,2133,2127,3000,2122,2126,3060,2115,2109,2113,1175,9697,7243,2978,2104,2096,5896,2948,2940,2085,7103,2943,7104,2934,2078,7234,7230,2073,2072,2930,25928,7229,2920,9634,5667,2895,7108,2067,7215,2900,2898,2882,2883,2877,2057,2021,2878,2868,2047,6707,2038,7209,9593,2857,2851,7203,2003,2000,2844,2835,1996,2837,1994,6734,2825,7120,1985,7175,7126,1984,2808,1981,1980,7168,2792,7166,1955,1959,1952,1933,1939,1930,1912,1903,1867,1884,7160,25959,7156,1845,1854,6774,25539,25962,7153,3645,2962,1708,1693,1681,6391,1697,5141,1666,1660,1654,6406,1673,1644,1643,1641,6414,1647,1628,1636,1625,6436,1638,1608,1606,1605,6486,1609,6783,1598,6789,7144,1600,7139,27475,1583,1549,6849,1559,1542,1538,7137,7133,1535,1533,1529,1527,7127,1514,6805,6499,1518,1509,1495,6534,1500,1490,1479,1275,9007,1469,1458,1445,6536,1471,1442,1438,1436,7110,1414,1413,1411,1408,6589,1390,1394,1386,1382,6617,1393,1362,9901,1354,7105,1346,7096,7095,1322,6618,1332,1326,1305,1319,7085,1301,1298,1296,1283,6636,1277,7060,7054,1252,1251,1250,1241,1233,7041,1231,1226,1225,5005,7029,1215,7179,1192,1190,1188,1168,7015,6637,7005,1151,1150,7000,1139,1131,8904,25990,5616,6992,1091,1082,8856,1068,1047,7223,1046,1045,1040,2945,6638,1029,26008,1003,6969,7238,990,988,987,6961,984,951,948,6959,941,926,6955,6949,907,906,905,816,867,848,7248,815,2935,807,7253,795,6939,789,786,785,6642,790,768,761,760,6770,775,753,744,694,6811,754,719,7258,6930,701,697,8843,693,671,678,627,619,613,6922,596,593,6919,572,570,551,534,6812,539,524,7296,505,8780,499,497,492,7325,483,408,487,6909,477,473,445,2933,436,435,7180,439,431,8756,428,6904,418,7339,415,8858,411,6900,7345,26030,8859,2932,404,390,389,388,7341,394,386,376,8748,6885,26033,7354,7358,366,4534,349,345,4541,4802,6877,336,328,6870,308,273,6862,6850,293,280,6851,6848,266,8722,6837,258,256,233,7419,210,79,139,4660,7430,4496,2919,5901,4502,7443,5902,6822,2908,4514,4513,4516,5905,4519,6802,6796,5906,6853,6795,6792,4527,2901,6787,5908,5909,2899,8691,5910,2897,4536,8885,4537,5911,6785,6780,4542,7486,5233,2885,5915,4546,4547,6765,4549,2881,4553,6859,8890,4556,4557,2869,7498,5919,5142,6860,2866,4563,7502,2865,4569,6861,4571,2861,5925,2863,6729,4578,6723,6717,4581,7529,6863,6708,4587,8608,4592,4593,4595,4599,5931,4597,8906,2856,6701,8557,7553,4640,6700,4602,6866,6693,4607,2853,6686,4612,9383,2847,6867,5744,8514,4616,2842,6673,4624,7571,4627,4629,6670,5087,4632,4633,4634,4832,2836,4637,4638,6661,6658,7591,4643,4692,4644,8920,27865,6657,4646,8476,5945,6653,4653,4654,8451,4657,5947,2831,7622,6872,8435,4694,4666,7635,5951,4677,6619,4680,2827,7653,2824,6614,26138,26139,4689,4695,4697,4698,6875,4700,27945,6601,6592,4704,4705,6582,4708,2822,3260,7691,4711,6574,6570,2408,4715,2809,4717,4718,2802,4720,3586,4723,26154,7728,4728,5967,4749,4613,4731,6879,4738,17376,4741,4746,4744,4752,6513,2791,4761,4764,8967,6485,7759,4769,6483,5976,4773,7779,6479,2787,7783,5979,2786,6471,6468,2785,8697,4790,4794,4793,2507,4797,6453,6451,4830,6886,2778,7827,4819,5143,7832,4822,6435,8993,6432,2766,2763,6889,6417,4839,2762,5996,6411,5999,6890,5190,6000,7896,6398,7908,5216,4861,4858,6009,6395,9006,6394,6016,6393,2761,26218,4869,6384,5094,4874,6382,7973,6017,6377,4891,6376,6375,4895,6371,6020,4900,2754,6365,6021,7987,5791,213,25532,2749,8431,4917,6023,5347,6024,4919,4921,4775,4944,4941,4943,2748,9025,8707,6031,6937,8041,8708,8051,6035,6905,8062,9040,8375,2743,8074,2992,6041,8360,8077,1373,8358,16063,26256,4469,26266,4968,8343,6049,6911,4973,4974,6912,8340,9058,4976,8324,6053,8111,8113,8311,4849,6057,8712,8130,4995,6059,2738,6062,5002,6061,8292,4866,6065,16065,8274,5048,6072,8266,8261,5031,6073,5037,6074,10630,2726,9077,8198,5043,4883,8243,8219,8208,5858,16066,5069,2666,26325,8184,5072,5073,26330,2721,6083,5081,6086,5084,5086,5099,8216,9080,10138,10133,6099,8234,5111,5096,8172,6097,5116,26367,16067,5123,5125,8247,5136,5139,5140,5147,4904,5149,6934,5181,6104,6105,8149,26384,5154,5156,8140,6107,6108,8121,2652,8119,5171,6111,5176,6112,6113,6114,5183,8105,8098,8078,8069,8066,8275,6120,6121,5196,8033,8036,5202,6123,6125,4272,5218,6942,8003,5228,7996,6943,5230,6944,5235,6134,5240,5238,7932,6135,6136,4239,5244,7944,5247,5250,5251,4203,2639,6140,8282,26415,8280,5262,7919,2638,4915,5275,7918,6950,2636,2623,4120,5287,7887,4107,8309,5292,6952,7342,26821,5295,6149,7878,5299,7868,26817,6954,6152,6153,7859,7841,8323,5315,5318,2617,8336,5329,5332,5333,5337,16070,2606,5343,7811,5418,5345,5346,4029,2605,2588,5354,26435,6165,2581,6166,7801,2576,3500,7793,2572,7789,6962,5421,7780,3439,5376,6173,5389,5391,2501,5392,6965,2493,7755,5400,3287,5404,6179,2492,2485,7733,7735,2483,6182,25638,3202,6185,6204,6192,2473,5428,5430,7695,7694,2456,7692,5486,7683,2433,3142,6198,7654,7631,2394,5445,5446,2448,5451,6200,2367,5457,5460,5462,12892,26464,8352,66,6203,2312,7621,5473,7612,67,3124,6976,7609,2290,7603,5482,7388,5485,6977,2286,5489,7590,2278,7592,5493,8371,5499,6979,7389,2420,7581,7579,7570,2241,7566,2336,2238,7562,5516,6401,5517,7558,7545,2138,2270,26474,5521,5522,5523,5524,2030,5526,7541,6984,3079,2134,5531,6224,6226,7531,5536,6227,6986,7518,2130,5547,6987,5552,1976,7512,6988,7496,26476,5563,8383,26480,1946,26484,7494,5571,26486,6237,1934,5580,7492,6239,1916,7481,7471,2999,5596,1907,7466,1886,311,5602,1849,7462,1865,5614,7455,16076,5617,5621,9109,6994,6248,7452,5632,7445,5641,5642,6426,1726,7434,2014,26524,5657,5660,5661,5665,1204,5668,7427,6998,1652,5679,7415,1623,5685,6261,5689,1601,5693,5694,6262,5695,5697,7406,9495,6265,1528,6266,1986,9468,1587,2870,9449,5728,5727,6285,1576,5734,7004,2848,5737,1572,1545,1541,26560,1534,9418,1536,5746,9417,7007,5752,1530,26578,5756,6281,1524,1508,1507,9388,5762,5764,6287,1492,2678,5098,5774,1444,1399,9356,6295,5801,5802,1377,5808,5814,5815,7014,1361,9339,6303,7018,26613,6309,1334,1302,6318,16080,6321,7021,9311,1299,1292,1274,1268,9303,1260,26620,9296,7024,1831,7025,7027,1232,9282,6348,1229,9273,6355,1222,6427,9260,9259,1202,9251,6369,1170,6373,1161,9248,6379,6380,9243,7034,1149,6400,6388,6389,809,9225,9220,9223,6402,1111,9213,1092,6407,6409,6428,1078,1077,9173,9171,26651,9166,1049,26652,6424,6518,9159,6431,1639,6454,1041,26655,6439,9153,7050,6443,6444,5511,1591,6455,6458,28257,8412,6466,6467,1013,7067,8774,7069,6481,962,6490,7057,8419,6493,7058,7059,947,16085,929,7080,7062,6507,8424,7063,9863,886,6516,9832,856,9830,7410,6524,7073,6538,810,7075,6545,792,6551,7079,6556,6557,7082,755,777,736,1081,1073,6588,1272,735,1097,9762,729,9759,7089,7090,26697,9757,703,6695,9244,6610,698,679,7092,9740,6622,628,6625,626,6631,9722,6635,7097,6647,516,7098,9715,583,594,8433,9703,6654,6655,6659,571,6662,6664,6665,9670,6668,527,9654,9659,511,6675,16316,6679,510,500,4824,9617,6685,6690,6694,495,8797,16315,7111,481,6702,6703,6704,9595,6710,16089,9592,6714,8799,6718,6721,6724,4845,6725,6727,472,6732,468,16313,9515,6739,6740,7121,7122,7125,16312,441,6744,6749,6751,6754,6757,6760,7416,440,433,6762,429,9106,6766,16311,414,7132,16310,409,406,403,387,6778,7136,373,367,356,6793,6794,344,9035,6799,6806,7142,8812,8501,9005,6820,4935,15092,6823,7146,317,8815,297,7164,8520,5573,7184,8532,276,8539,7279,262,7280,7173,7172,7178,214,10211,7187,7190,8916,4682,7196,7199,7200,7202,7298,7206,8878,4759,7207,4497,7211,26756,7213,5105,4500,4216,26757,8853,7225,8835,8834,8831,7232,4687,8837,8824,7241,7242,4511,8819,8816,8841,8811,5027,7255,4517,7259,7261,4518,4520,8804,7422,7270,7275,8789,5010,7284,7286,4525,7432,8781,7291,4529,8775,7306,7313,7317,8764,8760,8759,8758,7328,4966,8753,8752,8754,7337,7475,4535,8750,4538,8860,7417,7349,5110,7350,7353,7355,8743,8744,7363,3618,2094,4548,7368,7370,8738,2253,4552,30,7377,4555,7379,7384,7385,7386,8728,4561,3505,7391,4382,7395,7397,7398,4564,4230,7401,7403,40,8723,9162,7409,28,7412,7414,7420,7418,4566,7426,8717,8716,8876,8713,16109,8705,7440,8702,7439,19708,7444,7446,7449,7450,4574,7490,7454,7456,8695,7457,7458,9163,16111,7461,7465,9164,4580,7464,7469,7468,7472,7474,8688,207,7479,7482,3304,8888,8889,16113,4591,8677,7493,7636,4971,7497,7499,7500,8666,7585,7506,7504,8653,7509,8895,3242,2867,7511,4603,9165,8646,7515,7516,7678,7519,7517,7521,7524,7525,7526,8901,7527,8622,8902,8621,7532,4619,8592,7534,7536,4620,8905,7538,8569,4623,8563,7542,4625,4626,7544,7548,7546,8541,2777,8909,7551,8521,8910,7557,7559,4639,7564,7568,4641,8513,4642,7572,8507,7573,2742,7578,7580,8917,8505,7610,260,7586,8919,7587,4655,7593,4658,7597,7598,7599,7600,7601,7602,7604,5155,3453,2495,7613,8457,7614,7615,4669,7619,8437,7625,7627,196,7628,26812,7632,7634,26814,26815,7640,7637,7639,11068,7641,11064,7652,5163,7651,26819,11060,7655,7659,7660,7658,7662,26828,26829,7663,7668,2258,26831,7667,7665,7671,7672,7674,26832,26833,4686,7686,4691,7687,7690,4696,8944,8658,2947,7700,8947,7704,7707,7712,7713,7715,7716,7718,7724,784,7727,7837,9174,8952,25,7734,7738,8963,2249,7748,7751,4709,7754,7757,171,8972,7760,7761,7764,7765,7766,7767,7768,7769,7771,7772,7774,8974,7775,4713,7778,7784,7788,7791,8978,4714,7795,7794,7797,16138,4054,7806,7802,4722,7808,26854,7813,8985,7819,4726,26859,7823,7821,16140,7828,4729,7830,7833,7835,7289,16141,7836,7838,7839,7840,7843,7844,7845,7847,7848,7849,7850,7851,7853,7855,7858,16142,2729,7863,7867,16143,7870,3509,7873,26871,8994,7876,7880,4732,5294,7883,7885,7891,1308,7894,4733,7897,7902,7898,7900,16147,7903,7904,7906,13551,9004,7912,4740,7914,1859,7920,9008,7921,7923,7925,16286,5145,7442,7929,4750,9010,7931,7936,5316,4751,7945,4760,7946,4762,7947,7949,7950,7952,7954,7955,7957,7958,7960,7962,7963,7964,7965,7967,9017,7972,1881,7976,5348,7979,7984,9019,10758,7988,7989,7994,7995,4774,540,5357,8000,10752,8002,8009,7263,5363,4777,8010,8012,12,8014,4780,5383,8027,8026,4781,8030,8031,8032,8037,9029,9031,8040,8039,9032,4796,8042,8046,26913,8048,8049,4814,9036,8050,3006,8054,8055,8056,8059,8060,8093,8063,8065,4823,1057,1868,10723,1494,1459,1133,9052,309,9055,8087,10794,8092,4828,8089,8094,26931,8099,8103,4840,10714,4843,8110,4844,9062,12483,4846,8118,8120,8122,10798,8127,9065,1200,8133,4856,9222,8135,8134,8151,4860,8143,10702,4863,8155,8153,9070,8160,5320,9072,7451,4868,8170,8169,13847,8177,8183,8182,8181,8180,8179,8187,8256,8186,8185,8189,8197,4156,8203,1720,8210,8209,8214,26954,8218,8217,8224,8228,957,10728,12791,26955,5151,8233,4892,9082,26956,26959,4894,8237,4898,235,1050,8248,4902,9085,26960,8255,8257,8253,8263,8260,8269,8268,8272,4907,10660,8277,9090,10656,1173,8286,9091,8291,14696,9092,4911,8300,9093,8304,9094,8308,8307,8312,1824,10648,10647,8316,4933,10646,8320,8321,10645,4942,8328,10644,9099,9100,10643,8335,8330,8333,8332,10,8337,10483,5177,8344,1242,9102,8347,9103,8351,8356,4992,8366,14607,8370,8377,9107,8379,9230,8384,3085,9121,4459,9123,9122,9256,8398,9179,8397,8402,8404,8403,8410,8408,8407,9130,8416,9131,27009,9132,8421,8425,8428,8432,27031,9135,16188,514,9136,8438,8449,8447,8454,9138,8456,8461,8459,1456,9141,8464,8465,16191,8467,8469,10610,8479,5553,8473,10841,8475,8485,8483,27067,16192,27068,8487,1100,8490,8493,1432,8496,8494,8499,8504,8503,8502,8508,5576,9150,8512,8511,4297,8516,27083,9151,8519,8522,9152,8526,27086,8528,27092,8533,8534,27100,8540,8537,27101,27103,10544,8542,8547,8551,2223,8555,8554,8556,2164,8561,2156,8574,3555,8580,8601,8607,8610,8614,8628,3401,8634,131,9170,8635,8637,8642,8641,8645,8644,8659,27140,27141,16202,5914,10509,13552,9188,9187,9194,9192,9196,2311,9200,146,9203,27150,9281,1030,9218,9215,9217,3475,10442,9221,2690,9236,9235,9242,9246,1672,5654,4090,9267,767,9274,27181,9278,9289,9283,9288,9297,9304,9299,34,27185,9301,9300,9307,9306,5284,9314,9317,1807,9322,9324,15180,27193,9330,9335,9343,2680,9346,2185,16223,9355,9354,2062,39,9362,29,16228,13004,3495,141,9382,16229,9386,2632,16230,9400,9401,9408,9411,2289,16233,9422,10302,7006,3451,9438,9452,10917,9443,9457,10267,9467,545,1017,16239,896,9895,9331,9492,4988,9491,9501,19533,16245,16246,16248,10225,9547,9545,9550,16250,4426,4386,5778,4979,10193,27253,4366,9573,9570,9575,16703,27256,9361,9588,4314,9591,9603,4228,9374,5809,27262,9615,4171,9619,9625,9630,4103,9637,27005,10331,9646,4032,5849,9648,4023,9651,4010,9664,10037,9396,9665,4002,9669,10011,3659,3656,9683,3644,9692,9689,9695,9694,9693,5022,9700,9707,9705,9903,9712,9711,3614,9403,9718,9723,9727,9878,3595,9737,3589,9746,25358,3572,27292,9753,9424,3566,9765,3560,3552,12297,10130,9789,5054,2064,9814,3523,9822,9454,2203,2459,9462,3465,9836,2781,9841,12265,27304,9844,3457,12260,9847,9852,794,12255,9857,12254,9861,2362,12253,2119,12251,9871,27317,4923,2812,9900,9899,10247,9902,12227,9908,3400,12220,3382,12219,5960,3379,9921,3373,9926,12212,9931,3331,9934,2660,10004,10003,10008,3324,10007,10013,184,323,12188,10023,12183,10027,12177,1028,10032,10030,1025,10040,3216,10039,5170,106,10050,12171,12169,12166,2307,2240,5984,10077,2245,10234,162,10086,10088,97,12140,12137,5093,148,10099,16314,212,10114,4489,27351,12124,2019,12121,10129,12117,10137,12111,12105,16319,10145,46,5742,4972,5222,10161,10159,2917,12094,2915,10169,2887,4376,2884,10182,2859,10172,10188,10187,10192,10190,10189,12068,27359,9577,2494,9581,1,2795,6076,246,10212,228,5800,254,2783,281,998,283,2759,9587,307,103,395,469,432,452,478,5252,12040,426,12036,2600,425,453,672,407,10255,10258,12033,791,585,1018,419,532,2731,915,10272,901,1071,10274,2512,10280,12027,554,10283,971,1033,1066,1117,2302,2715,257,2709,1053,1008,10306,1044,832,10308,1039,1015,10320,5273,648,968,2291,520,12006,820,667,2694,1350,5293,10379,11999,11053,1083,2271,10391,11995,5301,961,4176,1228,1353,980,796,10410,1674,1376,10430,1476,1778,1727,1805,4040,2268,1788,5314,1406,10459,2675,11067,1779,4031,1827,10474,1315,10475,10480,5323,1687,10484,11949,4018,1740,892,5861,813,819,893,27395,2108,2208,17224,4007,2210,2265,2298,1900,3663,2236,2005,2195,2550,817,2211,11945,1851,10543,11086,11085,11938,2667,2439,11933,10550,10555,2137,2522,2058,5356,2691,2503,9905,2668,10577,11091,10581,2049,10580,1765,16350,16349,814,16351,1054,11900,11118,2794,11122,11121,55,11125,16353,2800,12106,5366,2826,16358,2036,11139,27433,932,3609,2914,2864,5369,11886,2105,16272,11871,2050,5104,2846,27436,11161,11160,11166,11171,11169,3025,11174,11173,178,3021,11187,11186,3092,3115,3225,11201,3190,9758,3178,3041,5384,3270,3159,11216,11215,3305,3152,3361,3245,3367,2266,5387,12221,2547,1398,3234,3163,11245,11249,3428,11247,3058,11257,11258,3539,11261,3423,11815,11285,2486,16387,11274,16389,16388,3515,16391,16390,11283,11281,11280,1760,11287,11286,11291,11290,16392,3616,16368,16394,16393,3624,16397,4280,11302,11301,120,4167,4006,3577,12737,4130,11322,2384,3592,5422,4192,11796,11333,27473,11791,11338,11337,4267,11343,11341,11340,3544,11348,11346,11345,11786,11784,4243,11781,11779,4193,4365,11777,4368,4375,16426,11772,11373,11372,11370,4162,4390,118,11763,7106,11388,11387,11386,11385,11760,11392,11391,11395,11394,16415,11399,4572,11403,16417,11406,16418,555,16420,16419,27482,11413,16422,16421,27483,4468,13005,479,11419,16428,393,11423,2292,11426,4277,11429,11750,5205,11435,4493,2070,11745,4507,4308,11453,11452,11455,4532,9748,11744,11460,11459,11466,11464,11463,5928,11737,11468,4505,11474,11473,11472,11471,1992,11484,3461,4659,4610,11708,4745,11704,91,11703,11496,4950,15742,5053,11702,5078,11701,5169,11514,11512,4346,11700,11521,11527,11526,11525,11524,4789,11531,11530,11529,9750,11535,9855,11538,11537,11542,11541,4862,11699,11549,2528,4864,27525,11559,5025,11565,11696,9870,5291,9745,11695,3419,5026,11591,11590,11589,11588,11692,11593,5378,11599,11598,11597,11603,11602,11601,9880,5439,11609,5063,11625,11642,4565,11646,11650,11649,11648,5496,9752,11647,11659,9754,5484,11657,11662,11661,9755,9904,11667,11666,11665,9756,11669,1728,5470,5953,11694,11693,11691,5634,5653,4670,11707,11706,11705,11608,6347,2482,11600,5680,16532,16531,16533,5455,5533,16536,16535,11743,11742,11740,11739,11749,11748,11747,11746,5929,11752,11751,11592,11768,5507,5701,5747,5786,11767,25394,3450,5817,11780,11776,11775,11774,11773,11785,11783,11782,6063,11790,11789,11788,11787,11795,11794,11793,11792,5267,5913,5978,225,11806,6087,182,11582,6044,5806,11825,5922,11840,10020,11882,11865,6046,6156,11566,11866,6176,11874,11876,11576,11881,11880,11879,11885,11884,11883,6085,11888,11887,6423,11893,5535,10043,11951,6138,6158,11550,27555,11908,11907,20,6247,11916,27561,11543,11929,6249,11540,11931,11536,6148,11937,11936,11935,11934,11534,11942,11941,11940,11939,6245,11944,11943,180,6330,2215,11950,11528,11954,11523,6712,11522,5554,16565,12017,11965,11519,6523,6425,143,17195,5557,6144,11970,16568,16567,11994,27566,11997,16570,6292,16571,27567,27588,12012,16574,16573,12020,12018,11515,16575,12023,16577,8839,16579,16578,6378,5184,12032,12031,12030,12029,12035,12034,16580,6632,16581,6539,6735,16584,6183,12067,12064,16585,16587,16586,6674,12086,12085,16589,6824,852,12104,12103,27593,12110,12109,12108,12107,1329,12114,12112,6410,12118,12116,27594,27596,12122,12120,25391,6590,12139,715,6521,12145,6738,12148,12154,6809,6584,6814,12170,12167,6825,12174,12173,12172,12178,12182,12181,12180,12179,12187,12186,12185,12184,1343,6856,12189,11479,25389,11475,6902,6903,27625,12202,12222,7019,11467,7031,11465,7038,6029,7055,7008,12218,12217,12216,12226,12225,12224,12223,7128,11458,6628,6807,92,6037,10104,6494,6957,799,7251,12252,12259,12258,12257,12256,12264,12263,12262,12261,7003,7237,11456,7483,12280,123,2782,11454,2,3397,12288,12292,11450,12296,12295,12294,12293,12298,4439,12307,994,17154,2627,27643,27645,2237,7193,12312,26654,12311,12310,12309,16622,12314,16620,4170,16621,16623,7467,27684,16625,16624,16626,7463,27685,12337,16628,16627,2306,12339,16629,12347,12346,12345,2087,12344,12352,12351,12350,12349,27693,12354,16631,16630,27698,16632,19580,5483,1284,2037,12364,12377,8144,27726,6526,12371,1846,7074,7582,2086,7583,11433,269,11427,7743,2186,3478,7792,12439,12438,12437,27771,27772,16651,12446,7866,12444,8116,12451,12450,12449,12448,8157,12454,12453,8159,7943,12474,12472,248,10264,8206,8211,617,12505,8213,3562,2080,2841,7834,1007,7540,12559,12558,12557,12556,7453,217,7732,2534,7809,12587,11418,53,7941,8201,12608,12607,27815,12612,12610,27816,7993,8029,63,12625,3043,1517,107,6048,12643,7818,1829,7864,27820,19744,2294,8083,27822,16666,10128,12675,12674,12673,12672,12678,12677,12684,12683,12682,12681,12689,12688,12687,12686,1871,7942,12693,12692,12691,7271,7433,16670,16671,12710,1844,8067,12712,16673,16674,8104,8123,7980,3310,12743,16676,5212,8082,12746,5214,2658,8137,12751,12750,12755,12754,1042,12753,12752,12760,8147,12992,12759,12758,6530,1219,7607,1770,7608,12784,27861,1447,7807,27863,1182,8162,12789,11412,8165,1189,12792,8166,12800,12799,12798,8167,8173,1840,12807,1901,7826,10096,238,12815,12814,12813,12819,12818,12817,421,10184,10266,10268,2045,10276,10281,1426,1137,10316,8139,12973,16697,8154,12847,1120,8129,12854,12999,12860,12859,12858,8205,12866,12865,12864,12863,12871,12870,12869,12868,12998,8313,12874,12873,8176,7336,8194,12881,16704,967,8232,12884,16705,16707,16706,8250,8249,27877,8251,8267,12902,12901,8191,12907,12906,12905,12904,8270,12912,12911,12910,12909,12915,1615,12914,2479,2462,8285,8287,8294,11405,27900,12923,8295,8296,8299,12940,12939,12938,12937,27926,12945,12944,12943,12942,11404,8301,8302,8303,1454,8305,959,12971,1563,8306,8178,12968,12967,12970,2997,8284,12993,8288,12978,12976,12975,27940,11402,12980,7550,12985,12990,12988,12987,7574,12995,8212,8223,13001,13000,8225,13009,13007,13006,13013,13018,13017,8325,13026,13025,13048,8341,8283,1962,8385,1178,8386,8388,8390,13051,13050,13049,8391,13056,13054,13053,8393,27978,13060,13058,3257,8395,8350,1383,8394,13281,9853,9856,1341,1927,13332,2772,7999,8317,8334,70,8382,8353,13342,13341,8427,13347,3238,11397,13355,11393,8196,8399,8406,13372,8430,8439,16768,16767,8444,16770,16769,16772,16771,8195,16776,16774,16773,16785,16784,8364,13390,16786,8229,28021,1860,28023,8434,8142,13401,13399,13398,222,13403,8445,2048,8446,13409,13407,13414,13412,13411,13419,13418,13417,13416,8314,13424,969,13423,13422,13421,1035,13427,13426,8805,8373,1887,8515,13443,13442,8361,1397,8455,75,11389,13455,8500,1197,8506,975,8548,13469,13467,8633,13471,13480,13477,13476,13475,13474,28084,13482,13481,13479,13485,10237,13484,16802,16800,652,1691,13505,8568,13508,8349,28105,13514,16806,28115,2060,13524,13523,13522,13521,13529,13528,13527,13526,13534,13533,13532,13531,8536,2804,13541,13536,8572,16808,2170,8491,8615,16809,16810,7899,16812,16811,16814,16813,1483,8443,2739,16816,16815,4452,16817,8517,13570,13569,13573,2161,13572,25616,8631,13577,8638,8640,13585,13584,8665,8667,13587,8668,13590,17155,8671,13596,13594,13593,8680,28144,13601,13599,13598,13606,13605,13604,13603,8689,13609,13608,4423,4420,8694,8331,13625,13623,13622,8818,13630,13628,13627,8701,13634,13632,1163,992,7367,4384,985,8355,17906,17929,8486,17938,13673,13672,13671,13670,8605,13676,13675,8721,13682,13680,13679,8731,13687,13685,13684,13692,13691,13690,13689,17968,13698,13697,13696,13695,10269,13702,13701,13700,8509,8740,924,4330,8553,15425,8808,8755,4316,8779,18036,2213,13721,10270,13727,13726,8342,8761,13730,13729,8546,16841,8845,16844,16843,16842,8850,13743,13741,16845,13747,13746,16846,18066,18071,13752,13751,13749,8733,13757,13756,13755,13754,13763,13761,13760,13759,8788,13769,16849,16847,8854,10277,8900,13774,8907,8865,8986,8124,13783,4238,8193,8577,2034,2013,8751,18115,2365,18119,13792,8823,8852,4191,13796,13795,1558,8912,13802,13801,13800,8138,13808,13807,13806,13805,851,8724,13812,13810,13817,13816,13815,13814,8827,18143,13823,13822,8965,13828,4153,8971,4136,4024,13844,18180,4020,8372,2941,11364,8613,18200,13852,4124,18201,13855,13859,13858,13857,13863,13862,13861,13860,8934,13867,13866,8953,13873,13872,13871,13870,13876,13875,2123,2009,18222,10279,2345,18233,8883,8518,9002,4099,9003,9012,9016,9026,8741,1960,9048,4080,2840,9056,18265,9069,205,18269,18271,16871,13930,13928,13927,18298,13935,13933,13932,8409,13940,13939,13938,13937,18315,13945,13944,13943,13942,13950,13949,13948,13947,18322,13955,13954,13953,13952,9011,13958,18326,13957,16872,9073,18350,13975,13974,13972,9084,13977,8940,2446,14001,10055,4011,18381,18372,10057,16878,10059,18380,16880,16879,10060,16882,16881,1993,8679,16883,8765,11355,14016,1967,8948,14027,11349,9075,18408,14034,1806,8842,14039,14038,18426,18434,14044,14042,14041,18440,14049,14048,14047,14046,8844,14054,14053,14051,8927,14057,14056,2175,8782,14062,3613,3612,1937,9175,11347,18487,14075,14074,3594,8970,8549,9148,3564,9195,7246,610,18499,18505,14090,8477,14094,14092,8868,11344,18529,14097,5271,1876,14101,11342,7250,3528,14109,14108,14107,14106,14113,14112,14111,9181,16896,9197,592,9227,14131,3474,18607,18619,11339,10162,3458,8345,14147,14146,14152,14151,14150,14149,8429,14157,14155,14154,18647,14162,14161,14160,14159,9022,14166,14165,14164,9139,1922,9198,9224,498,11332,9254,3425,9207,3412,8939,18702,9295,3411,8145,16907,18732,9028,5684,9305,3403,9319,18738,14213,14212,14211,8869,14217,9334,14216,14222,14221,14220,14219,14227,14226,14225,14224,8894,14232,3391,8995,5698,18767,9337,2465,9323,9359,420,3383,9129,18778,14253,9137,11325,14254,9375,16916,18793,16917,9390,18807,18811,14266,16918,8602,416,18813,9360,18815,14280,14279,9425,14285,14284,14283,14282,9448,14290,14289,14288,14287,10382,14298,14295,14293,14292,9366,14305,9429,9455,9459,9502,7630,16923,9190,9275,18900,9371,14349,9435,9478,9479,9481,14368,14366,16928,14371,16929,9482,14377,14376,14374,9885,14381,14379,16930,8742,16931,14394,14393,16932,9074,16934,16933,16936,16935,2069,9503,9302,9357,5750,16945,19201,9444,28191,2039,14416,9517,9543,14425,28192,14424,9321,19213,11311,5307,9818,14432,8857,2023,9120,9892,19224,5765,14441,14439,9431,19233,14445,14444,14456,28197,14451,14449,14448,14455,14454,14453,9897,14460,19244,14458,14466,10285,9064,14497,9569,2730,9571,9579,9598,9586,14498,14494,14493,14492,14503,14502,14501,19269,14508,14507,14506,14505,14515,14514,14513,14510,14517,9628,2616,8369,11295,2424,9465,17156,9666,1893,9381,397,5795,9668,19310,9671,2006,1640,1389,223,19331,16957,9688,9329,16958,1621,9412,14566,14565,11292,14569,14568,9696,9714,14574,16966,9729,14579,14578,14577,14576,14584,14583,14582,14581,19362,14592,14591,14590,16967,9663,16968,1147,9667,11289,10447,9770,9787,19372,9034,9499,9796,16974,16973,19380,1872,9541,14622,17157,1016,9469,995,9580,16976,14639,9713,16977,9829,19393,353,9838,14636,14635,14642,14641,10454,14648,14647,14644,9183,16980,16979,16981,11288,351,515,14671,19413,26331,14677,14675,14674,1950,19419,14682,14680,14679,9647,14688,14687,14684,9925,9875,14702,14701,14700,9928,11284,19436,14721,11282,28241,28244,14722,14727,14725,14724,14732,14731,14730,14729,14738,14737,14736,14735,14747,14746,14749,19466,17158,19468,17159,337,17161,14975,14766,14765,14771,28248,14773,11279,14778,14777,28256,14782,14780,14787,14786,14785,14784,14792,14791,14790,14789,28258,5281,14794,28259,28260,28263,1918,14818,19518,14824,14823,14822,11268,4510,4521,5917,11271,19534,15196,17011,14862,14860,14859,298,10497,14866,14865,19548,14871,14870,14868,14875,14874,14873,19565,4540,14896,14898,14910,14909,14908,14907,14915,14914,14913,14912,14920,14919,14918,14917,14932,14924,14923,14922,14935,14934,14992,4600,19583,19587,4622,19588,15195,4649,1713,11259,14974,14998,14997,14996,14995,15003,15002,15001,15000,19596,15006,4672,15053,4674,15036,15035,1176,15039,15038,15049,15047,15052,4503,15061,15060,15059,15058,15065,15063,15071,15076,15074,4504,4508,4837,15113,15109,15108,15112,15111,4853,4509,19639,19637,25321,15143,15147,15146,15145,15144,15152,15151,15150,15149,15159,15155,15154,15164,15163,15162,15161,19649,15193,4882,1594,15179,15178,15185,15189,15187,15200,15199,15198,1588,19660,15225,15236,4522,15235,15234,15233,15241,15248,15240,15239,15238,15246,15245,15244,15243,15249,19669,17426,11246,17066,4530,4951,3662,15396,15394,6143,4440,4531,4223,15487,15493,15492,15491,15490,15498,15497,15496,15495,19682,17073,19684,17074,17076,17075,15528,17077,15533,17078,15538,15537,15536,15535,19695,15543,15542,15541,15540,17079,17080,4447,6050,4957,4959,15583,15582,15581,15580,15587,1217,15585,15592,15591,15590,15589,15598,15597,15595,15594,15602,15601,11238,2056,15632,4539,15635,4986,15647,15645,15652,15651,15650,15649,15657,15655,15654,1127,15662,15661,15660,15659,1957,15665,15664,4545,19743,6084,15700,15699,15698,15697,15705,15704,15703,15702,15721,15718,15717,15707,19764,15724,15723,607,5007,5016,10582,4558,5032,15753,19773,15756,5051,15774,15773,4451,5077,15782,15786,19796,15787,252,15785,15784,15791,15790,15789,1174,4688,1072,15808,17110,17111,6117,17113,17112,17115,15827,15826,15825,15824,15838,15830,15829,17116,5152,15836,15835,15834,15833,15840,15839,17117,1461,5180,5198,5219,1624,17120,5223,3648,5321,15869,15880,15875,15874,15873,15879,15878,15877,15885,15884,15883,15882,15890,15889,15888,15887,15892,17122,782,4576,5257,15919,19830,19834,15929,15927,15926,15934,15932,15931,15939,15938,15937,15936,15944,15943,15942,15941,15949,15948,15947,15946,15953,15952,15951,4577,716,19869,1227,4582,19873,5360,5364,15995,5368,16001,16000,15999,15998,16006,16005,16004,16003,16009,4719,16008,17163,17196,16023,16022,16027,16026,16025,4584,18052,6808,5424,5432,18142,5449,5450,5463,5488,17197,5502,19916,5505,6188,17193,19919,4586,17199,17198,4594,17219,17226,5562,6209,1364,5575,6212,4596,6215,17266,5593,17249,17265,1095,17268,4601,772,5598,17285,6234,17320,6241,17317,17316,17315,17314,4604,5615,5341,17363,5625,5628,5350,5633,17341,625,6259,17366,17371,17370,17369,17368,5672,19999,17390,17394,17393,17392,5673,482,17411,94,4611,17417,17421,17420,4614,17423,17422,1395,17429,17428,17427,25294,5676,5677,4615,17438,17452,17443,4617,17460,17456,17462,17461,17472,17468,17467,11123,17466,5703,5704,17479,17482,17485,4618,1991,4628,4630,1646,17505,4635,17510,17509,4636,17518,17517,5733,17523,17520,243,1065,17545,17535,5743,5748,6308,4645,17558,17556,17567,17566,17565,17564,1064,5772,17580,17584,5780,20044,5875,5787,17596,17616,4651,17615,17614,17613,4652,742,5797,1908,17820,6331,17651,20071,6335,20079,17649,17648,17709,4662,4664,4665,17737,17736,1253,19745,20091,5857,6352,6358,11221,803,17776,17780,17779,4673,26329,5355,4675,6360,4676,5907,18651,5920,272,6367,4679,6374,4683,17835,5938,5940,6385,17858,5948,17868,17866,17865,5954,17878,6399,25353,5971,5981,1537,25357,17901,4699,4701,17931,4703,11217,4706,4707,17942,11212,11211,4712,11208,4716,17971,23,11202,17969,17970,17972,17974,4724,6437,4730,1971,4735,11189,18009,18010,18031,18032,6449,11188,1861,11182,6452,18033,18034,11172,4737,6457,1852,11167,18030,6461,4742,18035,4743,11163,11162,6469,11158,4747,2055,4748,11155,2112,18065,5359,18067,18068,18069,18070,18073,18074,663,11152,11151,18084,18091,1888,11141,18093,1243,11138,11136,4766,6503,4768,18113,25392,18116,18117,1270,18121,11126,6511,6512,4771,11119,6515,11115,18133,11110,427,18141,11108,18144,18145,18146,11106,11100,11098,18232,1474,11095,11093,6543,26347,4776,11084,6558,4782,13856,18181,18182,1662,18183,13854,18190,6578,25467,6581,13851,13850,6587,13849,25260,18202,18203,18204,241,18214,6593,13842,6595,4798,6599,4809,13821,18220,6605,13813,4811,18231,18235,13809,18234,4812,13804,13799,4816,16408,6857,13797,4817,13794,6627,4820,26807,2257,4821,4825,18267,18268,18270,18283,20144,18301,6656,4827,18309,4829,18289,18286,4833,18288,18293,13776,18314,18299,18300,18302,18303,13766,18313,4834,18317,4836,18316,18318,13758,6682,6680,13753,13750,18327,18328,13748,4842,4847,13744,6697,18348,18349,13738,25245,25244,13728,4852,18507,2079,13723,18361,6731,25524,6736,20150,26479,6747,6752,6759,19664,6781,13703,13699,18401,4857,13693,18409,6790,13688,13686,4412,13683,13626,18439,13681,6798,6800,13677,13674,18460,18508,18438,6821,18441,6830,18543,156,4867,18486,4871,18459,13631,125,6847,18466,4873,13633,13629,18485,13624,13621,19617,18495,13610,18500,18506,18504,13607,13602,13600,6892,20679,13597,6899,13595,108,18525,20698,13579,13576,4885,13575,4886,13571,18542,19590,6938,26095,18585,6946,18557,13560,4890,13558,18573,18575,18608,18578,18579,18584,6974,20699,13520,4901,18609,7076,13535,13530,2031,13525,6997,1975,18648,18649,4913,13515,4910,13513,13511,1965,1964,8625,18650,9146,5453,4914,25511,7028,18731,4916,13498,18674,18677,18678,4918,13483,25533,4922,13478,7044,13470,1721,13466,7061,18701,26481,1504,4937,4938,19450,13460,7078,4947,20500,18727,18729,18733,7109,13445,26483,13441,7112,751,13425,25220,26818,13420,19386,13415,18763,1125,13413,18764,13410,7129,18765,13408,18766,18768,1935,13404,13402,18870,752,13400,7150,13397,1269,13396,7157,7161,18871,13391,13389,18804,26820,18809,18812,18816,18817,7183,9781,13376,13374,18833,9879,13349,21436,21437,13348,13346,7231,9893,7233,2584,18845,7252,10089,7262,10117,13336,4389,3028,13331,10140,18869,18876,18878,7278,26825,1848,10203,18899,7302,10223,13059,13057,18903,13055,18907,18908,19381,13052,7330,20506,13047,13043,7334,18923,7338,18924,18925,19173,19172,19174,7218,19178,4956,19234,10061,13034,7239,7361,7235,7366,19382,4367,13027,13019,27011,13015,13010,13008,7256,7369,13003,13002,12997,7371,12996,7378,7383,12994,9626,12991,7393,7394,7396,7404,4352,12989,4340,12986,12984,10257,9786,12979,2103,12977,3365,4953,19245,12974,4955,7281,19575,4960,12972,10224,651,646,4962,5466,644,638,19275,4967,12950,19274,4970,4969,4975,12946,12941,4977,19311,4978,4980,199,19298,19299,10227,19300,12936,4982,4295,19308,4984,25615,12922,4987,4989,10111,4991,12916,12913,4997,4998,12908,19330,20619,25623,5000,12903,1497,1496,5003,5004,6779,12896,1421,1384,12890,5012,7314,5011,1339,1327,1310,690,5013,5018,5021,26485,12886,5029,9804,20624,5036,25203,6487,5038,12876,12872,25202,26487,5045,25201,12862,25200,5052,10139,5062,1513,1434,1433,1775,5065,5068,5070,12846,20625,5074,12839,19414,19415,5079,5082,5083,920,286,5085,9618,5090,5091,5095,20637,5097,10171,6649,12827,5103,5102,19438,7376,5106,5107,25652,5109,12812,5112,7372,5113,5115,7421,282,10549,3380,27683,5134,5135,5137,54,195,20641,5138,5144,169,181,12797,20644,5146,19492,19493,4727,5158,5157,5159,12786,25667,5168,2159,2152,5173,19519,10490,5495,2770,2481,12757,5179,4936,5182,12756,5185,7485,2445,114,12747,5193,10463,5191,5192,12745,10554,19549,5194,101,1874,12736,5195,5197,5199,5200,5201,5203,5207,12707,5208,88,45,5211,12705,19581,5213,5215,20697,5217,19586,5227,5224,12690,5226,7569,12685,5232,5234,12680,5231,12676,12670,2230,2745,19613,10467,5237,2722,5239,5241,19629,3481,25582,5242,5243,7611,4739,5023,5245,7633,47,4021,19638,1087,7594,20668,3568,12611,2602,5253,4034,12609,19661,7644,5255,7647,5258,5034,5260,5263,7649,5268,5269,7661,1055,1945,19689,5270,20677,5272,7643,5274,4201,12560,7681,5278,12555,5280,7697,4284,5285,19712,5288,5044,12543,12542,117,25122,5300,12540,26958,5302,12534,12522,20696,5305,5309,5313,12486,5317,19741,19742,3520,20701,7685,12452,5322,5326,7750,12445,12447,5335,5331,5328,152,186,5338,5339,7749,12440,5349,4430,12435,5351,7745,1063,3459,25104,8354,5352,5039,5358,6319,25737,5361,5362,7803,8401,5365,5367,12392,5370,5371,12384,5372,5373,5374,12379,5375,5064,7814,2773,60,12370,5380,27142,5381,5385,5386,7820,5388,2117,81,5390,25436,3542,7787,5393,12358,5395,5399,26328,5396,12353,5397,12348,5398,12343,5402,26488,5405,7852,20739,2235,12340,5411,5412,5413,4608,5414,2261,7865,737,20744,7693,20757,5415,7871,4275,5420,5423,7392,7800,19930,5066,7909,5425,5426,6970,5429,7861,12313,5433,5431,12308,5435,7939,5434,5436,5437,5438,7911,5442,5440,5441,5443,7968,20761,15072,5444,5447,25066,7928,5448,7975,7985,5452,5454,25063,15062,25062,15057,25061,19969,5456,20767,25059,7992,5458,20768,5464,5465,25056,5468,15054,8004,5472,5476,5477,15046,5478,5480,15037,19995,19997,20771,19996,5481,5520,7969,15021,15004,8011,7998,14999,5490,5491,8035,5492,14994,5494,14993,5498,5497,14991,5500,5501,5503,7879,5504,4702,7927,8081,5506,8088,1574,5508,4073,5509,1401,8109,5510,5513,5515,25410,5518,5519,5525,5527,8101,8070,5529,8125,5537,8136,8076,5538,8131,5544,5546,25033,14933,5542,5550,5548,14921,5555,5556,14916,5558,5560,5559,8115,5561,14911,5565,14906,5568,5570,5574,1546,8168,5577,7001,5578,8084,27254,14876,5581,18671,5590,20809,5592,8192,8174,14872,14869,14867,8190,7048,5597,14863,14861,14858,5600,2925,7924,8146,8207,8204,20152,14844,8235,8241,5612,5613,5644,5619,14825,8246,5624,8220,5626,5627,5629,20491,20834,5636,5640,2649,8279,20501,5646,14814,5650,5651,5659,20842,5663,5666,8254,20843,5671,5541,8318,20606,8329,8289,8281,5682,5683,14793,5687,5690,8319,14788,5691,5692,14783,5696,5699,26164,5700,8374,20645,5702,14779,14775,8363,5708,5711,5723,5712,5716,5718,14763,5719,8413,5721,5725,5726,8415,27383,5729,5740,26490,5732,14748,14739,5735,8417,14734,5739,14733,14728,5745,21476,14726,14723,5749,5755,5753,5758,5757,14719,8453,5760,5761,5766,5769,5767,8470,5770,5771,8492,8442,5773,5775,5777,5779,8481,5782,8463,14695,5783,5784,20742,5788,5790,5792,14683,5798,8531,5799,14681,5804,5811,8523,14678,4370,5812,14676,4985,5813,14673,8550,5819,14672,5820,5824,5825,8478,5847,5832,5833,14665,20780,20782,5851,8559,8543,5854,5864,14654,8530,5871,14649,14643,5879,3573,14640,5881,14637,20805,5883,14634,25365,3351,14621,4590,14623,4543,8396,8599,14620,5904,8578,8604,5918,8611,14611,20833,5924,5927,8632,8552,20845,5930,5933,5935,5942,5939,14593,5941,21004,8484,14575,5944,14589,5949,14580,5950,5956,14573,5957,5959,1105,14567,5963,5966,14563,7318,20891,5968,5970,10150,5974,5973,5977,5980,5983,3550,20884,5985,20885,8624,5987,5991,5992,14537,6006,5997,5993,20926,895,8670,20952,8529,20953,6008,8290,6013,6015,5188,20951,25927,8690,6022,8357,3399,8685,8524,6043,6028,14516,20977,6033,8757,2966,7357,14509,6034,8687,8777,8772,6038,8795,8620,6040,5189,8807,6045,8651,14504,6051,14499,14496,21014,21013,21470,8838,6054,6055,8458,14491,6056,21086,6060,6064,6069,6066,6067,6071,21096,6077,6082,6089,6088,6093,6092,6095,6094,6096,8882,8930,20940,6100,6103,6109,8896,6115,8886,6122,6118,8973,21111,6127,9001,25961,6131,6129,8977,6133,20949,20950,20960,8221,6142,6146,8984,6150,8969,6155,6154,8938,8949,8849,25972,6160,26144,6163,6162,6174,9124,6178,6180,9098,14457,6181,21126,6194,6195,25984,6197,6201,20976,9083,6208,9020,14452,14450,17093,6214,6222,25991,14447,9177,6223,14442,6228,9147,14438,20999,6229,21196,6233,21169,6236,27817,6235,9201,9253,14434,14430,14426,6254,6253,27818,21012,21021,6258,6257,7488,6263,6267,6268,6264,14415,6270,6271,21205,21206,9263,6276,26254,6277,6280,27725,6284,9284,9272,6288,26638,14401,3601,6290,6289,6296,6294,6297,8821,27823,9312,9325,6300,9292,6301,14395,6304,9365,4533,21047,21052,9358,9344,5101,3187,6310,14383,14378,7510,14375,9387,14373,9398,21285,6313,9414,14370,21062,25291,6314,14369,6316,9410,6326,21069,6324,21072,6323,9453,9456,21316,25276,6328,26326,6334,6338,6337,6351,6350,1532,6359,6357,6356,6362,8898,3333,6370,6364,6363,21095,6366,6372,9500,9497,21110,9508,6386,6383,9511,6387,9514,9489,6397,9420,9552,6403,9559,9509,2765,6405,6408,3126,9564,21407,9574,6412,9568,6415,6416,21138,25267,9584,16164,2956,6418,9551,21431,21432,21433,6419,6420,6421,9578,21101,6430,2923,2916,6433,6438,6441,18118,6445,6447,26180,26181,6450,26189,21153,6460,26546,6462,6465,6473,6470,2862,6476,6474,26227,2854,6480,25435,9645,6488,6491,6932,6492,6495,20970,6613,6497,6498,6501,6502,6506,6505,6504,6510,14306,14304,20927,26549,6519,6522,14299,21181,25091,6529,6528,14291,6537,26327,6531,25493,6540,9652,14286,6542,6541,26324,6546,20850,6547,2818,2816,2788,6550,6552,6555,18593,26354,6572,18605,6576,6577,14281,6580,21204,26375,6583,26374,6586,6585,6594,6596,6598,6600,27032,9642,6602,21211,6608,6606,25541,27054,20752,6615,21213,6620,20740,6621,21217,2747,20678,6624,21227,2741,2737,9698,21230,27061,2727,6630,21233,20676,6633,26433,26446,6650,6666,10540,6660,6667,6672,20655,26475,7547,26477,6676,20648,25209,6684,26504,25617,6683,26527,20634,26528,6689,6687,6692,20626,2669,26522,2653,5206,6698,26525,26526,6699,6709,20620,21283,19212,20607,2637,2630,6726,6716,21284,6719,20447,26568,19324,2628,21292,26575,2624,2596,26577,27093,6743,6737,6750,6753,6761,6756,6769,6763,6775,6771,2577,2545,19396,26601,26617,6777,26618,6782,26619,9474,21309,6786,20125,6791,6797,21328,20095,21338,21339,21340,6819,6818,26645,26649,26653,6831,6838,6834,21373,6846,6843,26672,20068,6855,20047,20045,20046,26688,6871,21370,21371,6883,21374,25168,6887,19532,6897,6894,2471,2385,6914,19559,26720,26721,26723,26722,9741,25148,9604,19599,26743,6920,6925,9709,6924,27178,6927,6928,26755,26760,26758,26763,6940,26849,2370,2355,19915,19914,21406,6964,6966,6968,21409,2347,6972,19886,26811,26813,26941,26824,6982,6981,6996,27,26830,19874,3148,19872,21155,19868,19870,2297,2267,2246,21434,19854,26851,7009,10118,7013,7011,26858,21435,21438,26860,14231,26861,21475,27179,7032,7022,7030,7039,7040,26908,19809,7042,7043,7051,7052,19798,26907,7065,26914,26915,7068,2160,2169,7159,7088,19770,7099,19890,26951,26953,25760,19739,7113,7114,19726,9701,2784,90,7117,21509,7119,7130,19711,19704,19701,19688,7135,7134,27006,7143,27007,7145,2075,27024,20023,19659,7152,2068,10185,15,7158,25800,2040,1988,1972,25826,7162,27063,7167,27066,27065,25086,7169,10194,27069,19614,25054,25055,25823,25057,1958,25058,7181,7177,25060,25064,25065,25026,7189,7197,7194,7204,7217,20163,7214,14223,25094,7219,84,19550,19551,7226,7224,7222,27135,7227,19536,7236,2429,19504,1730,19496,3491,1734,21506,19479,25123,27180,19463,21504,19459,1719,19460,7254,1683,9763,1704,20649,19432,19422,7269,20618,27258,19416,9831,27214,7273,27215,4241,7277,7276,25151,20669,27243,7292,7294,27252,7297,1599,21477,7300,7304,21471,1592,7312,7316,1589,27309,7321,19309,7327,27307,27308,27334,7333,19268,20743,25179,7344,19246,7347,25885,20772,27354,7359,7364,25195,19205,25204,7399,20824,27396,14167,1525,19184,7405,27397,9835,9622,4455,20859,7616,4470,9821,14196,4392,7670,9868,9811,9610,4290,27434,27437,27438,27476,7701,14163,14158,14156,3667,9881,14153,7684,27454,14148,7705,3630,14143,7723,7491,7489,27474,25217,27480,14102,4184,14114,14110,14105,27486,27485,4177,20171,9859,25223,4168,25226,7737,14099,9911,1266,4150,7682,14091,14093,14089,9384,9920,2226,14076,10197,4062,9935,7741,25233,3532,7329,20138,82,27529,14063,14058,14055,14052,14050,3456,14045,3467,14043,14040,21088,14015,3308,3347,14011,3329,21219,14009,27581,7752,7773,6448,27595,16,13976,13973,13971,10035,9889,27644,3120,13956,13951,13946,13941,10146,27633,13936,13934,138,27642,10056,13931,27646,13929,10049,13907,7805,27682,13899,13894,27686,27687,26244,10053,7365,13874,9930,13868,10078,159,13864,16583,16582,4161,211,16576,16572,16569,27724,16564,16563,27728,10080,26826,2460,16551,26482,10093,21289,3455,10095,3033,4033,10100,2188,27770,274,27756,16538,2120,21267,16537,16534,16467,86,27773,27774,27775,2995,9540,16427,7822,16398,10087,27814,2918,7829,16366,27864,9613,10201,16354,16251,27813,16249,16247,16244,27821,7781,16240,16238,2008,27830,27833,2505,2597,27879,27843,16232,27838,16231,5119,16227,16225,16224,16222,21081,27846,7872,16212,27862,8006,4754,16201,16194,4765,16193,16190,16189,16187,8222,27885,27886,16161,16183,10273,7884,7889,5047,27931,27942,7881,21424,16158,7893,27920,7913,16146,16145,21408,16144,5166,16132,16129,5167,27943,27944,16125,10065,16115,16114,16112,16110,1037,21456,10346,21459,27983,27985,10362,1763,1746,1218,28142,28002,28000,28004,5114,16075,7937,7934,16073,16074,16072,28020,28022,16071,28024,28025,16064,7790,28033,16028,16024,1122,16007,16002,1318,28067,7882,15994,7940,28075,1481,28074,28076,5225,28077,15983,15978,15974,15964,15955,28089,15950,15945,15940,10425,10428,15935,28102,10439,15933,15928,7817,15930,15925,7933,28114,28116,28117,28118,28119,15918,10445,7978,3541,20978,1696,15891,15886,15881,7265,26260,5229,15876,7796,15837,15828,1473,15823,7917,28172,28174,28176,9869,15807,28187,28190,28193,15794,5249,15788,15783,15781,15779,1358,13,15775,15772,7319,7990,1864,15722,15725,27597,15706,27582,15701,15696,15692,15663,15656,15658,27038,15653,15648,898,15600,26434,15599,15593,15584,15579,15578,27310,27278,15562,15544,15539,20164,15534,15527,10165,27084,26559,15499,15494,26594,15395,15397,7198,27102,15393,1214,865,15247,15242,25755,15237,26957,96,27008,27010,15226,15182,15197,15181,15191,15186,15184,15177,1555,26952,15165,15160,15156,15153,15148,15135,15114,15110,15105,15090,26816,17869,17828,17822,26759,17819,960,17818,1138,26718,17782,17735,17762,17760,17756,17724,17714,17708,17650,25789,17642,17632,17617,17612,17607,17597,17568,17563,17548,858,26489,26491,17536,26478,17525,17519,17515,17511,1201,3,17481,17473,17465,17464,17459,17430,17418,17412,7195,17229,17391,17389,17372,17367,26255,17365,470,26219,17328,17318,17303,2065,688,3035,1671,17279,2953,2011,17267,26149,26137,48,200,17225,17223,14,17205,17201,305,17194,26080,2018,17171,17162,25985,17118,17114,8043,966,25960,4053,287,2212,16924,25897,16919,25877,25874,16863,25857,25859,16853,16818,16760,25804,25806,16678,16669,25726,25759,972,16601,25716,8188,897,99,16588,25655,25656,568,2725,5089,25636,993,25608,4435,4491,25544,4479,7991,5311,7986,4461,5342,7970,5324,7886,4396,7869,8007,8005,10558,8019,5382,8008,8028,7730,4465,8017,8024,1020,5344,8001,7673,4448,5410,7948,7910,5108,10704,10676,8068,10662,8079,5427,10734,5340,5469,4437,5479,5487,8047,8090,8071,3291,7890,8022,8102,8097,5471,8073,8112,8021,7216,4903,7935,8117,5534,8114,8128,5539,5512,5543,8126,5153,8052,8152,5279,4671,8148,8013,8045,5584,5594,3452,8161,8158,5588,7977,5475,8141,8164,8175,4381,4349,8200,8230,8242,8240,8252,8245,8226,8293,8271,4336,8298,8322,8310,8264,8315,8327,8265,8276,7938,8338,8376,8326,8378,8016,8387,8389,8420,8414,8411,8426,8436,8462,8468,8359,8448,8466,8471,17930,8498,8488,8565,8418,4327,6711,8545,8472,8558,6091,8085,8497,5869,8560,8573,4299,8606,8612,4296,8630,4294,8626,8600,8650,8623,4289,8474,8682,8678,8629,8660,8715,8706,8692,8538,4266,8150,8762,8636,8776,8525,8749,8745,6102,8595,18087,4245,8800,675,8833,8836,4242,8737,8871,8874,17891,8535,8802,8244,8879,8830,8911,8847,8892,8915,8935,8931,8828,8239,8923,8893,8891,8862,8943,8975,8990,8846,8989,9027,8747,8936,7874,4194,9014,8861,9168,9079,9184,9206,9209,8647,4166,9172,9212,9241,9249,9233,5076,3263,9210,9271,9276,5604,9033,18187,9328,9261,9333,9340,9370,8822,9280,9376,9404,9439,18206,4114,9464,9428,9364,9458,9480,9421,9488,9463,9385,4106,1032,9506,6422,9555,9549,4096,9561,9423,9539,9590,9553,4093,9572,9476,9614,9557,9620,9583,9636,9621,4087,9640,9650,9644,9643,9661,4064,9518,9672,9655,3261,4050,9730,9720,4044,9721,9764,4042,4017,2202,3635,18741,3632,9742,2952,1420,9771,9791,9797,9699,9800,9656,9812,9798,3626,9827,9710,9609,9839,9660,9845,9866,9907,9910,9914,9927,9883,3605,9635,9310,9833,10022,10017,9891,10058,10084,10014,10102,3535,3534,10108,10305,10091,9247,3494,10208,10051,19214,10163,3483,10168,10213,8718,10229,18632,1152,10198,10240,10275,10260,3473,660,10278,3463,10115,3444,10301,3429,3404,3402,3355,3289,3285,8171,3252,3186,3158,3141,3117,3105,3098,3099,3074,3068,2981,2963,14423,2957,2942,2927,2833,2801,2755,2744,2734,14481,2685,2674,2647,7228,16950,2361,1834,1667,1417,1221,1159,5818,1116,8163,1048,8156,7577,6935,8132,6936,4407,19217,8107,831,818,722,480,476,402,8106,352,377,321,314,270,19270,255,4494,4498,10529,4523,19454,7400,7520,19373,4524,4528,4573,4575,7565,4588,4621,271,4631,7688,4656,4663,4667,4499,4690,5964,4734,4736,4779,4783,15127,4854,4855,4870,4887,4893,4905,4906,4909,4934,4320,4307,15416,4211,4140,4132,4477,4434,3426,4961,6068,4993,5001,6078,5006,3138,5042,4559,5049,4560,5088,5092,5100,5122,5126,5150,16636,5246,5256,5261,5264,5276,5289,5303,5308,5312,5325,19879,4583,5377,5379,5409,5419,4585,5461,5514,5528,5532,5540,5545,5567,5569,5579,4598,5585,5595,5599,5601,4436,5608,5609,5610,5611,5623,17325,4605,4606,5635,5637,5639,5643,5645,5652,5669,5670,4609,10206,5675,5678,5681,5686,5707,5724,5717,5720,5722,5730,5731,5738,5736,5741,5751,5754,5759,5763,5776,5781,4648,5793,5803,5805,5807,5816,5822,5830,5834,5852,5853,5868,5873,5882,5894,4668,2912,5899,5903,3354,5916,5921,5926,4678,5932,19817,5934,5936,5943,4684,5952,5958,4338,5961,19828,4685,5986,5988,5008,4403,6440,7706,6446,10131,6472,4753,4755,4763,18868,20137,6609,4767,19804,6509,4770,4772,5009,6941,6549,7323,6573,18191,4792,4795,13845,6591,6597,4810,6607,6626,5014,5015,19730,6651,5024,19713,6671,19731,4848,4343,6688,4850,6722,7267,6745,6741,19703,6758,6767,19671,6768,19665,6772,6776,19672,6788,4661,6801,6803,6817,4865,19658,6842,4952,6865,6878,4879,19622,4954,4880,19615,6916,6933,4889,6951,6963,3639,19568,4896,4897,6990,6995,6993,7012,4908,7016,18640,9071,19499,9447,7033,7045,9929,4949,8674,7100,7102,18728,8922,4485,9234,8053,8044,19388,4422,7141,19375,4226,4483,13384,9631,4458,9731,147,7171,5998,6005,6007,10653,6010,6014,7441,6018,6019,6026,10525,6032,6036,6039,6042,4405,7476,6145,6141,6130,7523,4278,10695,7533,6126,145,7543,6119,7567,6116,6110,6106,4112,4081,6081,6079,6075,6070,6058,7638,7642,6256,6052,10686,3651,7698,6251,6255,6252,7736,6250,6246,7753,6244,6242,6238,6232,6230,6225,6217,6216,6213,6211,6207,6206,7915,10570,18872,7982,7997,6196,6184,6175,3250,3224,6171,6170,6164,6161,3341,6157,6340,6361,5859,6353,6349,6346,6345,6344,6333,6332,6327,6325,6320,6317,6311,6307,3627,3111,6305,6302,6299,6293,6291,6283,6279,6278,6275,7390,6274,2349,6272,6269,7402,7380,7375,7374,7373,7360,7352,7343,7320,7335,7332,7324,7322,7315,7303,7299,7295,7290,7288,7287,6508,7285,4401,7283,7282,7274,3136,7268,7266,7264,7260,3083,7077,7247,7245,7240,7221,7220,7210,7182,7205,7192,7191,7185,7176,7174,7170,7165,7163,7155,7154,7151,7149,7148,7140,7138,7131,7116,7115,5897,7101,7091,7087,7081,7053,7046,7037,7035,7020,7017,6999,6985,6956,6978,6975,6967,6960,6948,6947,6945,6931,6929,6926,6923,6921,6918,6915,6913,6873,6908,6907,6906,6901,6893,6891,6882,6881,6880,6858,6852,6841,6836,6828,6827,6816,6815,6810,6804,6854,5912,6784,6764,6715,6755,6748,8686,6706,5923,6733,6728,6705,6696,6554,6681,6868,6669,6869,6646,6634,6623,6874,6616,6612,6611,6603,6876,6579,6575,6559,6548,6544,6533,6532,6527,6520,6514,4758,6500,6496,5975,6484,6482,6478,6464,17055,6884,6459,6456,2779,6442,5989,5990,6888,6429,4838,6413,6396,6404,6012,6392,6895,6896,4899,6898,6025,8422,8405,8392,8381,8380,8367,8365,4999,4963,5040,8023,8020,8199,4292,2723,4958,8025,8018,4311,9906,4172,10312,7348,7331,5041,10422,5117,10456,5160,5165,7507,5221,5236,7669,7605,3343,6730,7648,5259,7664,7702,5298,5304,5306,7703]
    overseer = Overseer.find_by_email('devang.shah@bulkmro.com')

    Inquiry.where(inquiry_number: inquiries).update_all(sales_manager_id: overseer.id)
    [inquiries.count, Inquiry.where(inquiry_number: inquiries).count]
  end

end
