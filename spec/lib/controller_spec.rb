require 'spec_helper'

describe Liberator::Controller do
  before :each do
    @controller = Liberator::Controller.new
  end

  describe 'key_pressed method' do
    it 'selects the next entry when passed the "j" key' do
      expected_value = @controller.instance_eval { @directory.entries[1] }
      @controller.handle_key 'j'
      selected_value = @controller.instance_eval { @directory.selected_entry }
      selected_value.should equal(expected_value)
    end

    it 'selects the previous entry when passed the "k" key' do
      # Select the next entry, so we can actually move to a previous value.
      @controller.instance_eval { @directory.select_next_entry }
      expected_value = @controller.instance_eval { @directory.entries[0] }
      @controller.handle_key 'k'
      selected_value = @controller.instance_eval { @directory.selected_entry }
      selected_value.should equal(expected_value)
    end

    describe 'enter key' do
      context 'a directory is selected' do
        before :each do
          # Select a directory.
          @selected_entry = @controller.instance_eval { @directory.selected_entry }
          until File.directory? @selected_entry[:path]
            @controller.instance_eval { @directory.select_next_entry }
            @selected_entry = @controller.instance_eval { @directory.selected_entry }
          end
        end

        it 'changes directories' do
          # Trigger the key and expect the directory to change.
          @controller.handle_key 10
          selected_directory = @controller.instance_eval { @directory }
          selected_directory.path.should == @selected_entry[:path]
        end
      end

      context 'a file is selected' do
        before :each do
          # Select a file.
          @selected_entry = @controller.instance_eval { @directory.selected_entry }
          until File.file? @selected_entry[:path]
            @controller.instance_eval { @directory.select_next_entry }
            @selected_entry = @controller.instance_eval { @directory.selected_entry }
          end
        end

        it 'does not change directories' do
          # Trigger the key and expect the directory to remain.
          old_directory = @controller.instance_eval { @directory }
          @controller.handle_key 10
          selected_directory = @controller.instance_eval { @directory }
          selected_directory.should equal old_directory
        end
      end
    end

    describe 'h key' do
      context 'in a non-root directory' do
        it 'changes to the parent directory' do
          parent_directory = @controller.instance_eval { @directory.parent }
          @controller.handle_key 'h'
          new_directory = @controller.instance_eval { @directory }
          new_directory.path.should == parent_directory.path
        end
      end
     end
  end
end
