# middleware explicitly
# Middleware1.new(
#   Middleware2.new(
#     Middleware3.new(@app)
#   )
# ).call(currency)

# middleware by reduce
[Middleware3, Middleware2, Middleware1].reduce(@app) do |app, middleware|
  middleware.new(app)
end.call(currency)
