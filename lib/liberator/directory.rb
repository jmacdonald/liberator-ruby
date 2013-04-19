module Liberator
  class Directory
    attr_reader :path, :entries, :selected_index
    def initialize(path)
      @path = File.expand_path path
      cache_entries
    end

    def selected_entry
      @entries[@selected_index]
    end

    def select_previous_entry
      @selected_index -= 1 if @selected_index > 0
    end

    def select_next_entry
      @selected_index += 1 unless @selected_index >= @entries.size-1
    end

    def parent
      Directory.new File.expand_path(@path + '/..')
    end

    def delete_selected_entry
      FileUtils.rm_rf selected_entry[:path]
    end

    def refresh
      begin
        @entries = Dir.real_entries(@path).collect do |entry|
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
        @entries = @entries.compact.sort_by { |entry| 1.0/entry[:size].to_f }
        @selected_index = 0
      rescue
        raise IOError.new
      end
    end
    alias_method :cache_entries, :refresh
  end
end
