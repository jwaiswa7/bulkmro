

class RandomRecords < BaseFunction
	 def self.for(object, limit)
 		 if object.is_a?(Class)
  			 object.limit(limit).order('RANDOM()')
  		elsif object.respond_to?(:each)
  			 object.where([object.table_name, '.id IN (?)'].join, object.map(&:id).sample(limit))
  		end
 	end
end
