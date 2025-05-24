class AccessFileSetJob < ApplicationJob
  queue_as :default

  def perform(file_set_id, permit)
    fs = FileSet.find file_set_id
    if permit != "" then
      fs.visibility = "restricted"
    else
      fs.visibility = "open"
    end
    fs.save
  end
end
