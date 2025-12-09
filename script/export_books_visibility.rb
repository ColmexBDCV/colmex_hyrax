#!/usr/bin/env rails runner

require 'csv'


# Crear array con los resultados
results = []


# Procesar cada Book
Book.all.each do |book|
  row = {
    identifier: book.id,
    handle: book.handle.presence || 'N/A',
    title: book.title.present? ? book.title.join('; ') : 'N/A',
    visibility: book.visibility,
    item_access_restrictions: book.item_access_restrictions.present? ? book.item_access_restrictions.join('; ') : 'N/A',
    fileset_visibility: book.file_sets.map(&:visibility).join('|') || 'N/A'
  }
  results << row
  puts "Procesado Book ID: #{book.id}"
end

# Mostrar en consola
puts "\n" + "="*150
puts "REPORTE DE BOOKS CON VISIBILIDAD DE FILESETS"
puts "="*150 + "\n"

# Header
headers = [:identifier, :handle, :title, :visibility, :item_Access_restrictions, :fileset_visibility]
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
         (row[:item_Access_restrictions][0..29] || 'N/A'),
         (row[:fileset_visibility][0..29] || 'N/A'))
end

puts "\n" + "="*150
puts "Total de Books: #{results.length}"
puts "="*150 + "\n"

# Exportar a CSV si lo deseas
csv_filename = "books_visibility_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv"
CSV.open(csv_filename, 'w') do |csv|
  csv << headers
  results.each do |row|
    csv << [row[:identifier], row[:handle], row[:title], row[:visibility], 
            row[:item_Access_restrictions], row[:fileset_visibility]]
  end
end

puts "CSV exportado a: #{csv_filename}\n"
