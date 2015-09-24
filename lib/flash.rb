class Flash
  # Find and deserialize the cookie
  def initialize(req)
    raw_cookie = req.cookies.find { |cook| cook.name == "_rails_lite_flash" }
    @now = raw_cookie ? JSON.parse(raw_cookie.value) : {}
    @later = {}
  end

  def [](key)
    @now[key] || (@later[key] || @later[key.to_s])
  end

  def []=(key, val)
    @later[key] = val
  end

  def now
    @now
  end

  # serialize the hash into json and save in a cookie
  def store_flash(res)
    cookie = WEBrick::Cookie.new('_rails_lite_flash', @later.to_json)
    cookie.path = '/'
    res.cookies << cookie
  end
end
