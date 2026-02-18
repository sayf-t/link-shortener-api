module Links
  class ResolveService
    def self.call(short_code)
      Link.find_by(short_code: short_code)
    end
  end
end
