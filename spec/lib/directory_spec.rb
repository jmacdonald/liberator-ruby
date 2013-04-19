require 'spec_helper'
require 'fileutils'

describe Liberator::Directory do
  before :each do
    @directory = Liberator::Directory.new '.'
  end

  describe 'constructor' do
    context 'with an unreadable directory' do
      before :all do
        FileUtils.mkdir 'unreadable', mode: 000
      end

      after :all do
        FileUtils.rmdir 'unreadable'
      end

      it 'raises an IOError exception' do
        expect { @directory = Liberator::Directory.new 'unreadable' }.to raise_error(IOError)
      end
    end
  end

  describe 'path attribute' do
    it "is the absolute equivalent of the constructor's path argument" do
      @directory.path.should == File.expand_path('.')
    end
  end

  describe 'entries attribute' do
    it 'is an array' do
      @directory.entries.should be_an(Array)
    end

    it 'does not contain nil values' do
      @directory.entries.each do |entry|
        entry.should_not be_nil
      end
    end

    it 'contains Hash objects' do
      @directory.entries.first.should be_a(Hash)
    end

    it 'is reverse sorted by size' do
      (0..@directory.entries.size-2).each do |index|
        @directory.entries[index][:size].should be >= @directory.entries[index+1][:size]
      end
    end

    describe 'entry hash' do
      before :each do
        @hash = @directory.entries.first
      end

      describe 'path attribute' do
        it 'exists' do
          @hash.should have_key(:path)
        end

        it 'is an absolute path' do
          @hash[:path].start_with?(@directory.path).should be_true
        end
      end

      describe 'size attribute' do
        it 'exists' do
          @hash.should have_key(:size)
        end

        it 'is an integer' do
          @hash[:size].should be_an(Integer)
        end
      end
    end
  end

  describe 'selected_entry method' do
    it 'exists' do
      @directory.should respond_to(:selected_entry)
    end

    describe 'return value' do
      it 'defaults to the first entry' do
        @directory.selected_entry.should equal(@directory.entries.first)
      end
    end
  end

  describe 'select_next_entry method' do
    it 'exists' do
      @directory.should respond_to(:select_next_entry)
    end

    context 'first entry is selected' do
      it 'selects the second entry' do
        @directory.select_next_entry
        @directory.selected_entry.should equal(@directory.entries[1])
      end
    end

    context 'last entry is selected' do
      before :each do
        @directory.instance_eval { @selected_index = @entries.size-1 }
      end

      it 'does not change the selected entry' do
        previous_selection = @directory.selected_entry
        @directory.select_next_entry
        @directory.selected_entry.should equal(previous_selection)
      end
    end
  end

  describe 'select_previous_entry method' do
    it 'exists' do
      @directory.should respond_to(:select_previous_entry)
    end

    context 'first entry is selected' do
      it 'does not change the selected entry' do
        previous_selection = @directory.selected_entry
        @directory.select_previous_entry
        @directory.selected_entry.should equal(previous_selection)
      end
    end

    context 'last entry is selected' do
      before :each do
        @directory.instance_eval { @selected_index = @entries.size-1 }
      end

      it 'selects the second last entry' do
        @directory.select_previous_entry
        @directory.selected_entry.should equal(@directory.entries[@directory.entries.size-2])
      end
    end
  end

  describe 'parent method' do
    it 'exists' do
      @directory.should respond_to(:parent)
    end

    describe 'return value' do
      it 'is a directory' do
        @directory.parent.should be_a(Liberator::Directory)
      end

      it 'points to the parent directory' do
        @directory.parent.path.should == File.expand_path('..')
      end
    end
  end

  describe 'delete_selected_entry' do
    it 'exists' do
      @directory.should respond_to(:delete_selected_entry)
    end

    context 'a file is selected' do
      it 'deletes the selected file' do
        FileUtils.touch 'test_file'
        file_path = File.expand_path('./test_file')
        directory = Liberator::Directory.new '.'
        directory.select_next_entry until directory.selected_entry[:path] == file_path
        directory.delete_selected_entry
        File.exists?(file_path).should be_false
      end
    end

    context 'a directory is selected' do
      before :each do
        FileUtils.rm_rf 'test_dir' if Dir.exists? 'test_dir'
      end

      context 'with no files' do
        it 'deletes the directory' do
          Dir.mkdir 'test_dir'
          dir_path = File.expand_path('./test_dir')
          directory = Liberator::Directory.new '.'
          directory.select_next_entry until directory.selected_entry[:path] == dir_path
          directory.delete_selected_entry
          Dir.exists?(dir_path).should be_false
        end
      end

      context 'with a file' do
        it 'deletes the directory' do
          Dir.mkdir 'test_dir'
          FileUtils.touch 'test_dir/test_file'
          dir_path = File.expand_path('./test_dir')
          directory = Liberator::Directory.new '.'
          directory.select_next_entry until directory.selected_entry[:path] == dir_path
          directory.delete_selected_entry
          Dir.exists?(dir_path).should be_false
        end
      end
    end
  end

  describe 'refresh method' do
    it 'exists' do
      @directory.should respond_to(:refresh)
    end

    it 'updates cached entries' do
      initial_entry_count = @directory.entries.size
      FileUtils.touch 'test_file'
      @directory.refresh
      @directory.entries.size.should_not == initial_entry_count
      File.unlink 'test_file'
    end

    it 'resets the selected_index to 0' do
      @directory.select_next_entry
      @directory.refresh
      @directory.selected_index.should == 0
    end
  end

  describe 'cache_entries method' do
    it 'exists' do
      @directory.should respond_to(:cache_entries)
    end

    it 'is an alias of the refresh method' do
      @directory.method(:cache_entries).should == @directory.method(:refresh)
    end
  end
end
