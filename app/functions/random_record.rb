# frozen_string_literal: true

class RandomRecord < BaseFunction
	 def self.for(object)
 		 if object.is_a?(Class)
  			 object.limit(1).order('RANDOM()').first
  		elsif object.respond_to?(:each)
  			 object.limit(1).order('RANDOM()').first
  		end
 	end
end
