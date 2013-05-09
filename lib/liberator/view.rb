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
      # Clear the screen manually, since clear function causes blinking.
      @entry_window.setpos 0, 0
      height.times { @entry_window.deleteln }

      # Figure out what to draw based on the selected entry and height of the window.
      if selected_index < height-1
        visible_range = (0...height)
      elsif selected_index == entries.size-1 # last item selected
        visible_range = (entries.size-height..entries.size)
      else
        visible_range = (selected_index-height+2..selected_index+1)
      end

      entries[visible_range].each_with_index do |entry, index|
        # Get the file/directory name, without its full path.
        name = entry[:path][entry[:path].rindex('/')+1..-1]
        name += '/' if File.directory? entry[:path]

        draw_line name, formatted_size(entry[:size]), index+visible_range.begin == selected_index
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
  end
end
