require 'spec_helper'

describe Dir do
  describe 'real_entries' do
    before :each do
      File.symlink 'lib', 'symlink'

      @entries = Dir.real_entries Dir.pwd
    end

    after :each do
      File.unlink 'symlink'
    end

    it 'returns an array' do
      @entries.should be_an Array
    end

    describe 'returned object' do
      it 'contains strings' do
        @entries.each do |entry|
          entry.should be_a String
        end
      end

      it 'does not include the current directory' do
        @entries.should_not include '.'
      end

      it 'does not include the parent directory' do
        @entries.should_not include '..'
      end

      it 'does not include symlink paths' do
        @entries.each do |entry|
          File.symlink?(entry).should_not be_true
        end
      end
    end
  end
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
