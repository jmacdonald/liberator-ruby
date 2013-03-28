class Dir
  def self.real_entries(path)
    Dir.entries(path).select do |entry|
      absolute_path = path + '/' + entry
      !File.symlink?(absolute_path) && entry != '.' && entry != '..'
    end
  end

  def self.size(path)
    size = 0
    full_path = File.expand_path(path) + '/'
    Dir.real_entries(full_path).each do |entry|
      if File.file? full_path + entry
        size += File.size full_path + entry
      elsif File.directory? full_path + entry
        size += Dir.size full_path + entry
      end
    end
    size
  end
end
