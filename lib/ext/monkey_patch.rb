class EventMachine::DnsResolver::Request
  def self.new(*args)
    request = super
    request.retry_interval = 1
    request.max_tries = 2
    request.callback {
      request.cancel_timeout
    }.errback {
      request.cancel_timeout
    }
    request
  end

  def receive_answer(msg)
    result = []
    msg.each_answer do |name,ttl,data|
      case data
      when Resolv::DNS::Resource::IN::A, Resolv::DNS::Resource::IN::AAAA
        result << data.address.to_s
      when Resolv::DNS::Resource::IN::PTR
        result << data.name.to_s
      when Resolv::DNS::Resource::IN::NAPTR
        begin
          regex = data.regex
          c = regex[0,1]
          substr = regex[1,regex.length - 2]
          match, replace = substr.split(c)
          result << name.to_s.gsub(/#{match}/, replace)
        rescue Exception => e
          fail "error parsing #{e.message}"
        end
      end
    end
    if result.empty?
      fail "rcode=#{msg.rcode}"
    else
      succeed result
    end
  end
end

class EventMachine::DnsResolver::DnsSocket
  def nameservers=(nameservers)
    @nameservers = nameservers
  end

  def nameservers
    @nameservers
  end

  def post_init
    @requests = {}
    @connected = true
    EM.add_periodic_timer(0.02, &method(:tick))
  end

  def send_packet(pkt)
    send_datagram pkt, self.nameservers.sample, 53
  end
end
