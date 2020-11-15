# passing dependency through a lot of classes

class Application
  class Converter
    # NOTE: 4) we changed implementation to add dependency explicitly
    attr_reader :rate
    def initialize(dependency)
      @rate = dependency
    end

    def call(currency)
      currency * rate
    end
  end

  class MainController
    # NOTE: 3) we pass dependency through a lot of classes
    def initialize(dependency)
      @dependency = dependency
    end
    def call(params)
      # NOTE: 3) MainController still knows about Converter implementation and its dependencies
      Converter.new(@dependency).call(params[:currency])
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

  # NOTE: 2) Application receives dependency implicitly
  def initialize(dependency)
    @app = MainController.new(dependency)
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
    # NOTE: 1) Application receives dependency implicitly
    Application.new(@dependency).call(currency: currency)
  end
end

RubToUsdConverter = ApplicationRunner.new(0.013)
puts RubToUsdConverter.call(1_000)

RubToEuroConverter = ApplicationRunner.new(0.011)
puts RubToEuroConverter.call(1_000)
