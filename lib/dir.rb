class Dir
  def self.real_entries(path)
    Dir.entries(path).select do |entry|
      absolute_path = path + '/' + entry
      !File.symlink?(absolute_path) && entry != '.' && entry != '..'
    end
  end

  def self.size(path)
    `du -s "#{path}"`.split("\t").first.to_i if Dir.exists? path
  end
end
