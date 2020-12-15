require 'win32ole' if Puppet.features.microsoft_windows?

Puppet::Type.newtype(:wmi_obj) do
  @keyprops = {}

  def self.keyprops(namespace, wmiclass)
    wmiclass = wmiclass.downcase.to_sym
    namespace = namespace.downcase.to_sym
    @keyprops[namespace] = {} unless @keyprops[namespace]
    unless @keyprops[namespace][wmiclass]
      klass = WIN32OLE.connect("winmgmts://./#{namespace}:#{wmiclass}")
      props = klass.Properties_.each.select do |p|
        p.Qualifiers_.each.any? { |q| q.Name == 'key' && q.Value == true }
      end
      @keyprops[namespace][wmiclass] = props.map { |p| p.Name.downcase }.sort
    end
    @keyprops[namespace][wmiclass]
  end

  ensurable

  newparam(:name, namevar: true)

  newparam(:wmiclass) do
    munge { |val| val.downcase }
  end

  newparam(:namespace) do
    munge { |val| val.downcase }
  end

  newproperty(:props) do
    validate do |val|
      unless val.is_a?(Hash)
        raise "'props' must be a hash"
      end
    end
    munge do |val|
      newhash = {}
      val.each { |k, v| newhash[k.downcase] = v }
      newhash
    end
  end

  validate do
    raise "Missing required parameter 'namespace'" if self[:namespace].nil?
    raise "Missing required parameter 'wmiclass'" if self[:wmiclass].nil?
    raise "Missing required parameter 'props'" if self[:props].nil?

    keys = self[:props].map { |k, _v| k.downcase }
    self.class.keyprops(self[:namespace], self[:wmiclass]).each do |keyprop|
      unless keys.include?(keyprop)
        raise "Missing key property '#{keyprop}' for WMI class '#{self[:wmiclass]}'"
      end
    end

    if catalog
      # namevars can't be used to prevent duplicate resources because the key properties
      # change based on the WMI class. So instead, we'll create an alias here
      # that includes all key properties for the given class plus class and namespace, which
      # together uniquely identify the WMI object.
      keyvals = self.class.keyprops(self[:namespace], self[:wmiclass]).map { |p| self[:props][p].downcase }
      catalog.alias(self, [self[:namespace], self[:wmiclass], *keyvals])
    end
  end
end
