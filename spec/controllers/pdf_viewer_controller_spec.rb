require 'rails_helper'

RSpec.describe PdfViewerController, type: :controller do
  describe '#content_options' do
    it 'serves repository files inline for the PDF iframe' do
      allow(controller).to receive(:file).and_return(double(mime_type: 'application/pdf', original_name: 'sample.pdf', id: 'file'))
      allow(controller).to receive(:asset).and_return(double(label: 'sample.pdf'))

      expect(controller.send(:content_options)[:disposition]).to eq('inline')
    end
  end

  describe '#local_content_options' do
    it 'serves local files inline for the PDF iframe' do
      allow(controller).to receive(:local_file_mime_type).and_return('application/pdf')
      allow(controller).to receive(:local_file_name).and_return('sample.pdf')

      expect(controller.send(:local_content_options)[:disposition]).to eq('inline')
    end
  end
end
