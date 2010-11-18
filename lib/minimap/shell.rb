module Redcar
  class Minimap
    class Shell
      FIXED_WIDTH  = 200
      REDRAW_PAUSE = 200
      attr_accessor :minimap_height, :window, :bounds, :tab

      def initialize(window)
        @last_redraw = 0
        @window = window
        create_widget
        assign_tab
        redraw
      end

      def create_widget
        @widget = Swt::Widgets::Shell.new(Swt::SWT::TOOL)
        @widget.layout = Swt::Layout::FillLayout.new
        @label = Swt::Widgets::Label.new(@widget, Swt::SWT::NONE)
        attach_to_window
        @widget.open
      end

      def attach_to_window
        @parent_shell = window.controller.shell
      end

      def redraw
        scaled_img = create_scaled_screenshot(tab)
        @widget.set_bounds(*calculate_bounds)
        @label.image = scaled_img
      end

      def assign_tab(new_tab = nil)
        new_tab ||= window.focussed_notebook_tab
        if new_tab.edit_tab?
          self.tab = new_tab.edit_view.controller.mate_text.control
        else
          self.tab = new_tab.controller.widget
        end
        tab.add_paint_listener do |e|
          redraw if @last_redraw + REDRAW_PAUSE > (@last_redraw = Time.now.to_i)
        end
      end

      def calculate_bounds
        parent_bounds = @parent_shell.bounds
        [ parent_bounds.x + parent_bounds.width, parent_bounds.y,
          FIXED_WIDTH, minimap_height ]
      end

      def create_scaled_screenshot(tab)
        img = Swt::Graphics::Image.new(tab.display, tab.bounds)
        gc = Swt::Graphics::GC.new(tab)
        gc.copy_area(img, 0, 0)
        scale_screenshot(img)
      end

      def scale_screenshot(img)
        tab_bounds = img.bounds
        self.minimap_height = tab_bounds.height / (tab_bounds.width / FIXED_WIDTH)
        scaled_img_data = img.image_data.scaled_to(FIXED_WIDTH, minimap_height)
        Swt::Graphics::Image.new(@widget.display, scaled_img_data)
      end
    end
  end
end
