require "omniauth_resource/version"

module OmniauthResource
  def self.factory(auth_hash)
    klass = auth_hash['provider'].classify
    begin
      "OmniauthResource::#{klass}".constantize.new(auth_hash)
    rescue NameError # => e # TODO: Refactor
      return Doorkeeper.new(auth_hash)
    end
  end

  class Base
    include HustleSupport::CoreExt::AttrAccessor

    attr_reader :provider, :uid, :name, :nickname, :email, :url, :image, :birthday,
                :description, :credentials, :access_token, :access_secret,
                :other, :raw_info

    def initialize(auth_hash)
      @provider      = auth_hash['provider']
      @uid           = auth_hash['uid']
      @name          = auth_hash['info']['name']
      @nickname      = auth_hash['info']['nickname']
      @email         = auth_hash['info']['email']
      @birthday      = auth_hash['info']['birthday']
      @url           = nil
      @image_url     = auth_hash['info']['image']
      @description   = auth_hash['info']['description']
      @credentials   = auth_hash['credentials'].to_json # `#to_json` is needed?
      @access_token  = auth_hash['credentials']['token']
      @access_secret = auth_hash['credentials']['secret']
      @other         = nil
      @raw_info      = auth_hash['extra']['raw_info'].to_json if auth_hash.key?('extra')
    end
  end

  class Doorkeeper < OmniauthResource::Base
    def initialize(auth_hash)
      super
      @nickname ||= auth_hash['info']['nickname'] = auth_hash['info']['name']
      freeze
    end
  end

  class Chatwork < OmniauthResource::Base
  end

  class Google < OmniauthResource::Base
    def initialize(auth_hash)
      super
      @url = auth_hash['info']['urls']['google'] if auth_hash['info'].key?('urls')
      freeze
    end
  end

  class Github < OmniauthResource::Base
    def initialize(auth_hash)
      super
      @url = auth_hash['info']['urls']['GitHub']
      @other = { blog: auth_hash['info']['urls']['Blog'] } if auth_hash['info']['urls']['Blog'].present?
      freeze
    end
  end

  class Slack < OmniauthResource::Base
  end

  class Facebook < OmniauthResource::Base
    def initialize(auth_hash)
      super
      @url = auth_hash['extra']['raw_info']['link']
      freeze
    end
  end

  class Twitter < OmniauthResource::Base
    def initialize(auth_hash)
      super
      @url = auth_hash['info']['urls']['Twitter']
      @other = {
        location: auth_hash['info']['location'],
        website: auth_hash['info']['urls']['Website']
      }
      @raw_info = nil
      freeze
    end
  end
end
