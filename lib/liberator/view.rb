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
    end

    def refresh(directory, entries, selected_entry)
      @entry_window.clear

      entries.each do |entry|
        # Turn on highlighting, if this entry is selected.
        @entry_window.standout if entry == selected_entry

        # Print the formatted size.
        size = entry[:size]
        if size > GIGABYTE
          formatted_size = "#{size / GIGABYTE} GB"
        elsif size > MEGABYTE
          formatted_size = "#{size / MEGABYTE} MB"
        elsif size > KILOBYTE
          formatted_size = "#{size / KILOBYTE} KB"
        else
          formatted_size = "#{size} bytes"
        end

        # Get the file/directory name, without its full path.
        name = entry[:path][entry[:path].rindex('/')+1..-1]
        name += '/' if File.directory? entry[:path]

        # Right-justify the file/directory size.
        formatted_size = formatted_size.rjust @entry_window.maxx - name.length
        @entry_window << name + formatted_size

        # Stop highlighting.
        @entry_window.standend
      end

      update_status_bar directory

      @entry_window.refresh
    end

    def update_status_bar(directory)
      @status_bar.setpos 0, 0
      formatted_directory = directory.ljust @width
      @status_bar << formatted_directory

      @status_bar.refresh
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
