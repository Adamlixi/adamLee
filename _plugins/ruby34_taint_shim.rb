# Ruby 3.2+ removed Object#taint/#tainted?, which liquid 4.0.3 (pinned by jekyll ~> 4.2.0) still calls.
unless Object.method_defined?(:tainted?)
  class Object
    def tainted?
      false
    end

    def taint
      self
    end
  end
end
