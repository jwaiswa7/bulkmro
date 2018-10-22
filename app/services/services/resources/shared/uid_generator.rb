class Services::Resources::Shared::UidGenerator < Services::Shared::BaseService

  def self.inquiry_number
    # Generates in Postgres sequences
  end

  def self.company_uid
    "#{(Company.maximum(:id) || 0) + 10000}"
  end

  def self.address_uid
    "A#{(Address.maximum(:id) || 0) + 10000}"
  end

  def self.product_sku(unpersisted_skus=[])
    length = 4

    15.times do |i|
      sku = generate_sku(length + (i / 5).to_i)
      if (Product.find_by_sku(sku).blank? || Product.find_by_sku(sku).not_approved?) && !unpersisted_skus.include?(sku)
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

  attr_accessor :sales_quote
end