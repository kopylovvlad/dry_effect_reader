require 'dry/effects'

class Application
  # model
  class Converter
    include Dry::Effects.Reader(:rate)
    def call(currency)
      currency * rate
    end
  end

  # controller
  class MainController
    def call(params)
      Converter.new.call(params[:currency])
    end
  end

  # middlewares
  # data conventer from string to integers, data validator, logger and other stuff
  class Middleware1
    def initialize(app); @app = app; end
    def call(env)
      puts 'middleware 1'
      @app.call(env)
    end
  end
  class Middleware2
    def initialize(app); @app = app; end
    def call(env)
      puts 'middleware 2'
      @app.call(env)
    end
  end

  def initialize
    @app = MainController.new
  end
  def call(env)
    middlewares = [Middleware2, Middleware1]
    middlewares.reduce(@app) do |app, middleware|
      middleware.new(app)
    end.call(env.freeze)
  end
end

# we run our application with some dependencies
class ApplicationRunner
  include Dry::Effects::Handler.Reader(:rate)
  def initialize(dependency)
    @dependency = dependency
  end

  def call(currency)
    # NOTE: the Application class is pure.
    # only ApplicationRunner knows about dependency injection
    # and we use only current class for configuration
    with_rate(@dependency) do
      Application.new.call(currency: currency)
    end
  end
end


# RubToUsdConverter = ApplicationRunner.new(0.013)
# puts RubToUsdConverter.call(1_000)
# RubToEuroConverter = ApplicationRunner.new(0.011)
# puts RubToEuroConverter.call(1_000)

