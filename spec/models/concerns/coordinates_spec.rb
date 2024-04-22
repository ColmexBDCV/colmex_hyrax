# spec/models/concerns/coordinates_spec.rb
require 'rails_helper'
require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.describe Coordinates, type: :model do
    let(:including_class) do
        Class.new do
            include Coordinates
            def to_solr(solr_doc = {})
            solr_doc # simplemente retorna el documento sin modificar
            end
        end
    end
      

  let(:instance) { including_class.new }


    describe "#get_coordinates" do
        before do
            allow(Qa::Authorities::Geonames).to receive(:username).and_return('fakeuser')
            stub_request(:get, "http://api.geonames.org/getJSON?geonameId=1234&username=fakeuser")
            .to_return(body: '{"lat": "40.7128", "lng": "-74.0060"}')
        end

        it "returns latitude and longitude as a string" do
            expect(instance.get_coordinates("1234")).to eq("40.7128|-74.0060")
        end
    end
end
