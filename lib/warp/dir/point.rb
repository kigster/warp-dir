require 'forwardable'
module Warp
  module Dir
    class Point
      DEFAULT_FORMAT = :ascii
      ATTRS = %i(full_path name)
      attr_accessor *ATTRS

      def initialize name, full_path
        raise ArgumentError.new ":name is required" if name.nil?
        raise ArgumentError.new ":full_path is required" if full_path.nil?
        @full_path  = Warp::Dir.absolute full_path
        @name       = name.to_sym
      end

      def absolute_path
        full_path
      end

      def relative_path
        Warp::Dir.relative self.absolute_path
      end

      alias_method :path, :relative_path

      def formatted type = DEFAULT_FORMAT, width = 0
        case type
          when :ascii
            self.to_s(width)
          when :bash
            "printf \"#{self.to_s(width)}\\n\""
          else
            raise ArgumentError.new("Type #{type} is not recognized.")
        end
      end

      def inspect
        sprintf("(#{object_id})[name: '%s', path: '%s']", name, path)
      end

      def to_s width = 0
        sprintf("%#{width}s  ->  %s", name, relative_path)
      end

      def hash
        sum = ATTRS.inject("") do |sum, attribute|
          sum += send(attribute).hash.to_s
        end
        Digest::SHA1.base64digest(sum).hash
      end

      def eql?(another)
        return false unless another.is_a?(Warp::Dir::Point)
        ATTRS.each do |attribute|
          return false unless send(attribute).eql?(another.send(attribute))
        end
      end

      #____________________________________________________________________________________
      #
      # Collection of Points, which assumes that it's items are members of the Point class.
      #
      class Collection
        extend Forwardable
        def_delegators :@the_list, :size, :<<, :map, :each

        attr_accessor :the_list

        def initialize list = []
          @the_list = list
        end

        def add name, path = nil, overwrite: false
          p = if name.is_a?(Warp::Dir::Point) && path.nil?
                name
              else
                Warp::Dir::Point.new(name, path)
              end

          # if we found this WarpPoint by name, and it's path is different from the incoming...
          if self[name] && !self[name].eql?(p)
            if overwrite
              self[name] = p
            else
              raise Warp::Dir::Errors::PointAlreadyExists.new(p)
            end
          else
            @the_list << p    # new warp point
          end
          p
        end

        define_method(:to_a)  { self.the_list.dup }
        define_method(:<<) do |p|
          raise InvalidArgumentError.new("#{p} is not a Point") unless p.is_a?(Point)
          self.the_list << p
          self.the_list.uniq!
        end
        define_method(:[]) do |index|
          if "#{index}" =~ /^[0-9]+$/     # if digit
            self.the_list[index]
          else                                     # otherwise, find the one that matches with the name
            self.the_list.find { |p| p.name.eql?(index.to_sym) }
          end
        end

        # find the widest warp point name, and indent them all based on that.
        # make it easy to extend to other types, and allow the caller to
        # sort by one of the fields.
        def formatted type = DEFAULT_FORMAT, sort_field = :name
          longest_key_length = the_list.map(&:name).map(&:length).sort.last
          sorted_by(sort_field).map do |p|
            raise InvalidArgumentError.new("#{p} is not a Point") unless p.is_a?(Point)
            p.formatted(type, longest_key_length)
          end.join("\n")
        end

        def sorted_by field
          the_list.sort { |a,b| a.send(field) <=> b.send(field) }
        end
      end

    end
  end
end
