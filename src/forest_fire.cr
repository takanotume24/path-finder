# TODO: Write documentation for `ForestFire`
require "random"

module ForestFire
  VERSION = "0.1.0"
  enum CellStatus
    VACANT
    TREE
    READY
    FIRE
    ASH
  end

  class Map
    def initialize(array : Array(Array(Int32)))
      @array = array
    end

    def get_next_gen(now, fired_cell)
      rule = [[0, 0, 0, 0, 0, 0, 0, 0, 0, nil],
              [1, 2, 2, 2, 2, 3, 3, 3, 3, nil],
              [2, 3, 3, 4, 4, 5, 5, 5, 5, nil],
              [3, 4, 4, 5, 5, 5, 5, 5, 5, nil],
              [4, 5, 5, 5, 5, 5, 5, 5, 5, nil],
              [nil, 6, 6, 6, 6, 6, 6, 6, 6, 6],
              [nil, 7, 7, 7, 7, 7, 7, 7, 7, 7],
              [nil, 8, 8, 8, 8, 8, 8, 8, 8, 8],
              [nil, 9, 9, 9, 9, 9, 9, 9, 9, 9],
              [9, 9, 9, 9, 9, 9, 9, 9, 9, nil]]
      next_gen = rule[now][fired_cell]
      if next_gen.nil?
        abort
      end

      next_gen
    end

    def get_cell_status(cell_num) : CellStatus
      case cell_num
      when 0
        return CellStatus::VACANT
      when 1
        return CellStatus::TREE
      when 2, 3, 4
        return CellStatus::READY
      when 5, 6, 7, 8
        return CellStatus::FIRE
      when 9
        return CellStatus::ASH
      else
        return CellStatus::ASH
      end
    end

    def get(x, y) : Int32
      array_x = @array[x]?
      if !array_x
        return 0
      end

      xy = array_x[y]?
      if !xy
        return 0
      end

      return xy
    end

    def is_fire?(cell_num)
      if get_cell_status(cell_num) == CellStatus::FIRE
        return 1
      else
        return 0
      end
    end

    def count(x, y)
      count = 0
      # [x-1][y-1]  [x][y-1]  [x+1][y-1]
      # [x-1][y]    [x][y]    [x+1][y]
      # [x-1][y+1]  [x][y+1]  [x+1][y+1]
      count += is_fire? get x, y
      count += is_fire? get x - 1, y - 1
      count += is_fire? get x, y - 1
      count += is_fire? get x + 1, y - 1
      count += is_fire? get x - 1, y
      count += is_fire? get x + 1, y
      count += is_fire? get x - 1, y + 1
      count += is_fire? get x, y + 1
      count += is_fire? get x + 1, y + 1
      return count
    end

    def next_gen(x, y) : Int32
      now = get x, y
      fired_cell = count x, y
      get_next_gen now, fired_cell
    end

    def next_map
      new_map = @array.clone
      @array.each_index do |x_i|
        @array[x_i].each_index do |y_i|
          new_map[x_i][y_i] = next_gen x_i, y_i
        end
      end
      @array = new_map
    end

    def show
      `clear`
      @array.each do |a|
        a.each do |cell|
          cell_status = get_cell_status cell
          char = case cell_status
                 in CellStatus::VACANT
                   "⬜"
                 in CellStatus::TREE
                   "🌲"
                 in CellStatus::READY
                   "🟨"
                 in CellStatus::FIRE
                   "🔥"
                 in CellStatus::ASH
                   "⬛"
                 end
          print "#{char}"
        end
        print "\n"
      end
      puts ""
    end
  end

  class Game
    def initialize(array : Array(Array(Int32)), one_frame : Bool = false)
      @one_frame = one_frame
      @map = Map.new(array)
    end

    def run
      while true
        @map.show
        @map.next_map
        sleep(0.1)

        if @one_frame
          gets
        end
      end
    end
  end
end
