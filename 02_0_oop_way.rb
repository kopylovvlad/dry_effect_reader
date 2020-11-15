class Application
  class Converter
    def call(currency)
      currency * rate
    end
  end

  class MainController
    def call(params)
      Converter.new.call(params[:currency])
    end
  end

  # middlewares
  # data conventer from string to integers, data validator, logger, some middleware
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
    @dependency
    Application.new.call(currency: currency)
  end
end

RubToUsdConverter = ApplicationRunner.new(0.013)
puts RubToUsdConverter.call(1_000)

# undefined local variable or method `rate' for #<Application::Converter:0x00007fb3440669f0> (NameError)
