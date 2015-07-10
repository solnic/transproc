module Transproc
  module Deprecations
    def self.announce(name, msg)
      warn <<-MSG.gsub(/^\s+/, '')
        #{name} is deprecated and will be removed in 1.0.0.
        #{msg}
        #{caller.detect { |l| !l.include?('lib/transproc')}}
      MSG
    end
  end
end
