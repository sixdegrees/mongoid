# encoding: utf-8
module Mongoid #:nodoc:
  module Collections #:nodoc:
    class Master

      attr_reader :collection

      # All read and write operations should delegate to the master connection.
      # These operations mimic the methods on a Mongo:Collection.
      #
      # Example:
      #
      # <tt>collection.save({ :name => "Al" })</tt>
      Operations::ALL.each do |name|
        define_method(name) { |*args|
          t = Time.now
          r = collection.send(name, *args)
          Mongoid.logger.debug("[MONGOID] requete #{name} with query #{args.inspect} => time elapse : #{Time.now - t}s")
          r
        }
      end

      # Create the new database writer. Will create a collection from the
      # master database.
      #
      # Example:
      #
      # <tt>Master.new(master, "mongoid_people")</tt>
      def initialize(master, name)
        @collection = master.collection(name)
      end
    end
  end
end
