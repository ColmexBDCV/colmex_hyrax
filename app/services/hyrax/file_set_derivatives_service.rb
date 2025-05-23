module Hyrax
  # Responsible for creating and cleaning up the derivatives of a file_set
  class FileSetDerivativesService
    attr_reader :file_set
    delegate :uri, :mime_type, to: :file_set

    # @param file_set [Hyrax::FileSet] At least for this class, it must have #uri and #mime_type
    def initialize(file_set)
      @file_set = file_set
    end

    def cleanup_derivatives
      derivative_path_factory.derivatives_for_reference(file_set).each do |path|
        FileUtils.rm_f(path)
      end
    end

    def valid?
      supported_mime_types.include?(mime_type)
    end

    def create_derivatives(filename)
      case mime_type
      when *file_set.class.pdf_mime_types             then create_pdf_derivatives(filename)
      when *file_set.class.office_document_mime_types then create_office_document_derivatives(filename)
      when *file_set.class.audio_mime_types           then create_audio_derivatives(filename)
      when *file_set.class.video_mime_types           then create_video_derivatives(filename)
      when *file_set.class.image_mime_types           then create_image_derivatives(filename)
      end
    end

    # The destination_name parameter has to match up with the file parameter
    # passed to the DownloadsController
    def derivative_url(destination_name)
      path = derivative_path_factory.derivative_path_for_reference(file_set, destination_name)
      URI("file://#{path}").to_s
    end

    private

      def supported_mime_types
        file_set.class.pdf_mime_types +
          file_set.class.office_document_mime_types +
          file_set.class.audio_mime_types +
          file_set.class.video_mime_types +
          file_set.class.image_mime_types
      end

      def create_pdf_derivatives(filename)
        output_path = URI(derivative_url('thumbnail')).path



        dirname = File.dirname(output_path)
        FileUtils.mkdir_p(dirname) unless Dir.exist?(dirname)

        system("convert -density 150 '#{filename}[0]' -strip -trim -thumbnail 338x493^ -gravity center -extent 338x493 '#{output_path}'")

        extract_full_text(filename, uri)
      end

      def create_office_document_derivatives(filename)
        Hydra::Derivatives::DocumentDerivatives.create(filename,
                                                       outputs: [{
                                                         label: :thumbnail, format: 'png',
                                                         size: '200x150',
                                                         url: derivative_url('thumbnail'),
                                                         layer: 0
                                                       }])
        extract_full_text(filename, uri)
      end

      def create_audio_derivatives(filename)
        Hydra::Derivatives::AudioDerivatives.create(filename,
                                                    outputs: [{ label: 'mp3', format: 'mp3', url: derivative_url('mp3') },
                                                              { label: 'ogg', format: 'ogg', url: derivative_url('ogg') }])
      end

      def create_video_derivatives(filename)

        outputs = [{ label: :thumbnail, format: 'jpg', url: derivative_url('thumbnail') },
          { label: '2160p', size: '3840x2160', bitrate: '15000k', format: 'mp4', url: derivative_url('2160p') },
          { label: '1080p', size: '1920x1080', bitrate: '4000k', format: 'mp4', url: derivative_url('1080p') },
          { label: '720p', size: '1280x720', bitrate: '2000k', format: 'mp4', url: derivative_url('720p') },
          { label: '480p', size: '854x480', bitrate: '1000k', format: 'mp4', url: derivative_url('480p') },
          { label: '360p ', size: '640x360', bitrate: '600k', format: 'mp4', url: derivative_url('360p') }]


        outputs.delete_at(1) if @file_set.height.first.to_i < 2160
        outputs.delete_at(1) if @file_set.height.first.to_i < 1080
        outputs.delete_at(1) if @file_set.height.first.to_i < 720
        outputs.delete_at(1) if @file_set.height.first.to_i < 480
        outputs.delete_at(1) if @file_set.height.first.to_i < 360

        Hydra::Derivatives::VideoDerivatives.create(filename,
                                                    outputs: outputs)


      end

      def create_image_derivatives(filename)
        # We're asking for layer 0, becauase otherwise pyramidal tiffs flatten all the layers together into the thumbnail
        Hydra::Derivatives::ImageDerivatives.create(filename,
                                                    outputs: [{ label: :thumbnail,
                                                                format: 'jpg',
                                                                size: '200x150>',
                                                                url: derivative_url('thumbnail'),
                                                                layer: 0 }])
      end

      def derivative_path_factory
        Hyrax::DerivativePath
      end

      # Calls the Hydra::Derivates::FulltextExtraction unless the extract_full_text
      # configuration option is set to false
      # @param [String] filename of the object to be used for full text extraction
      # @param [String] uri to the file set (deligated to file_set)
      def extract_full_text(filename, uri)
        return unless Hyrax.config.extract_full_text?
        Hydra::Derivatives::FullTextExtract.create(filename,
                                                   outputs: [{ url: uri, container: "extracted_text" }])
      end
  end
end
