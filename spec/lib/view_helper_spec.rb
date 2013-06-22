require 'spec_helper'

class ViewHelperClass
  include Liberator::ViewHelper
end

describe ViewHelperClass do
  before :each do
    @view_helper = ViewHelperClass.new
  end

  describe 'formatted_size method' do
    context 'when passed less than a kilobyte' do
      it 'returns the size in bytes' do
        @view_helper.formatted_size(1000).should == '1000 bytes'
      end
    end

    context 'when passed a kilobyte' do
      it 'returns the size in kilobytes' do
        @view_helper.formatted_size(1024).should == '1 KB'
      end
    end

    context 'when passed a megabyte' do
      it 'returns the size in megabytes' do
        @view_helper.formatted_size(1048576).should == '1 MB'
      end
    end

    context 'when passed a gigabyte' do
      it 'returns the size in gigabytes' do
        @view_helper.formatted_size(1073741824).should == '1 GB'
      end
    end
  end
end
