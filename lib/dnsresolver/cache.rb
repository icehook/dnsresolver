module DNSResolver
  class Cache
    include DNSResolver::Configuration

    attr_accessor :map, :ttl, :expire_every, :lock

    def initialize(options = {})
      @map = {}.with_indifferent_access
      @ttl = options[:ttl] || 30
      @expire_every = options[:expire_every] || 15
      @lock = false
      EM::PeriodicTimer.new(@expire_every) { self.expire! }
    end

    def store(name, type, addresses = [])
      return if self.locked?

      begin
        h1 = {:addresses => addresses, :expires_at => (Time.now + @ttl)}.with_indifferent_access
        h2 = {type => h1}.with_indifferent_access

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
          type_hashes.each do |type, h|
            if type && h && h[:expires_at] && (h[:expires_at] <= Time.now)
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