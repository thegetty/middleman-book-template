module Book
  module XMLStructs
    ItemTag = Struct.new :id, :href, :media_type, :properties do
      def initialize(*)
        super
        self.properties ||= nil
      end
    end

    NavPoint = Struct.new :id, :play_order, :src, :text
  end
end
