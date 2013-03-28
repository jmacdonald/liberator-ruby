class Dir
  def self.real_entries(path)
    Dir.entries(path).select do |entry|
      !File.symlink?(entry) && entry != '.' && entry != '..'
    end
  end

  def self.size(path)
    size = 0
    full_path = File.expand_path(path) + '/'
    Dir.entries(full_path).each do |entry|
      # Skip meta-directories
      next if entry == '.' || entry == '..'

      if File.file? full_path + entry
        size += File.size full_path + entry
      elsif File.directory? full_path + entry
        size += Dir.size full_path + entry
      end
    end
    size
  end
end
