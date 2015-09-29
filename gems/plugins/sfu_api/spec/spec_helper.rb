require 'spec_helper'
require 'webmock/rspec'

# require sfu_api factories
factories = "#{File.dirname(__FILE__).gsub(/\\/, "/")}/factories/*.rb"
Dir.glob(factories).each { |file| require file }

# load REST mocks
mocks = {}
Dir.glob("#{File.dirname(__FILE__).gsub(/\\/, "/")}/mocks/*.yaml").each do |file|
  name = File.basename(file, '.yaml').to_sym
  mocks[name] = YAML.load_file file
end

mock_map = [
  { :method => :get, :pattern => /rest.its.sfu.ca\/.*\/rest\/course\/course.js.*/, :mock => mocks[:amaint_mocks][:course] },
  { :method => :get, :pattern => /rest.its.sfu.ca\/.*\/rest\/datastore2\/global\/accountInfo.js.*/, :mock => mocks[:amaint_mocks][:user] },
  { :method => :get, :pattern => /rest.its.sfu.ca\/.*\/rest\/crr\/terms.js.*/, :mock => mocks[:amaint_mocks][:terms] },
  { :method => :get, :pattern => /rest.its.sfu.ca\/.*\/rest\/crr\/resource2.js.*/, :mock => mocks[:amaint_mocks][:crr] }
]

WebMock.disable_net_connect!(allow_localhost: true)
RSpec.configure do |config|
  config.before(:each) do
    headers = {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}
    mock_map.each do | m |
      stub_request(m[:method], m[:pattern]).with(:headers => headers).to_return(:status => 200, :body => m[:mock], :headers => {})
    end
  end

  config.before(:each, :course_data_mock => true) do
    mock_data = File.open("#{File.dirname(File.expand_path(__FILE__))}/fixtures/all.lst")
    File.stubs(:exists?).returns(true)
    File.stubs(:open).returns(StringIO.new(mock_data.read))
  end

end
