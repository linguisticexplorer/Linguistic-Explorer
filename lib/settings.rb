class Settings

  class << self
    attr_accessor :in_preview, :group_data_enabled

    def configure
      yield self
    end
  end

end