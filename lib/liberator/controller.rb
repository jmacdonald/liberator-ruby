module Liberator
  class Controller
    def initialize(view=nil)
      @view = view
      @view.update_status_bar "Analyzing #{Dir.pwd}..." unless @view.nil?
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
          @view.update_status_bar "Analyzing #{@directory.selected_entry[:path]}..." unless @view.nil?
          @directory = Directory.new @directory.selected_entry[:path]
          render
        end
      when 'h'
        @view.update_status_bar "Analyzing #{File.expand_path(@directory.path + '/..')}..." unless @view.nil?
        @directory = @directory.parent
        render
      when 'x'
        @directory.delete_selected_entry if @view.confirm_delete
        @directory.refresh
        render
      end
    end

    def render
      @view.refresh(@directory.path, @directory.entries, @directory.selected_index) unless @view.nil?
    end
  end
end
