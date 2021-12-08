namespace :export do
    desc "Export all metadata by work_type"
    task :work_type, [:work_type, :keys] => [:environment]  do |_task, args|
        ExportByWorkTypeJob.perform_later(args[:work_type], args[:keys])
        puts "La exportación por tipo de Trabajo ha iniciado"
    end

    desc "Export all metadata by collection"
    task :collection, [:collection, :keys] => [:environment]  do |_task, args|
        ExportByCollectionJob.perform_later(args[:collection], args[:keys])
        puts "La exportación por colección ha iniciado"
    end

    desc "Export all metadata by thematic_collection"
    task :collection, [:collection, :keys] => [:environment]  do |_task, args|
        ExportByThematicCollectionJob.perform_later(args[:collection], args[:keys])
        puts "La exportación por colección temática ha iniciado"
    end

    desc "Export all metadata"
    task :all, [:keys] => [:environment]  do |_task, args|
        ExportAllJob.perform_later(args[:keys])
        puts "La exportación ha iniciado"
    end
end