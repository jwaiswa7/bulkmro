class Services::Shared::Migrations::MigrationsV2 < Services::Shared::Migrations::Migrations
  def fetch_csv(filename, csv_data)
    overseer = Overseer.find(197)
    temp_file = File.open(Rails.root.join('tmp', filename), 'wb')

    begin
      temp_file.write(csv_data)
      temp_file.close
      overseer.file.attach(io: File.open(temp_file.path), filename: filename)
      overseer.save!
      puts Rails.application.routes.url_helpers.rails_blob_path(overseer.file, only_path: true)
    rescue => ex
      puts ex.message
    end
  end

  def create_ifsc_code
    service = Services::Shared::Spreadsheets::CsvImporter.new('ifsc_code_list.csv', 'seed_files')
    service.loop(nil) do |x|
      Chewy.strategy(:bypass) do
        IfscCode.where(ifsc_code: x.get_column('IFSC')).first_or_create do |ifsc|
          ifsc.bank_id = Bank.where(name: x.get_column('BANK')).present? ? Bank.where(name: x.get_column('BANK')).last.id : nil
          ifsc.branch = x.get_column('BRANCH')
          ifsc.address = x.get_column('ADDRESS')
          ifsc.city = x.get_column('CITY')
          ifsc.district = x.get_column('DISTRICT')
          ifsc.contact = x.get_column('CONTACT')
          ifsc.state = x.get_column('STATE')
        end
      end
    end
  end

  def missing_bible_orders
    column_headers = ['inquiry_number', 'order_number']
    i = 0
    service = Services::Shared::Spreadsheets::CsvImporter.new('2019-05-02 Bible Data for Migration.csv', 'seed_files_3')
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |csv|
      service.loop(nil) do |x|
        order_number = x.get_column('So #')
        if order_number.include?('.') || order_number.include?('/') || order_number.include?('-') || order_number.match?(/[a-zA-Z]/)
          sales_order = SalesOrder.find_by_old_order_number(x.get_column('So #'))
          if sales_order.blank?
            csv << [x.get_column('Inquiry Number'), x.get_column('So #')]
          end
          i = i + 1
          puts "line #{i}, SO #{x.get_column('So #')}"
        end
      end
    end

    fetch_csv('bible_missing_orders.csv', csv_data)
  end

  def sap_sales_order_totals_mismatch
    column_headers = ['order_number', 'sprint_total', 'sprint_total_with_tax', 'sap_total', 'sap_total_with_tax']

    service = Services::Shared::Spreadsheets::CsvImporter.new('latest_sap_so.csv', 'seed_files_3')
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      service.loop(nil) do |x|
        sales_order = SalesOrder.find_by_order_number(x.get_column('#')) || SalesOrder.find_by_old_order_number(x.get_column('#'))
        sap_total_without_tax = x.get_column('Document Total').to_f - x.get_column('Tax Amount (SC)').to_f

        if sales_order.present?
          actual_total = sales_order.calculated_total.to_f
          actual_total_with_tax = sales_order.calculated_total_with_tax.to_f

          if ((actual_total != sap_total_without_tax) || (actual_total_with_tax != x.get_column('Document Total').to_f)) &&
              ((actual_total - sap_total_without_tax).abs > 1 || (actual_total_with_tax - x.get_column('Document Total').to_f).abs > 1)
            writer << [sales_order.order_number, actual_total, actual_total_with_tax, sap_total_without_tax, x.get_column('Document Total').to_f]
          end
        end
      end
    end

    fetch_csv('sales_orders_total_mismatch.csv', csv_data)
  end

  def bible_sales_order_totals_mismatch
    column_headers = ['inquiry_number', 'order_number', 'SKU', 'sprint_total', 'sprint_total_with_tax', 'bible_total', 'bible_total_with_tax']
    skipped_skus = []
    service = Services::Shared::Spreadsheets::CsvImporter.new('2019-05-02 Bible Data for Migration.csv', 'seed_files_3')
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      service.loop(nil) do |x|
        bible_order_row_total = x.get_column('Total Selling Price').to_f
        bible_order_tax_total = x.get_column('Tax Amount').to_f
        bible_order_row_total_with_tax = bible_order_row_total + bible_order_tax_total

        sales_order = SalesOrder.find_by_old_order_number(x.get_column('So #')) || SalesOrder.find_by_order_number(x.get_column('So #').to_i)
        if sales_order.present?
          product_sku = x.get_column('Bm #').to_s

          if sales_order.rows.map {|r| r.product.sku}.include?(product_sku)
            order_row = sales_order.rows.joins(:product).where('products.sku = ?', product_sku).first
            row_total = order_row.total_selling_price
            row_total_with_tax = order_row.total_selling_price_with_tax

            if ((row_total != bible_order_row_total) || (row_total_with_tax != bible_order_row_total_with_tax)) &&
                ((row_total - bible_order_row_total).abs > 1 || (row_total_with_tax - bible_order_row_total_with_tax).abs > 1)
              writer << [x.get_column('Inquiry Number'), sales_order.order_number, product_sku, row_total, row_total_with_tax, bible_order_row_total, bible_order_row_total_with_tax]
            end
          else
            if !(skipped_skus.include?(x.get_column('Bm #')) && skipped_skus.include?(x.get_column('So #')))
              skipped_skus.push(x.get_column('Bm #') + '-' + x.get_column('So #'))
            end
          end
        end
      end
      puts 'SKIPPED SKUs', skipped_skus
    end

    fetch_csv('bible_sales_orders_total_mismatch.csv', csv_data)
  end

  def missing_sap_purchase_orders
    column_headers = ['inquiry', 'po_number']

    service = Services::Shared::Spreadsheets::CsvImporter.new('latest_sap_po.csv', 'seed_files_3')
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      service.loop(nil) do |x|
        purchase_order = PurchaseOrder.find_by_po_number(x.get_column('#').to_i) || PurchaseOrder.find_by_old_po_number(x.get_column('#').to_i)
        if purchase_order.blank?
          writer << [x.get_column('Project'), x.get_column('#')]
        end
      end
    end

    fetch_csv('sap_missing_po.csv', csv_data)
  end

  def purchase_order_totals_mismatch
    column_headers = ['PO_number', 'sprint_total', 'sprint_total_with_tax', 'sap_total', 'sap_total_with_tax', 'is_legacy']
    service = Services::Shared::Spreadsheets::CsvImporter.new('latest_sap_po.csv', 'seed_files_3')
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      service.loop(nil) do |x|
        purchase_order = PurchaseOrder.find_by_po_number(x.get_column('#')) || PurchaseOrder.find_by_old_po_number(x.get_column('#'))
        if purchase_order.present? &&
            ((purchase_order.calculated_total_with_tax.to_f != x.get_column('Document Total').to_f) || (purchase_order.calculated_total.to_f != (x.get_column('Document Total').to_f - x.get_column('Tax Amount (SC)').to_f).to_f)) &&
            ((purchase_order.calculated_total_with_tax.to_f - x.get_column('Document Total').to_f).abs > 1 || (purchase_order.calculated_total.to_f - (x.get_column('Document Total').to_f - x.get_column('Tax Amount (SC)').to_f).to_f).abs > 1)
          writer << [purchase_order.po_number, purchase_order.calculated_total.to_f, purchase_order.calculated_total_with_tax.to_f, (x.get_column('Document Total').to_f - x.get_column('Tax Amount (SC)').to_f), x.get_column('Document Total').to_f, purchase_order.is_legacy?]
        end
        # if !purchase_order.present?
        #   writer << [x.get_column('Po number'), x.get_column('Date'), x.get_column('Project'), x.get_column('Document Total'), x.get_column('Project Code'),x.get_column('Tax Amount (SC)'),x.get_column('Canceled')]
        # end
      end
    end

    fetch_csv('purchase_orders_total_mismatch.csv', csv_data)
  end

  def missing_sap_invoices
    column_headers = ['invoice_number']

    service = Services::Shared::Spreadsheets::CsvImporter.new('latest_sap_invoices.csv', 'seed_files_3')
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      service.loop(nil) do |x|
        sales_invoice = SalesInvoice.find_by_invoice_number(x.get_column('#')) || SalesInvoice.find_by_old_invoice_number(x.get_column('#'))
        if sales_invoice.blank?
          writer << [x.get_column('#')]
        end
      end
    end

    fetch_csv('sap_missing_invoices.csv', csv_data)
  end

  def sap_sales_invoice_totals_mismatch
    column_headers = ['invoice_number', 'sprint_total', 'sprint_tax', 'sprint_total_with_tax', 'sap_total', 'sap_tax', 'sap_total_with_tax']

    service = Services::Shared::Spreadsheets::CsvImporter.new('latest_sap_invoices.csv', 'seed_files_3')
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      service.loop(nil) do |x|
        sales_invoice = SalesInvoice.find_by_invoice_number(x.get_column('#'))
        sap_total_without_tax = 0
        total_without_tax = 0

        if sales_invoice.present? && !sales_invoice.is_legacy?
          total_without_tax = sales_invoice.metadata['base_grand_total'].to_f - sales_invoice.metadata['base_tax_amount'].to_f
          sap_total_without_tax = x.get_column('Document Total').to_f - x.get_column('Tax Amount (SC)').to_f
          if (total_without_tax != sap_total_without_tax) || (sales_invoice.metadata['base_grand_total'].to_f != x.get_column('Document Total').to_f) &&
              ((total_without_tax - sap_total_without_tax).abs > 1 || (sales_invoice.metadata['base_grand_total'].to_f - x.get_column('Document Total').to_f).abs > 1)

            writer << [
                sales_invoice.invoice_number,
                total_without_tax,
                sales_invoice.metadata['base_tax_amount'].to_f,
                sales_invoice.metadata['base_grand_total'].to_f,
                sap_total_without_tax,
                x.get_column('Tax Amount (SC)').to_f,
                x.get_column('Document Total')
            ]
          end
        end
      end
    end

    fetch_csv('sap_invoices_totals_mismatch.csv', csv_data)
  end

  # main
  def complete_bible_orders_mismatch_with_dates
    column_headers = ['inquiry_number', 'client order date', 'order_number', 'old_order_number', 'order date', 'SKU', 'sprint_total', 'sprint_total_with_tax', 'bible_total', 'bible_total_with_tax', 'kit order', 'adjustment entry']
    matching_orders = []
    adjustment_entries = []
    matching_rows_total = 0
    matching_bible_rows = 0
    ae_amount = 0

    service = Services::Shared::Spreadsheets::CsvImporter.new('2019-05-02 Bible Data for Migration.csv', 'seed_files_3')
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      service.loop(nil) do |x|
        is_adjustment_entry = 'No'
        order_number = x.get_column('So #')
        bible_order_row_total = x.get_column('Total Selling Price').to_f
        bible_order_tax_total = x.get_column('Tax Amount').to_f
        bible_order_row_total_with_tax = bible_order_row_total + bible_order_tax_total

        if order_number.include?('.') || order_number.include?('/') || order_number.include?('-') || order_number.match?(/[a-zA-Z]/)
          sales_order = SalesOrder.find_by_old_order_number(order_number)
        else
          sales_order = SalesOrder.find_by_order_number(order_number.to_i)
        end

        if sales_order.present?
          product_sku = x.get_column('Bm #').to_s

          if sales_order.rows.map {|r| r.product.sku}.include?(product_sku)
            order_row = sales_order.rows.joins(:product).where('products.sku = ?', product_sku).first
            row_total = order_row.total_selling_price
            row_total_with_tax = order_row.total_selling_price_with_tax

            if ((row_total != bible_order_row_total) || (row_total_with_tax != bible_order_row_total_with_tax)) &&
                ((row_total - bible_order_row_total).abs > 1 || (row_total_with_tax - bible_order_row_total_with_tax).abs > 1)

              # adjustment entries
              if (row_total == -(bible_order_row_total)) && (row_total_with_tax == -(bible_order_row_total_with_tax))
                adjustment_entries.push(x.get_column('Bm #') + '-' + x.get_column('So #'))
                ae_amount = ae_amount + row_total_with_tax
                is_adjustment_entry = 'Yes'
              end

              # KIT check
              if sales_order.calculated_total.to_f == bible_order_row_total &&
                  sales_order.calculated_total_with_tax.to_f == bible_order_row_total_with_tax
                writer << [x.get_column('Inquiry Number'), x.get_column('Client Order Date'), sales_order.order_number, sales_order.old_order_number || 'nil', x.get_column('Order Date'), product_sku, row_total, row_total_with_tax, bible_order_row_total, bible_order_row_total_with_tax, 'Yes', is_adjustment_entry]
              else
                writer << [x.get_column('Inquiry Number'), x.get_column('Client Order Date'), sales_order.order_number, sales_order.old_order_number || 'nil', x.get_column('Order Date'), product_sku, row_total, row_total_with_tax, bible_order_row_total, bible_order_row_total_with_tax, 'No', is_adjustment_entry]
              end
            else
              matching_bible_rows = matching_bible_rows + bible_order_row_total_with_tax
              matching_rows_total = matching_rows_total + row_total_with_tax
              matching_orders.push(x.get_column('So #'))
            end
          end
        end
      end
      puts 'Matching orders uniq', matching_orders.uniq.count
      puts 'Matching orders', matching_orders.count
      puts 'Totals(Bible, sprint)', matching_bible_rows.to_f, matching_rows_total.to_f
      puts 'Adjustment entries', adjustment_entries
      puts 'AE amount', ae_amount.to_f
    end

    fetch_csv('first_total_mismatch.csv', csv_data)
  end

  def update_mismatching_non_kit_orders
    mismatching_non_kit_orders = ['201996', '202007', '202038', '202090', '2000015', '2000016', '2000041', '2000110', '2000144', '2000152', '2000170', '2000180', '2000228', '2000238', '2000262', '2000271', '2000272', '2000277', '2000279', '2000280', '2000299', '2000300', '2000318', '2000322', '2000327', '2000347', '2000355', '2000359', '2000360', '2000361', '2000362', '2000363', '2000364', '2000410', '2000411', '2000414', '2000426', '2000428', '2000431', '2000441', '2000451', '2000454', '2000455', '2000462', '2000466', '2000467', '2000468', '2000469', '2000470', '2000471', '2000480', '2000481', '2000482', '2000489', '2000490', '2000493', '2000495', '2000497', '2000510', '2000520', '2000521', '2000522', '2000524', '2000526', '2000527', '2000528', '2000530', '2000532', '2000533', '2000534', '2000536', '2000540', '2000543', '2000584', '2000585', '2000587', '2000588', '2000589', '2000597', '2000599', '2000604', '2000611', '2000614', '2000615', '2000616', '2000623', '2000624', '2000625', '2000629', '2000633', '2000634', '2000640', '2000644', '2000653', '2000654', '2000664', '2000665', '2000666', '2000667', '2000668', '2000671', '2000672', '2000673', '2000674', '2000676', '2000677', '2000679', '2000682', '2000683', '2000684', '2000685', '2000690', '2000696', '2000698', '2000700', '2000701', '2000702', '2000706', '2000719', '2000725', '2000749', '2000779', '2000823', '2000840', '2000942', '2001077', '2001133', '2001189', '2001250', '2001266', '2001279', '2001292', '2001307', '2001311', '2001319', '2001336', '2001345', '2001354', '2001363', '2001373', '2001661', '2001676', '2001677', '2001696', '2001707', '2001776', '2001777', '2001795', '2001798', '2001817', '2001818', '2001853', '2001865', '2001868', '2001873', '2001884', '2001892', '2001940', '2001978', '2002000', '2002012', '2002019', '2002044', '2002062', '2002077', '2002087', '2002107', '2002139', '2002158', '2002200', '2002203', '2002215', '2002230', '2002257', '2002270', '2002271', '2002272', '2002276', '2002435', '2002459', '2002531', '2002571', '2002572', '2002586', '2002599', '2002609', '2002663', '2002686', '2002689', '2002812', '2002944', '2002965', '2003055', '2003058', '2003066', '2003083', '2003085', '2003105', '2003120', '2003271', '2003287', '2003308', '2003411', '2003535', '2003550', '2003552', '2003564', '2003641', '10200023', '10200024', '10200074', '10200085', '10200086', '10200101', '10200106', '10200146', '10200175', '10200177', '10200203', '10200204', '10200205', '10200206', '10200216', '10200233', '10200237', '10210027', '10210031', '10210032', '10210033', '10210049', '10210062', '10210074', '10210084', '10210125', '10210128', '10210139', '10210145', '10210150', '10210151', '10210161', '10210163', '10210198', '10210199', '10210214', '10210216', '10210226', '10210245', '10210251', '10210278', '10210294', '10210294', '10210295', '10210296', '10210301', '10210301', '10210314', '10210316', '10210316', '10210335', '10210348', '10210350', '10210353', '10210365', '10210389', '10210391', '10210399', '10210403', '10210406', '10210425', '10210453', '10210453', '10210453', '10210453', '10210453', '10210453', '10210454', '10210460', '10210461', '10210462', '10210462', '10210469', '10210471', '10210485', '10210486', '10210491', '10210494', '10210528', '10210532', '10210537', '10210544', '10210559', '10210560', '10210564', '10210566', '10210575', '10210580', '10210583', '10210586', '10210603', '10210604', '10210605', '10210606', '10210607', '10210608', '10210609', '10210611', '10210614', '10210615', '10210617', '10210630', '10210645', '10210662', '10210670', '10210671', '10210672', '10210673', '10210681', '10210690', '10210694', '10210696', '10210698', '10210707', '10210709', '10210716', '10210726', '10210736', '10210761', '10210765', '10210766', '10210766', '10210771', '10210789', '10210792', '10210794', '10210796', '10210799', '10210803', '10210810', '10210811', '10210826', '10210831', '10210846', '10210856', '10210857', '10210875', '10210891', '10210896', '10210897', '10210903', '10210904', '10210911', '10210915', '10210915', '10210919', '10210921', '10210935', '10210958', '10210962', '10210970', '10210971', '10210975', '10210979', '10210980', '10210981', '10210987', '10210992', '10210993', '10210998', '10211002', '10211012', '10211013', '10211019', '10211021', '10211023', '10211024', '10211043', '10211046', '10211048', '10211049', '10211050', '10211074', '10211103', '10211107', '10211111', '10211118', '10211131', '10211132', '10211133', '10211179', '10211189', '10211235', '10211258', '10211295', '10211456', '10211550', '10211553', '10211560', '10211566', '10211569', '10211572', '10211737', '10212228', '10300005', '10300006', '10300015', '10300022', '10300024', '10300026', '10300029', '10300030', '10300031', '10300034', '10300036', '10300037', '10300048', '10300052', '10300053', '10300054', '10300059', '10300065', '10300067', '10300068', '10300071', '10300076', '10400009', '10610009', '10610010', '10610037', '10610047', '10610052', '10610066', '10610082', '10610090', '10610094', '10610103', '10610107', '10610111', '10610118', '10610136', '10610143', '10610147', '10610147', '10610150', '10610187', '10610195', '10610198', '10610202', '10610207', '10610212', '10610218', '10610239', '10610241', '10610254', '10610255', '10610274', '10610278', '10610287', '10610306', '10610318', '10610342', '10610345', '10610348', '10610363', '10610370', '10610383', '10610383', '10610302', '10610389', '10610410', '10610423', '10610427', '10610428', '10610432', '10610433', '10610435', '10610465', '10610472', '10610498', '10610509', '10610874', '10710005', '10910022', '10910022', '10910035', '10910036', '10910039', '10910044', '10910064', '10910067', '10910069', '10910070', '10910071', '10910074', '10910087', '10910088', '10910096', '10910109', '10910110', '10910115', '10910123', '10910128', '10910129', '10910145', '10910152', '11210010', '11210027', '11210030', '11210033', '11210038', '11210039', '11210041', '11210045', '11210046', '11210060', '11210062', '11210065', '11210066', '11210075', '11210079', '11210081', '11410013', '11410018', '11410018', '11410026', '99999001', '99999003', '99999004', '99999007', '99999012', '99999013', '99999036', '99999038', '99999039', '99999053', '99999055', '99999063', '99999088', '99999089', '2000134-1', '2000179-1', '2000315-1', '2000380-2', '2000387-1', 'Order1', 'Order2']

    correctly_updating_orders = ['2000041', '2000271', '2000347', '2000363', '2000364', '2000414', '2000431', '2000451', '2000454', '2000510', '2000526', '2000540', '2000543', '2000640', '2000719', '2000779', '2001077', '2001266', '2001279', '2001292', '2001307', '2001311', '2001311', '2001319', '2001345', '2001363', '2001696', '2001776', '2001798', '2001818', '2001865', '2001978', '2002000', '2002200', '2002272', '2002435', '2002586', '2002609', '2002944', '2003271', '2003641', '10200074', '10200177', '10200205', '10200206', '10210027', '10210049', '10210062', '10210074', '10210084', '10210125', '10210145', '10210151', '10210161', '10210198', '10210199', '10210216', '10210278', '10210294', '10210294', '10210295', '10210296', '10210301', '10210314', '10210316', '10210316', '10210460', '10210559', '10210560', '10210580', '10210609', '10210614', '10210615', '10210617', '10210630', '10210645', '10210670', '10210673', '10210681', '10210690', '10210696', '10210707', '10210736', '10210794', '10210810', '10210856', '10210857', '10210897', '10210904', '10210911', '10210919', '10210921', '10210935', '10210962', '10210970', '10210980', '10210987', '10210992', '10211012', '10211024', '10211043', '10211103', '10211179', '10211189', '10211295', '10211550', '10211553', '10211560', '10211566', '10211569', '10211572', '10211737', '10300015', '10300024', '10300030', '10300036', '10300053', '10300068', '10610052', '10610066', '10610082', '10610136', '10610150', '10610239', '10610254', '10610274', '10610287', '10610306', '10610410', '10610423', '10610428', '10610435', '10610874', '10910036', '10910039', '10910067', '10910069', '10910070', '10910088', '10910110', '10910110', '10910129', '11210010', '11210027', '11210033', '11210038', '11210060', '11210066', '99999003', '99999004', '99999007', '99999012', '99999053', '99999055', '99999063']
    service = Services::Shared::Spreadsheets::CsvImporter.new('2019-05-02 Bible Data for Migration.csv', 'seed_files_3')
    has_vat = []
    updated_orders = []
    updated_orders_total = 0
    bible_total = 0
    i = 0
    service.loop(nil) do |x|
      order_number = x.get_column('So #')
      if mismatching_non_kit_orders.include?(order_number) && correctly_updating_orders.include?(order_number)
        if x.get_column('Tax Type').include?('VAT') || x.get_column('Tax Type').include?('CST')
          has_vat.push(order_number)
        end
        next if x.get_column('Tax Type').include?('VAT') || x.get_column('Tax Type').include?('CST')

        if order_number.include?('.') || order_number.include?('/') || order_number.include?('-') || order_number.match?(/[a-zA-Z]/)
          sales_order = SalesOrder.find_by_old_order_number(order_number)
        else
          sales_order = SalesOrder.find_by_order_number(order_number.to_i)
        end
        if sales_order.present?
          product_sku = x.get_column('Bm #').to_s

          if sales_order.rows.map {|r| r.product.sku}.include?(product_sku)
            order_row = sales_order.rows.joins(:product).where('products.sku = ?', product_sku).first
            quote_row = order_row.sales_quote_row
            tax_rate_percentage = (x.get_column('Tax Rate').to_f / 100)
            tax_rate = TaxRate.where(tax_percentage: tax_rate_percentage).first

            bible_order_row_total = x.get_column('Total Selling Price').to_f
            bible_order_tax_total = x.get_column('Tax Amount').to_f
            bible_order_row_total_with_tax = bible_order_row_total + bible_order_tax_total
            row_total = order_row.total_selling_price
            row_total_with_tax = order_row.total_selling_price_with_tax

            next if (row_total == -(bible_order_row_total)) && (row_total_with_tax == -(bible_order_row_total_with_tax))

            quote_row.quantity = x.get_column('Order Qty').to_f if quote_row.quantity == x.get_column('Order Qty').to_f
            quote_row.unit_selling_price = x.get_column('Unit selling Price').to_f
            quote_row.converted_unit_selling_price = x.get_column('Unit selling Price').to_f
            quote_row.margin_percentage = (x.get_column('Margin (In %)').to_f / 100)
            quote_row.tax_rate = tax_rate || nil
            quote_row.legacy_applicable_tax_percentage = tax_rate || nil
            quote_row.created_at = x.get_column('Order Date', to_datetime: true)
            quote_row.save(validate: false)
            puts '****************************** QUOTE ROW SAVED ****************************************'
            quote_row.sales_quote.save(validate: false)
            puts '****************************** QUOTE SAVED ****************************************'

            order_row.quantity = x.get_column('Order Qty').to_f
            order_row.created_at = x.get_column('Order Date', to_datetime: true)
            order_row.save(validate: false)
            puts '****************************** ORDER ROW SAVED ****************************************'
            sales_order.save(validate: false)
            puts '****************************** ORDER SAVED ****************************************'

            # if order_row.total_selling_price.to_f == bible_order_row_total && order_row.total_selling_price_with_tax.to_f == bible_order_row_total_with_tax
            i = i + 1
            puts 'Matched order count', i
            updated_orders.push(x.get_column('Bm #') + '-' + x.get_column('So #'))
            updated_orders_total = updated_orders_total + order_row.total_selling_price_with_tax.to_f
            bible_total = bible_total + bible_order_row_total_with_tax
            # end
          end
        end
      end
    end
    puts 'HAS VAT', has_vat
    puts 'CORRECTLY UPDATED ENTRIES', updated_orders
    puts 'Totals(sprint/bible)', updated_orders_total.to_f, bible_total.to_f
  end

  def set_is_kit_flag_in_mismatch_file
    column_headers = ['inquiry_number', 'client order date', 'order_number', 'old_order_number', 'order date', 'SKU', 'sprint_total', 'sprint_total_with_tax', 'bible_total', 'bible_total_with_tax', 'kit order']
    adjustment_entries = []
    service = Services::Shared::Spreadsheets::CsvImporter.new('updated_order_mismatch_file.csv', 'seed_files_3')
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      service.loop(nil) do |x|
        old_order_number = x.get_column('old_order_number')
        if old_order_number == 'nil'
          sales_order = SalesOrder.find_by_order_number(x.get_column('order_number').to_i)
        else
          sales_order = SalesOrder.find_by_old_order_number(old_order_number)
        end
        bible_order_row_total = x.get_column('bible_total').to_f
        bible_order_row_total_with_tax = x.get_column('bible_total_with_tax').to_f

        if sales_order.present?
          product_sku = x.get_column('SKU').to_s

          if sales_order.rows.map {|r| r.product.sku}.include?(product_sku)
            order_row = sales_order.rows.joins(:product).where('products.sku = ?', product_sku).first
            row_total = order_row.total_selling_price
            row_total_with_tax = order_row.total_selling_price_with_tax

            # mismatch orders
            if ((row_total != bible_order_row_total) || (row_total_with_tax != bible_order_row_total_with_tax)) &&
                ((row_total - bible_order_row_total).abs > 1 || (row_total_with_tax - bible_order_row_total_with_tax).abs > 1)

              # KIT check
              if sales_order.calculated_total.to_f == bible_order_row_total &&
                  sales_order.calculated_total_with_tax.to_f == bible_order_row_total_with_tax
                writer << [x.get_column('inquiry_number'), x.get_column('client order date'), sales_order.order_number, sales_order.old_order_number || 'nil', x.get_column('order date'), product_sku, row_total, row_total_with_tax, bible_order_row_total, bible_order_row_total_with_tax, 'Yes']
              else
                writer << [x.get_column('inquiry_number'), x.get_column('client order date'), sales_order.order_number, sales_order.old_order_number || 'nil', x.get_column('order date'), product_sku, row_total, row_total_with_tax, bible_order_row_total, bible_order_row_total_with_tax, 'No']
              end
            end
          end
        end
      end
    end
    fetch_csv('updated_local_order_mismatch_with_is_kit_flag.csv', csv_data)
  end

  def companies_export
    column_headers = ['Company Name', 'Company Alias', 'industry', 'state_name', 'company_contact', 'email', 'pan', 'company_type', 'Addresses count', 'Contacts count', 'Inquiries count']
    model = Company
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      model.includes({addresses: :state}, :company_contacts, :industry, :account).all.order(name: :asc).each do |record|
        company_name = record.name
        company_alias = record.account.name
        industry = (record.industry.name if record.industry.present?)
        state_name = (record.default_billing_address.present? ? record.default_billing_address.try(:state).try(:name) : record.addresses.first.try(:state).try(:name))
        company_contact = (record.default_company_contact.contact.full_name if record.default_company_contact.present?)
        email = record.email
        pan = record.pan
        company_type = record.company_type
        addresses_count = record.addresses.size
        contacts_count = record.contacts.size
        inquiries_count = record.inquiries.size
        writer << [company_name, company_alias, industry, state_name, company_contact, email, pan, company_type, addresses_count, contacts_count, inquiries_count]
      end
    end

    fetch_csv('companies_export.csv', csv_data)
  end

  def create_bible_orders
    # test_file
    service = Services::Shared::Spreadsheets::CsvImporter.new('2019-05-02 Bible Data for Migration.csv', 'seed_files_3')
    service.loop(nil) do |x|
      bible_total_with_tax = x.get_column('Total Selling Price').to_f + x.get_column('Tax Amount').to_f

      if bible_total_with_tax.negative?
        bible_order = BibleSalesOrder.where(inquiry_number: x.get_column('Inquiry Number').to_i,
                                            order_number: x.get_column('So #'),
                                            client_order_date: x.get_column('Client Order Date'),
                                            is_adjustment_entry: true).first_or_create! do |bible_order|
          bible_order.inside_sales_owner = x.get_column('Inside Sales Name')
          bible_order.company_name = x.get_column('Magento Company Name')
          bible_order.account_name = x.get_column('Company Alias')
          bible_order.currency = x.get_column('Price Currency')
          bible_order.document_rate = x.get_column('Document Rate')
          bible_order.metadata = []
        end
      else
        bible_order = BibleSalesOrder.where(inquiry_number: x.get_column('Inquiry Number').to_i,
                                            order_number: x.get_column('So #'),
                                            client_order_date: x.get_column('Client Order Date')).first_or_create! do |bible_order|
          bible_order.inside_sales_owner = x.get_column('Inside Sales Name')
          bible_order.company_name = x.get_column('Magento Company Name')
          bible_order.account_name = x.get_column('Company Alias')
          bible_order.mis_date = x.get_column('Order Date')
          bible_order.currency = x.get_column('Price Currency')
          bible_order.document_rate = x.get_column('Document Rate')
          bible_order.metadata = []
          bible_order.is_adjustment_entry = false
        end
      end

      if bible_order.present?
        skus_in_order = bible_order.metadata.map {|h| h['sku']}
        puts 'SKU STATUS', skus_in_order.include?(x.get_column('Bm #'))

        order_metadata = bible_order.metadata
        sku_data = {
            'sku': x.get_column('Bm #'),
            'description': x.get_column('Description'),
            'quantity': x.get_column('Order Qty'),
            'freight_tax_type': x.get_column('Freight	Tax Type'),
            'total_landed_cost': x.get_column('Total Landed Cost(Total buying price)').to_f,
            'unit_cost_price': x.get_column('unit cost price').to_f,
            'margin_amount': x.get_column('Margin').to_f,
            'margin_percentage': x.get_column('Margin (In %)'),
            'total_selling_price': x.get_column('Total Selling Price').to_f,
            'tax_rate': x.get_column('Tax Rate'),
            'tax_amount': x.get_column('Tax Amount').to_f,
            'unit_selling_price': x.get_column('Unit selling Price').to_f,
            'order_date': x.get_column('Order Date')
        }
        order_metadata.push(sku_data)
        bible_order.assign_attributes(metadata: order_metadata)
        bible_order.save
      end
    end

    bible_order_total = 0
    bible_order_tax = 0
    bible_order_total_with_tax = 0

    BibleSalesOrder.all.each do |bible_order|
      bible_order.metadata.each do |line_item|
        bible_order_total = bible_order_total + line_item['total_selling_price']
        bible_order_tax = bible_order_tax + line_item['tax_amount']
        bible_order_total_with_tax = bible_order_total_with_tax + bible_order_total + bible_order_tax
        bible_order.update_attributes(order_total: bible_order_total, order_tax: bible_order_tax, order_total_with_tax: bible_order_total_with_tax)
      end
    end
    puts 'BibleSO', BibleSalesOrder.count
  end

  def check_bible_total
    bible_order_total = 0
    BibleSalesOrder.all.each do |bible_order|
      bible_order.metadata.each do |line_item|
        bible_order_total = bible_order_total + line_item['total_selling_price']
      end
    end
    puts 'BIBLE ORDER TOTAL', bible_order_total
  end

  def flex_dump
    column_headers = ['Order Date', 'Order ID', 'PO Number', 'Part Number', 'Account Gp', 'Line Item Quantity', 'Line Item Net Total', 'Order Status', 'Account User Email', 'Shipping Address', 'Currency', 'Product Category', 'Part number Description']
    model = SalesOrder
    fc = []
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      model.joins(:company).where(companies: {id: 1847}).order(name: :asc).each do |order|
        if order.inquiry_currency.currency.id == 2 && order.calculated_total < 75000
          order.rows.each do |record|
            sales_order = record.sales_order
            order_date = sales_order.inquiry.customer_order_date.strftime('%F')
            order_id = sales_order.inquiry.customer_order.present? ? sales_order.inquiry.customer_order.online_order_number : ''
            customer_po_number = sales_order.inquiry.customer_po_number
            part_number = record.product.sku
            account = sales_order.inquiry.company.name

            line_item_quantity = record.quantity
            line_item_net_total = record.total_selling_price.to_s
            sap_status = sales_order.remote_status
            user_email = sales_order.inquiry.customer_order.present? ? sales_order.inquiry.customer_order.contact.email : 'sivakumar.ramu@flex.com'
            shipping_address = sales_order.inquiry.shipping_address
            currency = sales_order.inquiry.inquiry_currency.currency.name
            category = record.product.category.name
            part_number_description = record.product.name

            writer << [order_date, order_id, customer_po_number, part_number, account, line_item_quantity, line_item_net_total, sap_status, user_email, shipping_address, currency, category, part_number_description]
          end
        elsif order.inquiry_currency.currency.id != 2
          fc.push(order.order_number)
        end
      end
      puts 'FC', fc
    end

    fetch_csv('flex_export.csv', csv_data)
  end
end


# order_row.unit_selling_price = x.get_column('Unit selling Price').to_f
# order_row.converted_unit_selling_price = x.get_column('Unit selling Price').to_f
# order_row.margin_percentage = (x.get_column('Margin (In %)').to_f / 100)
# order_row.tax_rate = tax_rate || nil
# order_row.legacy_applicable_tax_percentage = tax_rate || nil


# supplier = Company.acts_as_supplier.find_by_name(x.get_column('supplier')) || Company.acts_as_supplier.find_by_name('Local')
#         inquiry_product_supplier = InquiryProductSupplier.where(supplier_id: supplier.id, inquiry_product: inquiry_product).first_or_create!
#         inquiry_product_supplier.update_attribute('unit_cost_price', x.get_column('unit cost price').to_f)
# row = sales_quote.rows.where(inquiry_product_supplier: inquiry_product_supplier).first_or_initialize

#         row.inquiry_product_supplier.unit_cost_price = x.get_column('unit cost price').to_f
#         row.tax_code = TaxCode.find_by_chapter(x.get_column('HSN code')) if row.tax_code.blank?
#         row.save!
#

# order_row = sales_order.rows.joins(:product).where('products.sku = ?', product_sku).first
