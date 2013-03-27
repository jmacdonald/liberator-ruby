require 'spec_helper'

describe Dir do
  describe 'size method' do
    before :each do
      @directory_size = Dir.size '.'
    end

    it 'returns an integer' do
      @directory_size.should be_an Integer
    end

    it 'calculates the correct size' do
      calculate_directory_size = lambda do |path|
        size = 0
        full_path = File.expand_path(path) + '/'
        Dir.entries(full_path).each do |entry|
          # Skip meta-directories.
          next if entry == '.' || entry == '..'

          if File.file? full_path + entry
            size += File.size(full_path + entry)
          elsif File.directory? full_path + entry
            size += calculate_directory_size.call(full_path + entry)
          end
        end
        size
      end

      @directory_size.should == calculate_directory_size.call('.')
    end
  end
end
