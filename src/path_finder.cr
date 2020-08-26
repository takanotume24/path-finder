# TODO: Write documentation for `ForestFire`
require "random"
require "csv"

module ForestFire
  VERSION = "0.1.0"

  class Cell
    getter cost, step, updated
    setter cost, step, updated

    def initialize(@cost : Int32, @step = 0, @updated : Bool = false)
    end

    def add
      self.step += 1
    end

    def_clone
  end

  class Point
    getter x : Int32
    getter y : Int32

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
    def initialize(@array : Array(Array(Cell)), @start : Point, @goal : Point, @processing_cost : Int32 = 0, @queue = Deque(Point).new)
      @queue << @start
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

        add_cost_around_cells point, @array
        show
      end

      # @array = array
    end

    def add_cost_around_cells(origin : Point, array = @array)
      add_cost origin.upper, origin, array
      add_cost origin.bottom, origin, array
      add_cost origin.left, origin, array
      add_cost origin.right, origin, array
    end

    def add_cost(target : Point, origin : Point, array = @array)
      origin_cell = get origin, array
      target_cell = get target, array

      if origin_cell.nil?
        abort
      end

      pp target_cell
      if target_cell
        if !target_cell.updated
          origin_cell.updated = true
          target_cell.updated = true
          target_cell.step += origin_cell.step + 1
          @queue << target
        end
      end
    end

    def get(point : Point, array = @array) : Cell?
      x = point.x
      y = point.y
      x_max = array[0].size
      y_max = array.size

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
          print "#{@array[x][y].step.to_s}\t#{x},#{y}\t"
        end
        print "\n"
      end
      puts ""
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

      if @one_frame
        gets
      end
    end
  end
end
