require 'rspec'
require 'dry/effects'
require './01_functional_way'

# unit tests
RSpec.describe Application::Converter do
  include Dry::Effects::Handler.Reader(:rate)

  subject { described_class.new.call(value) }

  context 'value = 10' do
    let(:dependency) { 20 }
    let(:value) { 10 }
    it 'multiplies 10 by 20' do
      with_rate(dependency) do
        expect(subject).to eql(20 * 10)
      end
    end
  end
end

# integration tests
RSpec.describe Application do
  include Dry::Effects::Handler.Reader(:rate)

  subject { Application.new.call(currency: value) }

  context 'value = 10' do
    let(:dependency) { 20 }
    let(:value) { 10 }
    it 'multiplies 10 by 20' do
      with_rate(dependency) do
        expect(subject).to eql(20 * 10)
      end
    end
  end
end
