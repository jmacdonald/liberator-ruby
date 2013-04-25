class Dir
  def self.real_entries(path)
    Dir.entries(path).select do |entry|
      absolute_path = path + '/' + entry
      !File.symlink?(absolute_path) && entry != '.' && entry != '..'
    end
  end

  def self.size(path)
    if Dir.exists? path
      size = `du -ks "#{path}" 2> /dev/null`
      size.split("\t").first.to_i*1024 if size != ''
    end
  end
end
