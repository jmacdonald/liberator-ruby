module Liberator
  class View
    GIGABYTE = 1073741824
    MEGABYTE = 1048576
    KILOBYTE = 1024

    def initialize
      # Initialize curses view.
      Curses.init_screen
      Curses.noecho
      Curses.curs_set 0
      Curses.cbreak
      @height = Curses.stdscr.maxy
      @width = Curses.stdscr.maxx

      @entry_window = Curses::Window.new @height-1, @width, 0, 0

      @status_bar = Curses::Window.new 1, @width, @height-1, 0
      @status_bar.standout

      @scroll_offset = 0
    end

    def refresh(directory, entries, selected_index)
      clear_screen

      visible_entries = entries[calculate_visible_range(entries, selected_index)]
      visible_entries.each_with_index do |entry, index|
        draw_line entry_name(entry[:path]), formatted_size(entry[:size]), entries[selected_index] == entry
      end

      update_status_bar directory
    end

    def update_status_bar(content)
      @status_bar.setpos 0, 0
      formatted_content = content.ljust @width
      @status_bar << formatted_content

      @status_bar.refresh
    end

    def formatted_size(size)
      return '-' if size.nil?

      if size > GIGABYTE
        "#{size / GIGABYTE} GB"
      elsif size > MEGABYTE
        "#{size / MEGABYTE} MB"
      elsif size > KILOBYTE
        "#{size / KILOBYTE} KB"
      else
        "#{size} bytes"
      end
    end

    def capture_keystroke
      @entry_window.getch
    end

    def confirm_delete
      update_status_bar "Really delete? (y to confirm)"
      capture_keystroke == 'y'
    end

    def close
      # Clean up curses view.
      Curses.close_screen
    end

    def height
      @entry_window.maxy
    end

    private

    def draw_line(left_content='', right_content='', highlight=false)
      @entry_window.standout if highlight

      line_content = left_content + right_content.rjust(@entry_window.maxx - left_content.length)
      @entry_window << line_content

      @entry_window.standend
    end

    def clear_screen
      # Clear the screen manually, since curses clear function causes blinking.
      @entry_window.setpos 0, 0
      height.times { @entry_window.deleteln }
    end

    def entry_name(path)
      name = path[path.rindex('/')+1..-1]
      name += '/' if File.directory? path
      name
    end

    def calculate_visible_range(entries, selected_index)
      if selected_index < height-1
        (0...height)
      elsif selected_index == entries.size-1 # last item selected
        (entries.size-height..entries.size)
      else
        (selected_index-height+2..selected_index+1)
      end
    end
  end
end
