require 'spec_helper'

describe Liberator::Directory do
  before :each do
    @directory = Liberator::Directory.new '.'
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
      @directory.respond_to?(:selected_entry).should be_true
    end

    describe 'return value' do
      it 'defaults to the first entry' do
        @directory.selected_entry.should equal(@directory.entries.first)
      end
    end
  end
end
