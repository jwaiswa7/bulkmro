class Services::Shared::Migrations::CategoriesActivate < Services::Shared::Migrations::Migrations
  def activate_category
    service = Services::Shared::Spreadsheets::CsvImporter.new('final_categories.csv', 'seed_files')
    service.loop do |row|
      parent_category_name = row.get_column('Category')
      middle_category_name = row.get_column('sub_cat_1')
      last_category_name = row.get_column('sub_cat_2')
      is_service = row.get_column('product_service').downcase == "product" ? false : true
      parent_category = Category.find_by_name(parent_category_name)
      if parent_category.present?
        if parent_category.is_service != is_service
          parent_category.update_attributes(is_service: is_service, is_active: true)
        end
        middle_category = Category.where(parent_id: parent_category.id, name: middle_category_name).last
        category_activation(middle_category, is_active: true, is_service: is_service)
        if middle_category.present?
          last_category = Category.where(parent_id: middle_category.id, name: last_category_name).last
          category_activation(last_category, is_active: true, is_service: is_service)
        end
      end
    end
  end

  def category_activation(cat, is_active: true, is_service: false)
    if cat.present?
      cat.is_active = true
      cat.is_service = is_service
      cat.save_and_sync
    end
  end
end