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
      @window = Curses.stdscr
    end

    def display_entries(entries, selected_entry)
      @window.clear
      @window.refresh

      entries.each do |entry|
        # Turn on highlighting, if this entry is selected.
        @window.standout if entry == selected_entry

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
        formatted_size = formatted_size.rjust @window.maxx - name.length
        @window << name + formatted_size

        # Stop highlighting.
        @window.standend
      end

      #@window.refresh
    end

    def capture_keystroke
      @window.getch
    end

    def close
      # Clean up curses view.
      Curses.close_screen
    end
  end
end
