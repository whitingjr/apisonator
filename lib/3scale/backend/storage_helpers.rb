module ThreeScale
  module Backend
    module StorageHelpers
      private
      def encode(stuff)
        JSON.generate(stuff)
      end

      def decode(encoded_stuff)
        stuff = JSON.parse(encoded_stuff, {:symbolize_names => true} )
        stuff[:timestamp] = Time.parse_to_utc(stuff[:timestamp]) if stuff[:timestamp]
        stuff
      end

      def storage
        Storage.instance
      end
    end
  end
end
