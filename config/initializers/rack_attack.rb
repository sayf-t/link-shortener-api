Rack::Attack.throttle("link creation", limit: 10, period: 60) do |req|
  req.ip if req.path == "/api/v1/links" && req.post?
end

Rack::Attack.throttle("redirects", limit: 60, period: 60) do |req|
  req.ip if req.path.match?(%r{\A/[0-9A-Za-z]+\z}) && req.get?
end

Rack::Attack.throttled_responder = lambda do |_env|
  [ 429, { "Content-Type" => "application/json" }, [ { error: "Too many requests. Try again later." }.to_json ] ]
end
