module PipelineHelper
  def get_pipeline_entry(entries, *attributes)
    if entries[attributes[0]].present? && entries[attributes[0]][attributes[1].name].present?
      entries[attributes[0]][attributes[1].name]
    else
      0
    end
  end

  def get_sum_of_entries(entries_array)
    entries_array.inject(0){|sum,x| sum + x }
  end

  def sum_of_total_number_and_values(entries)
    total_values = 0
    total_number = 0
    entries.each do |key, value|
      total_values = total_values + value["Total"][1]
      total_number = total_number + value["Total"][0]
    end
    [total_number, total_values]
  end

  def get_percentage()

  end

end