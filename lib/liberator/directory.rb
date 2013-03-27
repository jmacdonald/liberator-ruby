module Liberator
  class Directory
    attr_reader :path, :entries
    def initialize(path)
      @path = File.expand_path path
      @entries = Dir.entries(@path).collect do |entry|
        # Skip meta-directories.
        next if entry == '.' || entry == '..'

        absolute_path = @path + '/' + entry

        if File.file? absolute_path
          size = File.size absolute_path
        elsif File.directory? absolute_path
          size = Dir.size absolute_path
        else
          next
        end

        { path: absolute_path, size: size }
      end
      @entries.compact!
    end
  end
end
