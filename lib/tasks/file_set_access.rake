namespace :file_set_access do
  desc 'change access permission to FileSet, open or restricted'
  task :change, [:permission, :text ] => [:environment]  do |_task, args|
  
    FileSetAccessJob.perform_later(args[:permission], args[:text])
    
  end
end
