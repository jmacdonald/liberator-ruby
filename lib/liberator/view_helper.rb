module Liberator
  module ViewHelper
    GIGABYTE = 1073741824
    MEGABYTE = 1048576
    KILOBYTE = 1024

    def formatted_size(size)
      return '-' if size.nil?

      if size >= GIGABYTE
        "#{size / GIGABYTE} GB"
      elsif size >= MEGABYTE
        "#{size / MEGABYTE} MB"
      elsif size >= KILOBYTE
        "#{size / KILOBYTE} KB"
      else
        "#{size} bytes"
      end
    end

    def entry_name(path)
      name = path[path.rindex('/')+1..-1]
      name += '/' if File.directory? path
      name
    end
  end
end
