# saving dependencies into one global object

class Application
  # NOTE: 1) adding value object. singleton
  class ApplicationContainer
    def self.hash
      @@hash ||= {}
    end
    def self.set(key, value)
      hash[key] = value
    end
    def self.[](value)
      hash[value]
    end
  end

  class Converter
    attr_reader :rate
    def initialize(rate)
      @rate = rate
    end
    def call(currency)
      currency * rate
    end
  end

  class MainController
    def call(params)
      # NOTE: 3) MainController knows about relation between Converter and ApplicationContainer
      Converter.new(ApplicationContainer[:rate]).call(params[:currency])
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

  def initialize(dependency)
    # NOTE: 2) Application knows about all dependency
    ApplicationContainer.set(:rate, dependency)
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
    Application.new(@dependency).call(currency: currency)
  end
end

RubToUsdConverter = ApplicationRunner.new(0.013)
puts RubToUsdConverter.call(1_000)

RubToEuroConverter = ApplicationRunner.new(0.011)
puts RubToEuroConverter.call(1_000)
