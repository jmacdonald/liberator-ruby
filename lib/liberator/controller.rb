module Liberator
  class Controller
    def initialize(view)
      @view = view
      @view.update_status_bar "Analyzing #{Dir.pwd}..."
      @directory = Directory.new Dir.pwd
      render
    end

    def listen
      loop do
        handle_key @view.capture_keystroke
      end
    end

    def handle_key(key)
      case key
      when 'q'
        @view.close
        exit
      when 'j'
        @directory.select_next_entry
        render
      when 'k'
        @directory.select_previous_entry
        render
      when 10
        enter_selected_directory
      when 'h'
        @view.update_status_bar "Analyzing #{File.expand_path(@directory.path + '/..')}..."
        @directory = @directory.parent
        render
      when 'x'
        @directory.delete_selected_entry if @view.confirm_delete
        @directory.refresh
        render
      end
    end

    def render
      @view.refresh(@directory.path, @directory.entries, @directory.selected_index)
    end

    def enter_selected_directory
      if File.directory? @directory.selected_entry[:path]
        @view.update_status_bar "Analyzing #{@directory.selected_entry[:path]}..."
        begin
          @directory = Directory.new @directory.selected_entry[:path]
        rescue IOError
          @view.update_status_bar "Cannot change directories due to permissions"
        end
        render
      end
    end
  end
end
