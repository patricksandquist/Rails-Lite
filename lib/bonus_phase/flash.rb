module Phase6
  class Flash
    # Find and deserialize the cookie
    def initialize(req)
      raw_cookie = req.cookies.find { |cook| cook.name == "_rails_lite_app" }
      @cookie = raw_cookie ? JSON.parse(raw_cookie.value) : {}
      @cookie[:count] ||= 2 # number of responses left
    end

    def [](key)
      @cookie[key]
    end

    def []=(key, val)
      @cookie[key] = val
    end

    # serialize the hash into json and save in a cookie
    def store_flash(res)
      @cookie[:count] -= 1
      if @cookie[:count] > 0
        res.cookies << WEBrick::Cookie.new('_rails_lite_app', @cookie.to_json)
      else
        req.cookies.delete(@cookie)
      end
    end
  end
