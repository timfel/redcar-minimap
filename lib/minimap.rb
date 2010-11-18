require 'minimap/shell'

module Redcar
  # This class is your plugin. Try adding new commands in here
  # and putting them in the menus.
  class Minimap
    attr_reader :window

    # This method is run as Redcar is booting up.
    def self.menus
      # Here's how the plugin menus are drawn. Try adding more
      # items or sub_menus.
      Menu::Builder.build do
        sub_menu "View" do
          item "Toggle Minimap", ToggleMinimapCommand
        end
      end
    end

    def self.in_window
      @minimaps ||= {}
    end

    def initialize(window)
      Minimap.in_window[window] = self
      @window = window
      @shell = Shell.new(@window)
      @window.add_listener(:tab_focussed) {|tab| @shell.assign_tab(tab) }
      @window.add_listener(:closed) {|w| close }
    end

    def close
      self.class.in_window.delete(@window)
      # @window.remove_listener(self)
      @shell.dispose
    end

    # Example command: showing a dialog box.
    class ToggleMinimapCommand < Redcar::TabCommand
      def execute
        if Minimap.in_window[Redcar.app.focussed_window]
          Minimap.in_window[Redcar.app.focussed_window].close
        else
          Minimap.new(Redcar.app.focussed_window)
        end
      end
    end
  end
end
