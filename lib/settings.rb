class Settings

  class << self
    attr_accessor :in_preview

    def configure
      yield self
    end
  end

end