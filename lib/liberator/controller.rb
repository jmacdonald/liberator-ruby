module Liberator
  class Controller
    def initialize(view=nil)
      @view = view
      @directory = Directory.new Dir.pwd
      render
    end

    def listen
      loop do
        handle_key @view.capture_keystroke unless @view.nil?
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
        if File.directory? @directory.selected_entry[:path]
          @directory = Directory.new @directory.selected_entry[:path]
          render
        end
      when 'h'
        @directory = @directory.parent
        render
      when 'x'
        @view.confirm_delete
        render
      end
    end

    def render
      @view.refresh(@directory.path, @directory.entries, @directory.selected_index) unless @view.nil?
    end
  end
end
