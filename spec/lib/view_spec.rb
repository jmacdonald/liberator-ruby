require 'spec_helper'

describe Liberator::View do
  describe '#initialize' do
    before :each do
      # Stub out Curses module.
      # We can't replace this with a double since
      # Curses::Window would be inaccessible.
      Curses.stub(:init_screen)
      Curses.stub(:noecho)
      Curses.stub(:curs_set)
      Curses.stub(:cbreak)
      Curses.stub_chain(:stdscr, :maxy).and_return(140)
      Curses.stub_chain(:stdscr, :maxx).and_return(140)

      # Stub out Curses::Window.
      @window = double('Curses::Window')
      stub_const('Curses::Window', @window)
      @window.stub(:new).and_return(@window)
      @window.stub(:standout)
      @window.stub(:standend)
    end

    it 'initializes the screen' do
      Curses.should_receive(:init_screen)
      Liberator::View.new
    end

    it 'disables key echoing' do
      Curses.should_receive(:noecho)
      Liberator::View.new
    end
  end
end
