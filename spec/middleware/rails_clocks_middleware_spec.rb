require 'rails_helper'

RSpec.describe RailsClocks::Middleware do
  let(:app) { ->(env) { [200, {}, ['OK']] } }
  let(:middleware) { described_class.new(app) }

  before do
    RailsClocks.configure do |config|
      config.enabled = true
      config.sample_rate = 1.0 # Record all requests
    end
  end

  after do
    RailsClocks.configure do |config|
      config.enabled = true
      config.sample_rate = 1.0
    end
  end

  describe '#call' do
    context 'when recording is enabled' do
      it 'records the request' do
        env = {
          'REQUEST_METHOD' => 'GET',
          'PATH_INFO' => '/test',
          'rack.input' => StringIO.new,
          'HTTP_COOKIE' => 'session_id=12345'
        }

        expect {
          middleware.call(env)
        }.to change { RailsClocks::RecordedRequest.count }.by(1)

        recorded_request = RailsClocks::RecordedRequest.last
        expect(recorded_request.request_method).to eq('GET')
        expect(recorded_request.path).to eq('/test')
        expect(recorded_request.cookies).to include('session_id' => '12345')
      end
    end

    context 'when recording is disabled' do
      before do
        RailsClocks.configure { |config| config.enabled = false }
      end

      it 'does not record the request' do
        env = {
          'REQUEST_METHOD' => 'GET',
          'PATH_INFO' => '/test',
          'rack.input' => StringIO.new
        }

        expect {
          middleware.call(env)
        }.not_to change { RailsClocks::RecordedRequest.count }
      end
    end

    context 'when the request path is excluded' do
      before do
        RailsClocks.configure do |config|
          config.excluded_paths = [/\/excluded/]
        end
      end

      it 'does not record the request' do
        env = {
          'REQUEST_METHOD' => 'GET',
          'PATH_INFO' => '/excluded',
          'rack.input' => StringIO.new
        }

        expect {
          middleware.call(env)
        }.not_to change { RailsClocks::RecordedRequest.count }
      end
    end

    context 'when an error occurs' do
      it 'logs the error' do
        allow(Rails.logger).to receive(:error)

        allow(app).to receive(:call).and_raise(StandardError.new("Test error"))

        env = {
          'REQUEST_METHOD' => 'GET',
          'PATH_INFO' => '/test',
          'rack.input' => StringIO.new
        }

        expect {
          middleware.call(env)
        }.to raise_error(StandardError)

        expect(Rails.logger).to have_received(:error).with(/RailsClocks Middleware Error: Test error/)
      end
    end
  end
end 