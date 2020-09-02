# TODO: Write documentation for `PathFinder`
require "random"
require "csv"
require "colorize"

module PathFinder
  VERSION = "0.1.0"

  class Cell
    getter cost, step, updated, on_route, confirmed
    setter cost, step, updated, on_route, confirmed

    def initialize(@cost : Int32, @step = Int32::MAX, @updated = false, @on_route = false, @confirmed = false)
    end

    def set_cost(original : Cell)
      self.step = (original.step + self.cost)
    end

    def cost_except(original : Cell)
      return (original.step + self.cost)
    end

    def_clone
  end

  class Point
    getter x : Int32
    getter y : Int32

    def_equals @x, @y

    def initialize(@x : Int32, @y : Int32)
    end

    def upper
      Point.new(x, y + 1)
    end

    def bottom
      Point.new(x, y - 1)
    end

    def left
      Point.new(x - 1, y)
    end

    def right
      Point.new(x + 1, y)
    end
  end

  class Map
    def initialize(
      @array : Array(Array(Cell)),
      @start : Point,
      @goal : Point,
      @processing_cost : Int32 = 0,
      @update_list = Array(Point).new,
      @route = Deque(Point).new
    )
      @array[@start.x][@start.y].step = 0
      @update_list << @start
      @route << @goal
    end

    def update
      array = @array.clone

      while @update_list.size != 0
        if @array[@goal.x][@goal.y].confirmed
          break
        end

        @update_list.sort! { |a, b| get(a).not_nil!.step <=> get(b).not_nil!.step }
        # gets
        # pp @update_list.map {|a| get(a).not_nil!.step}
        point = @update_list.shift

        @array[point.x][point.y].confirmed = true
        add_costs_around_cell point, @array
      end

      # @array = array
    end

    def add_costs_around_cell(origin : Point, array = @array)
      add_cost origin.upper, origin, array
      add_cost origin.bottom, origin, array
      add_cost origin.left, origin, array
      add_cost origin.right, origin, array
    end

    def get_min_step_cell_around_cell(origin : Point) : Point
      min = {origin.upper => get(origin.upper), origin.bottom => get(origin.bottom), origin.right => get(origin.right), origin.left => get(origin.left)}.compact.min_by do |k, v|
        v.step
      end

      return min[0]
    end

    def add_cost(target : Point, origin : Point, array = @array)
      origin_cell = get origin, array
      target_cell = get target, array

      if origin_cell.nil?
        abort
      end

      if target_cell
        if target_cell.confirmed
          return
        end

        if target_cell.cost_except(origin_cell) < target_cell.step
          min_cell = get(get_min_step_cell_around_cell target).not_nil!
          target_cell.set_cost min_cell # ここで，直接繋がっている周辺のノードで，最小のコストを設定する必要がある．
        end
        @update_list << target
      end
    end

    def get(point : Point, array = @array) : Cell?
      x = point.x
      y = point.y
      x_max = array.size
      y_max = array[0].size

      if x < 0 || x_max <= x
        return nil
      end

      if y < 0 || y_max <= y
        return nil
      end

      array_x = array[x]?
      if !array_x
        return nil
      end

      xy = array_x[y]?
      if !xy
        return nil
      end

      return xy
    end

    def show
      `clear`
      @array.each_index do |x|
        @array[x].each_index do |y|
          step = @array[x][y].step.to_s.colorize

          if @array[x][y].on_route
            step = step.yellow.bold
          end
          if @array[x][y].cost > 1
            step = step.back(:red)
          end
          if @array[x][y].updated
            step = step.blue
          end

          print "#{step}\t"
        end
        print "\n"
      end
      puts ""
    end

    def make_route
      now = @goal

      while now != @start
        now = get_min_step_cell_around_cell now
        @route << now
      end
    end

    def color_route
      @route.each do |point|
        @array[point.x][point.y].on_route = true
      end
    end
  end

  class Game
    def initialize(path : String, @start : Point, @goal : Point, one_frame : Bool = false)
      @one_frame = one_frame
      csv = CSV.new(File.read path)

      map_array = Array(Array(Cell)).new

      csv.each do |c|
        x_array = Array(Cell).new

        c.row.size.times do |i|
          cost = c.row[i]
          x_array << Cell.new(cost.to_i)
        end
        map_array << x_array
      end
      @map = Map.new(map_array, @start, @goal)
    end

    def run
      @map.update
      @map.make_route
      @map.color_route
      @map.show

      if @one_frame
        gets
      end
    end
  end
end
