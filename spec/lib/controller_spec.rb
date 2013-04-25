require 'spec_helper'

describe Liberator::Controller do
  before :each do
    @view = double 'view', update_status_bar: true, refresh: true
    @controller = Liberator::Controller.new @view
  end

  describe 'constructor' do
    it 'displays a loading screen' do
      @view.should_receive :update_status_bar
      controller = Liberator::Controller.new @view
    end

    it 'refreshes the view' do
      @view.should_receive :refresh
      controller = Liberator::Controller.new @view
    end
  end

  describe 'key_pressed method' do
    context 'j key' do
      it 'selects the next entry' do
        expected_value = @controller.instance_eval { @directory.entries[1] }
        @controller.handle_key 'j'
        selected_value = @controller.instance_eval { @directory.selected_entry }
        selected_value.should equal(expected_value)
      end

      it 'refreshes the view' do
        @view.should_receive :refresh
        @controller.handle_key 'j'
      end
    end

    context 'k key' do
      it 'selects the previous entry' do
        # Select the next entry, so we can actually move to a previous value.
        @controller.instance_eval { @directory.select_next_entry }
        expected_value = @controller.instance_eval { @directory.entries[0] }
        @controller.handle_key 'k'
        selected_value = @controller.instance_eval { @directory.selected_entry }
        selected_value.should equal(expected_value)
      end

      it 'refreshes the view' do
        @view.should_receive :refresh
        @controller.handle_key 'k'
      end
    end

    context 'enter key' do
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

        it 'displays a loading screen' do
          @view.should_receive :update_status_bar
          @controller.handle_key 10
        end

        it 'refreshes the view' do
          @view.should_receive :refresh
          @controller.handle_key 10
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

        it 'does not refresh the view' do
          @view.should_not_receive :refresh
          @controller.handle_key 10
        end
      end

      context 'an unreadable directory is selected' do
        before :each do
          # Create the directory and refresh the cache entries so it appears.
          FileUtils.mkdir 'unreadable', mode: 000
          @controller.instance_eval { @directory.refresh }

          # Select the unreadable directory.
          @selected_entry = @controller.instance_eval { @directory.selected_entry }
          until @selected_entry[:path] == File.expand_path('./unreadable')
            @controller.instance_eval { @directory.select_next_entry }
            @selected_entry = @controller.instance_eval { @directory.selected_entry }
          end
        end

        after :each do
          FileUtils.rmdir 'unreadable'
        end

        it 'does not throw an IOError exception' do
          expect { @controller.handle_key 10 }.to_not raise_error(IOError)
        end

        it 'does not change directories' do
          # Trigger the key and expect the directory to remain.
          old_directory = @controller.instance_eval { @directory }
          @controller.handle_key 10
          selected_directory = @controller.instance_eval { @directory }
          selected_directory.should equal old_directory
        end

        it 'displays a message regarding permissions' do
          @view.should_receive(:update_status_bar).with 'Cannot change directories due to permissions'
          @controller.handle_key 10
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

        it 'refreshes the view' do
          @view.should_receive :refresh
          @controller.handle_key 'h'
        end
      end
    end
  end
end
