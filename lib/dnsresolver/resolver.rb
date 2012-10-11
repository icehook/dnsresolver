module DNSResolver
  class Resolver
    include DNSResolver::Logger
    include DNSResolver::Exceptions
    include Celluloid::IO

    def initialize(nameservers, options = {})
      options = { :config_info => { :nameserver => nameservers[0] }}.merge ::DNSResolver::DNSRUBY_DEFAULTS.merge options
      @resolver = Dnsruby::Resolver.new(options)
      @asynch_qas = Queue.new
      @query_callback_map = Hash.new
      self.add_nameservers nameservers
      2.times { self.start_asynch_qa_handler }
    end

    def resolver
      @resolver
    end

    def asynch_qas
      @asynch_qas
    end

    def query_callback_map
      @query_callback_map
    end

    def add_query_callback(query_id, callback)
      self.query_callback_map[query_id] = callback
    end

    def retrieve_query_callback(query_id)
      self.query_callback_map.delete query_id
    end

    def add_nameservers(nameservers)
      nameservers.each { |nameserver| @resolver.config.add_nameserver nameserver }
    end

    def start_asynch_qa_handler
      Celluloid::ThreadHandle.new do
        loop do

          begin
            query_id, answer, exception = @asynch_qas.pop
            if query_id
              callback = self.retrieve_query_callback query_id
              callback.call answer, exception if callback
            end
          rescue Exception => e
            logger.error e.message
            logger.error e.backtrace.join("\n")
          end

        end
      end
    end

    def query(name, options = {})
      answers = []
      record_type = options[:record_type] || Dnsruby::Types.A
      dns_class = options[:dns_class] || Dnsruby::Classes.IN

      begin
        message = self.resolver.query(name, record_type, dns_class)
        message.each_answer { |answer| answers << answer }
      rescue Dnsruby::NXDomain => nxde
        logger.debug "DNSResolver query, could not resolve '#{name}'"
      rescue Exception => e
        logger.error "DNSResolver query, '#{name}' #{e.message}"
      end

      answers
    end

    def asynchronous_query(name, options = {})
      record_type = options[:record_type] || Dnsruby::Types.A
      dns_class = options[:dns_class] || Dnsruby::Classes.IN
      queue = options[:answer_queue] || self.asynch_qas
      query_id = options[:query_id] || ::DNSResolver.generate_uuid
      callback = options[:callback]

      begin
        message = Dnsruby::Message.new(name, record_type, dns_class)
        self.add_query_callback query_id, callback if query_id && callback
        self.resolver.send_async(message, queue, query_id)
      rescue Exception => e
        logger.error "DNSResolver asynchronous_query, '#{name}' #{e.message}"
      end
    end

    def naptr_query(name, options = {})
      self.query(name, :record_type => Dnsruby::Types.NAPTR)
    end

  end
end