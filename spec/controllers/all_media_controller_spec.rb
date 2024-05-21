require 'rails_helper'

RSpec.describe AllMediaController, type: :controller do
  describe "GET #get_media" do
    let(:file_set) { create(:file_set) }

    it "returns http success if file_set exists" do
      get :get_media, params: { id: file_set.id }
      expect(response).to have_http_status(:success)
    end

    it "returns http not found if file_set does not exist" do
      get :get_media, params: { id: 0 }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "#get_derivatives" do
    let(:file_set) { create(:file_set) }
    let(:derivatives) { ["file-1080p.mp4", "file-720p.mp4", "file-thumbnail.png"] }

    before do
      # Stub Hyrax::DerivativePath.derivatives_for_reference to return a predetermined array
      allow(Hyrax::DerivativePath).to receive(:derivatives_for_reference).with(file_set).and_return(derivatives)
    end

    it "renders the correct json response excluding 'thumbnail' and sorting the tags" do
      expected_links = [
        ["/downloads/#{file_set.id}?file=1080p", "1080p"],
        ["/downloads/#{file_set.id}?file=720p", "720p"]
      ]
      expect(controller).to receive(:render).with(json: expected_links)
      controller.send(:get_derivatives, file_set)
    end
  end
end
