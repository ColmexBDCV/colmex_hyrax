class PdfViewerController < Hyrax::DownloadsController
  private

  # Fuerza la visualizacion inline del archivo original para el iframe del visor.
  def content_options
    super.merge(disposition: 'inline')
  end

  # Fuerza la visualizacion inline si el archivo viene desde almacenamiento local.
  def local_content_options
    super.merge(disposition: 'inline')
  end
end
