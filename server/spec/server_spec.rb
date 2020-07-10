class Wrapper
  def record
    `curl http://localhost:13111/vcr/mode/record`
  end

  def replay
    `curl http://localhost:13111/vcr/mode/replay`
  end

  def it(name, &blk)
    puts "use cassette #{ name }"
    use_cassette(name)

    puts "running test..."
    blk.call

    puts "stop cassette #{ name }"
    stop_cassette
  end

  def use_cassette(name)
    `curl http://localhost:13111/vcr/cassette/load?filepath=#{name}.yaml`
  end

  def stop_cassette
    `curl http://localhost:13111/vcr/cassette/eject`
  end
end

RSpec.describe '/create' do
  vcr = Wrapper.new

  before(:all) do
    vcr.replay
  end

  it 'root test' do
    get '/'
    # Rspec 2.x
    expect(last_response).to be_ok
  end

  it 'creates a payment intent on Stripe' do
    vcr.it('create-payment-intent') do
      body = {currency: "USD", items: [{id: "test"}]}
      post('/create-payment-intent', body.to_json, {'CONTENT_TYPE' => 'application/json'})
      expect(last_response).to be_ok
      expect(last_response.body["clientSecret"]).not_to be_nil
    end
  end
end
