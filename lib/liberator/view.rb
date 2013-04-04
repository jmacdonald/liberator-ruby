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

    def refresh(directory, entries, selected_entry)
      @entry_window.clear

      entries[@scroll_offset..@entry_window.maxy+@scroll_offset-1].each do |entry|
        # Turn on highlighting, if this entry is selected.
        @entry_window.standout if entry == selected_entry

        # Get the file/directory name, without its full path.
        name = entry[:path][entry[:path].rindex('/')+1..-1]
        name += '/' if File.directory? entry[:path]

        # Add the row to the window, appending a right-justified human-readable size.
        @entry_window << name + formatted_size(entry[:size]).rjust(@entry_window.maxx - name.length)

        # Stop highlighting.
        @entry_window.standend
      end

      update_status_bar directory

      @entry_window.refresh
    end

    def update_status_bar(content)
      @status_bar.setpos 0, 0
      formatted_content = content.ljust @width
      @status_bar << formatted_content

      @status_bar.refresh
    end

    def formatted_size(size)
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

    def close
      # Clean up curses view.
      Curses.close_screen
    end
  end
end
