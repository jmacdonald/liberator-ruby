require 'spec_helper'

describe Dir do
  describe 'real_entries' do
    context 'when passed the current directory' do
      before :each do
        @path = File.expand_path '.'
        File.symlink 'lib', "#{@path}/symlink"

        @entries = Dir.real_entries @path
      end

      after :each do
        File.unlink "#{@path}/symlink"
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
            absolute_path = @path + '/' + entry
            File.symlink?(absolute_path).should_not be_true
          end
        end
      end
    end

    context 'in another directory' do
      before :each do
        @path = File.expand_path 'spec'
        File.symlink 'lib', "#{@path}/symlink"

        @entries = Dir.real_entries @path
      end

      after :each do
        File.unlink "#{@path}/symlink"
      end

      describe 'returned object' do
        it 'does not include symlink paths' do
          @entries.each do |entry|
            absolute_path = @path + '/' + entry
            File.symlink?(absolute_path).should_not be_true
          end
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
      (`du -ks "."`.split("\t").first.to_i*1024).should == @directory_size
    end

    it 'returns nil when illegal values are passed to it' do
      Dir.size('echo "test"').should be_nil
    end

    context 'when passed an unreadable directory' do
      before :each do
        # Create nested unreadable structure, as some filesystems
        # will return a size for directories if their parent is readable.
        FileUtils.mkdir 'unreadable'
        FileUtils.mkdir 'unreadable/unreadable', mode: 0000
        FileUtils.chmod 0000, 'unreadable'
      end

      after :each do
        FileUtils.chmod 0700, 'unreadable'
        FileUtils.chmod 0700, 'unreadable/unreadable'
        FileUtils.rmdir 'unreadable/unreadable'
        FileUtils.rmdir 'unreadable'
      end

      it 'does not throw an exception' do
        expect { Dir.size 'unreadable/unreadable' }.to_not raise_error
      end

      it 'returns nil' do
        Dir.size('unreadable/unreadable').should be_nil
      end
    end
  end
end
