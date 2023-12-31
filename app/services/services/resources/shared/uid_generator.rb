class Services::Resources::Shared::UidGenerator < Services::Shared::BaseService
  def self.inquiry_number
    # Generates in Postgres sequences
  end

  def self.company_uid(record)
    record.is_supplier? ? "SC-#{record.id + 200000}" : "#{record.id + 200000}"
  end

  def self.address_uid(record)
    "A#{record.id + 200000}"
  end

  def self.product_sku(unpersisted_skus=[])
    length = 4

    15.times do |i|
      sku = generate_sku(length + (i / 5).to_i)
      if (Product.unscoped.find_by_sku(sku).blank? || Product.unscoped.find_by_sku(sku).not_approved?) && !unpersisted_skus.include?(sku)
        return sku
      end
    end
  end

  def self.generate_sku(length)
    alphabets = [*'A'..'Z']
    numbers = [*'0'..'9']

    sku_characters = %w(B M 9)

    length.times do |i|
      if i % 2 == 0
        sku_characters.push(alphabets.sample)
      else
        sku_characters.push(numbers.sample)
      end
    end

    sku_characters.join
  end

  def self.online_order_number(id)
    (id + 100000)
  end

  def self.generate_dc_number(id)
    current_year = Date.today.year % 100
    next_year = Date.today.next_year.year % 100
    previous_record = DeliveryChallan.where.not(delivery_challan_number: nil).last
    if previous_record
      if previous_record.delivery_challan_number.present?
        series = previous_record.delivery_challan_number.scan(/\d+/)&.first&.to_i + 1
        "DC-#{series}/#{current_year}-#{next_year}"
      end
    else
      "DC-101/#{current_year}-#{next_year}"
    end
  end

  def self.generate_activity_number
    previous_record = Activity.where.not(activity_number: nil).last
    if previous_record
        series = previous_record.activity_number.scan(/\d+/)&.first&.to_i + 1
        "AC#{series}"
    else
      "AC1"
    end
  end

  def self.generate_task_number(id)
    current_year = Date.today.year % 100
    current_month = Date.today.month % 100
    previous_record = Task.where.not(task_id: nil).last
    if previous_record
      if previous_record.task_id.present?
        series = "%03d" % (previous_record.task_id.from(4).to_i + 1)
        if current_month > 9
          "#{current_year}#{current_month}#{series}"
        else
          "#{current_year}0#{current_month}#{series}"
        end
      end
    else
      if current_month > 9
        "#{current_year}#{current_month}001"
      else
        "#{current_year}0#{current_month}001"
      end
    end
  end

  attr_accessor :sales_quote
end
