module DNSResolver
  class Cache
    include DNSResolver::Logging
    include DNSResolver::Configuration
    include DNSResolver::Exceptions

    attr_accessor :map, :ttl, :expire_every, :lock

    def initialize(options = {})
      @map = Hashie::Mash.new({})
      @ttl = options[:ttl] || 360
      @expire_every = options[:expire_every] || 15
      @lock = false
      EM::PeriodicTimer.new(@expire_every) { self.expire! }
    end

    def store(name, type, addresses = [])
      return if self.locked?

      begin
        h1 = Hashie::Mash.new({:addresses => addresses, :expires_at => (Time.now + @ttl)})
        h2 = Hashie::Mash.new({type => h1})

        if @map[name].blank?
          @map[name] = h2
        else
          @map[name][type] = h1
        end
      rescue Exception => e
        logger.warn e.message
        logger.warn e.backtrace.join("\n")
      end
    end

    def exists?(name, type)
      @map[name] && @map[name][type]
    end

    def get_addresses(name, type)
      return [] unless self.exists? name, type

      if h = @map[name][type]
        h[:addresses] || []
      else
        []
      end
    end

    def expire!
      @lock = true

      begin
        @new_map = @map.dup

        @new_map.each do |name, type_hashes|
          logger.info name
          type_hashes.each do |type, h|
            logger.info type
            if type && h && h.expires_at? && (h.expires_at <= Time.now)
              logger.info 'clearing'
              @new_map[name].delete type
            end
          end
        end
      rescue Exception => e
        logger.warn e.message
        logger.warn e.backtrace.join("\n")
        @lock = false
      else
        @map = @new_map
        @lock = false
      end
    end

    def locked?
      @lock
    end

  end
end