require 'ostruct'

class Embedly::EmbedlyObject < OpenStruct

  # Resursively make ostruct
  def initialize obj
    if obj
      o = obj.clone
      o.each do |k,v|
        if v.is_a?Hash
          o[k] = Embedly::EmbedlyObject.new v
        end
      end
      super o
    else
      super
    end
  end

  # for ruby 1.8.x, type should return @table[:type], not the
  # class.
  def type
    method_missing :type
  end

  def marshal_dump
    o = @table.clone
    o.each do |k,v|
      if v.is_a?Embedly::EmbedlyObject
        o[k] = v.marshal_dump
      end
    end
    return o
  end

end
