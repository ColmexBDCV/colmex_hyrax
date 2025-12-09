namespace :works do
  desc "Export works with fileset visibility information. Usage: rake works:export_visibility[work_type] (e.g., Book, Thesis, Article)"
  task :export_visibility, [:work_type] => :environment do |t, args|
    require 'csv'

    work_type = args[:work_type] 

    # Validar que la clase exista
    begin
      work_class = work_type.constantize
    rescue NameError
      puts "Error: Clase '#{work_type}' no encontrada."
      puts "Clases disponibles: Book, Thesis, Article, Audio, Video, etc."
      exit 1
    end

    # Crear array con los resultados
    results = []

    # Procesar cada Work del tipo especificado
    work_class.all.each do |work|
      row = {
        identifier: work.id,
        handle: work.handle.presence || 'N/A',
        title: work.title.present? ? work.title.join('; ') : 'N/A',
        visibility: work.visibility,
        item_access_restrictions: work.item_access_restrictions.present? ? work.item_access_restrictions.join('; ') : 'N/A',
        fileset_visibility: work.file_sets.map(&:visibility).join('|') || 'N/A'
      }
      results << row
      puts "Procesado #{work_type} ID: #{work.id}"
    end

    # Mostrar en consola
    puts "\n" + "="*150
    puts "REPORTE DE #{work_type.upcase} CON VISIBILIDAD DE FILESETS"
    puts "="*150 + "\n"

    # Header
    headers = [:identifier, :handle, :title, :visibility, :item_access_restrictions, :fileset_visibility]
    printf("%-40s | %-20s | %-50s | %-15s | %-30s | %-30s\n", 
           "IDENTIFIER", "HANDLE", "TITLE", "VISIBILITY", "ACCESS RESTRICTIONS", "FILESET VISIBILITY")
    puts "-"*150

    # Rows
    results.each do |row|
      printf("%-40s | %-20s | %-50s | %-15s | %-30s | %-30s\n",
             row[:identifier][0..39],
             row[:handle][0..19],
             (row[:title][0..49] || 'N/A'),
             row[:visibility][0..14],
             (row[:item_access_restrictions][0..29] || 'N/A'),
             (row[:fileset_visibility][0..29] || 'N/A'))
    end

    puts "\n" + "="*150
    puts "Total de Books: #{results.length}"
    puts "="*150 + "\n"

    # Exportar a CSV
    csv_filename = "books_visibility_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv"
    CSV.open(csv_filename, 'w') do |csv|
      csv << headers
      results.each do |row|
        csv << [row[:identifier], row[:handle], row[:title], row[:visibility], 
                row[:item_access_restrictions], row[:fileset_visibility]]
      end
    end

    puts "CSV exportado a: #{csv_filename}\n"
  end
end
