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
    inquiries.each do |inquiry|
      inquiry.last_synced_quote.update_attribute(:remote_uid, inquiry.quotation_uid)
    end
  end

  def add_completed_po_to_material_followup_queue

    PoRequest.all.includes(:purchase_order).where.not(purchase_order_id: nil).each do |po_request|
      current_overseer = Overseer.where(email: 'approver@bulkmro.com').last
      purchase_order = po_request.purchase_order
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
                overseer: current_overseer,
                inquiry: purchase_order.inquiry,
                purchase_order: purchase_order,
                sales_order: purchase_order.po_request.sales_order,
                email_type: 'Sending PO to Supplier'
            )
            email_message.assign_attributes(from: current_overseer.email, to: current_overseer.email, subject: "Internal Ref Inq ##{purchase_order.inquiry.inquiry_number} Purchase Order ##{purchase_order.po_number}")
            email_message.save!
          end
        end
      else
        puts "po request not available for #{purchase_order.po_number}"
      end
    end
  end
end
