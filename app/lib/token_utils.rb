class TokenUtils
  SECRET_KEY = 'MySecret' # put it into env var in real app

  def self.encode(payload)
    payload[:exp] = 24.hours.from_now.to_i
    return JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    return JWT.decode(token, SECRET_KEY)[0]
  end
end