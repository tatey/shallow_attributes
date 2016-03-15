module ShallowAttributes
  module Type
    # Abstract class for typecast object to Array type.
    #
    # @abstract
    #
    # @since 0.1.0
    class Array
      # Convert value to Array type
      #
      # @private
      #
      # @param [Array] values
      # @param [Class] element_class the type of array element class
      #
      # @example Convert integer array to string array
      #   ShallowAttributes::Type::Array.new.coerce([1, 2], String)
      #     # => ['1', '2']
      #
      # @raise [InvalidValueError] if values is not Array
      #
      # @return [Array]
      #
      # @since 0.1.0
      def coerce(values, element_class)
        unless values.is_a? ::Array
          raise ShallowAttributes::Type::InvalidValueError, %(Invalid value "#{values}" for type "Array")
        end

        values.map! { |value| ShallowAttributes::Type.coerce(element_class, value) }
      end
    end
  end
end
