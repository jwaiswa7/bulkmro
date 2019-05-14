# frozen_string_literal: true

class Overseers::AccountPolicy < Overseers::ApplicationPolicy
  def new?
    manager_or_cataloging? || logistics?
  end
  def payment_collections?
    manager_or_cataloging? || logistics?
  end
  def ageing_report?
    manager_or_cataloging? || logistics?
  end

  def autocomplete_supplier?
    index?
  end

  all_policies = {}
  Dir.glob("/var/www/html/sprint/app/policies/overseers/*") do |my_text_file|
    data = File.read(my_text_file)
    model = File.basename(my_text_file, ".rb")
    policies = []
    policies = data.scan(/(?:def\ )(?:.*)/)
    all_policies[model.gsub('_policy','')] = policies.map {|x| x.gsub('def ','').gsub('?','')}
  end

end
