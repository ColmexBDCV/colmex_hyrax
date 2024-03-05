require "rails_helper"

RSpec.describe ImportsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/imports").to route_to("imports#index")
    end

    it "routes to #new" do
      expect(get: "/imports/new").to route_to("imports#new")
    end

    it "routes to #create" do
      expect(post: "/imports").to route_to("imports#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/imports/1").to route_to("imports#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/imports/1").to route_to("imports#update", id: "1")
    end


  end
end
