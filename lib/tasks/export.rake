namespace :export do
    desc "Export all metadata by work_type"
    task :work_type, [:work_type] => [:environment]  do |_task, args|
        ExportByWorkTypeJob.perform_later(args[:work_type])
        puts "La exportación por tipo de Trabajo ha iniciado"
    end

    desc "Export all metadata by collection"
    task :collection, [:collection, :keys] => [:environment]  do |_task, args|
        ExportByCollectionJob.perform_later(args[:collection], args[:keys])
        puts "La exportación por colección ha iniciado"
    end
end