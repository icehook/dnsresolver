module DNSResolver
  class Response

    attr_accessor :request, :addresses, :errors, :options, :requested_at, :completed_at

    def initialize(request, addresses, errors, options = {})
      @request = request
      @addresses = addresses || []
      @errors = errors || []
      @options = Hashie::Mash.new(options)
      @requested_at = @options[:requested_at]
      @completed_at = @options[:completed_at]
    end

    def age
      (self.completed_at || Time.now).to_f - self.requested_at.to_f if self.requested_at
    end

  end
end
