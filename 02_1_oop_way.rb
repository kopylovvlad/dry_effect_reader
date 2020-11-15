# adding dependencies application input (user unput and middleware env)

class Application
  # model
  class Converter
    # NOTE: 3) we changed implementation to add dependency explicitly
    attr_reader :rate
    def initialize(dependency)
      @rate = dependency
    end

    def call(currency)
      currency * rate
    end
  end

  # controller
  class MainController
    def call(params)
      # NOTE: 2) MainController knows about Converter implementation and its dependencies
      Converter.new(params[:rate]).call(params[:currency])
    end
  end

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

class ApplicationRunner
  def initialize(dependency)
    @dependency = dependency
  end

  def call(currency)
    # NOTE: 1) we change user input
    Application.new.call(currency: currency, rate: @dependency)
  end
end

RubToUsdConverter = ApplicationRunner.new(0.013)
puts RubToUsdConverter.call(1_000)
RubToEuroConverter = ApplicationRunner.new(0.011)
puts RubToEuroConverter.call(1_000)
