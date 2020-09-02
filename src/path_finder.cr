# TODO: Write documentation for `PathFinder`
require "random"
require "csv"
require "colorize"

module PathFinder
  VERSION = "0.1.0"

  class Cell
    getter cost, step, updated, on_route
    setter cost, step, updated, on_route

    def initialize(@cost : Int32, @step = 0, @updated = false, @on_route = false)
    end

    def add(original : Cell)
      self.step = (original.step + self.cost)
    end

    def add_except(original : Cell)
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
      @queue = Deque(Point).new,
      @route = Deque(Point).new
    )
      @queue << @start
      @route << @goal
    end

    def update
      array = @array.clone

      point = 1
      while @queue.size != 0
        pp @queue
        point = @queue.shift?
        if point.nil?
          break
        end

        add_costs_around_cell point, @array
        show
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
        pp "#{target_cell.add_except(origin_cell)}, #{target_cell.step}"

        if !target_cell.updated || target_cell.add_except(origin_cell) < target_cell.step
          origin_cell.updated = true
          target_cell.updated = true
          target_cell.add origin_cell
          @queue << target
        end
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
          step = @array[x][y].step.to_s
          if @array[x][y].on_route
            step = step.colorize(:yellow).bold
          end
          print "[#{x},#{y}]\t#{step}\t"
        end
        print "\n"
      end
      puts ""
    end

    def make_route
      now = @goal

      while now != @start
        now = get_min_step_cell_around_cell now
        pp now
        @route << now
        @array[now.x][now.y].on_route = true
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
      @map.show
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
