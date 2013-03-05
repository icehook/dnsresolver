class DNSResolver::Action
  include EM::Deferrable

  attr_accessor :attributes

  def initialize(attributes = {})
    @attributes = Hashie::Mash.new(attributes)
    @attributes.created_at = Time.now
    self.set_timeout(self.ttl) if self.ttl
  end

  def age
    Time.now.utc.to_f - @attributes.created_at.utc.to_f
  end

  def ttl
    @attributes.ttl
  end

  def set_timeout(t)
    self.timeout t, DNSResolverError.new('timeout')
  end

end