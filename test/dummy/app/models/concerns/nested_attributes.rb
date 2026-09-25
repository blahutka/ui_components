# accepts_nested_attributes_for for plain ActiveModel objects (the dummy app has no database):
# `address_attributes=` / `phones_attributes=` build the children from the params a
# `fields_for` form submits, and the parent is invalid while a child is.
module NestedAttributes
  extend ActiveSupport::Concern

  included do
    class_attribute :nested_associations, default: []
    validate :nested_records_valid
  end

  class_methods do
    def nested_one(name, model)
      self.nested_associations += [ name ]
      attr_writer name

      define_method(name) { instance_variable_get("@#{name}") || instance_variable_set("@#{name}", model.new) }
      define_method("#{name}_attributes=") { |attributes| public_send("#{name}=", model.new(attributes.to_h)) }
    end

    # Rails submits collections as { "0" => {…}, "1" => {…} }
    def nested_many(name, model)
      self.nested_associations += [ name ]
      attr_writer name

      define_method(name) { instance_variable_get("@#{name}") || instance_variable_set("@#{name}", []) }
      define_method("#{name}_attributes=") do |attributes|
        rows = attributes.respond_to?(:values) ? attributes.to_h.sort_by { |index, _| index.to_i }.map(&:last) : Array(attributes)
        public_send("#{name}=", rows.map { |row| model.new(row.to_h) })
      end
    end
  end

  private
    def nested_records_valid
      nested_associations.each do |name|
        errors.add(name, :invalid) unless Array(public_send(name)).map(&:valid?).all?
      end
    end
end
