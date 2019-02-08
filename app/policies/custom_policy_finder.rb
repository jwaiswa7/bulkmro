# frozen_string_literal: true

class CustomPolicyFinder
  SUFFIX = "Policy"

  attr_reader :object, :namespace

  # @param object [any] the object to find policy and scope classes for
  #
  def initialize(object, namespace)
    @object = object
    @namespace = namespace
  end

  # @return [nil, Scope{#resolve}] scope class which can resolve to a scope
  # @see https://github.com/elabs/pundit#scopes
  # @example
  #   scope = finder.scope #=> UserPolicy::Scope
  #   scope.resolve #=> <#ActiveRecord::Relation ...>
  #
  def scope
    policy::Scope if policy
  rescue NameError
    nil
  end

  # @return [nil, Class] policy class with query methods
  # @see https://github.com/elabs/pundit#policies
  # @example
  #   policy = finder.policy #=> UserPolicy
  #   policy.show? #=> true
  #   policy.update? #=> false
  #
  def policy
    klass = find
    klass = klass.constantize if klass.is_a?(String)
    klass
  rescue NameError
    nil
  end

  # @return [Scope{#resolve}] scope class which can resolve to a scope
  # @raise [NotDefinedError] if scope could not be determined
  #
  def scope!
    raise NotDefinedError, "unable to find policy scope of nil" if object.nil?
    scope or raise NotDefinedError, "unable to find scope `#{find}::Scope` for `#{object.inspect}`"
  end

  # @return [Class] policy class with query methods
  # @raise [NotDefinedError] if policy could not be determined
  #
  def policy!
    raise Exception, "unable to find policy of nil" if object.nil?
    policy or raise Exception, "unable to find policy `#{find}` for `#{object.inspect}`"
  end

  # @return [String] the name of the key this object would have in a params hash
  #
  def param_key
    if object.respond_to?(:model_name)
      object.model_name.param_key.to_s
    elsif object.is_a?(Class)
      object.to_s.demodulize.underscore
    else
      object.class.to_s.demodulize.underscore
    end
  end

  private

    def find
      if object.nil?
        nil
      elsif object.respond_to?(:policy_class)
        object.policy_class
      elsif object.class.respond_to?(:policy_class)
        object.class.policy_class
      else
        klass = if object.is_a?(Array)
          object.map { |x| find_class_name(x) }.join("::")
        else
          find_class_name(object)
        end

        if namespace.present?
          "#{namespace}::#{klass}#{SUFFIX}"
        else
          "#{klass}#{SUFFIX}"
        end
      end
    end

    def find_class_name(subject)
      if subject.respond_to?(:model_name)
        subject.model_name
      elsif subject.class.respond_to?(:model_name)
        subject.class.model_name
      elsif subject.is_a?(Class)
        subject
      elsif subject.is_a?(Symbol)
        subject.to_s.camelize
      else
        subject.class
      end
    end
end
