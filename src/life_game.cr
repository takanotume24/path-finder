# TODO: Write documentation for `LifeGame`
require "random"

module LifeGame
  VERSION = "0.1.0"
  enum CellStatus
    BIRTH          # 誕生
    SUVIVE         # 生存
    DEPOPULATION   # 過疎
    OVERPOPULATION # 過密
    DEAD
  end

  class Map
    def initialize(x : Int32, y : Int32)
      @array = Array(Array(Int32)).new(y) { |i| Array(Int32).new(x) { |i| Random.rand(2) } }
      # @array = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      #           [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      #           [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      #           [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      #           [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      #           [0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0],
      #           [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      #           [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      #           [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      #           [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      #           [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      #           [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      # ]
    end

    def get(x, y) : Int32
      if !@array[x]?
        return 0
      end

      if !@array[x][y]?
        return 0
      end

      return @array[x][y]
    end

    def count(x, y)
      count = 0
      # [x-1][y-1]  [x][y-1]  [x+1][y-1]
      # [x-1][y]    [x][y]    [x+1][y]
      # [x-1][y+1]  [x][y+1]  [x+1][y+1]
      count += get x - 1, y - 1
      count += get x, y - 1
      count += get x + 1, y - 1
      count += get x - 1, y
      count += get x + 1, y
      count += get x - 1, y + 1
      count += get x, y + 1
      count += get x + 1, y + 1

      return count
    end

    def next_gen(x, y) : CellStatus
      c = count x, y

      if @array[x][y] == 1
        case
        when c == 2, c == 3
          return CellStatus::SUVIVE
        when c <= 1
          return CellStatus::DEPOPULATION
        when c >= 4
          return CellStatus::OVERPOPULATION
        else
          return CellStatus::DEAD
        end
      else
        case
        when c == 3
          return CellStatus::BIRTH
        else
          return CellStatus::DEAD
        end
      end
    end

    def apply(status : CellStatus) : Int32
      case status
      in CellStatus::BIRTH
        return 1
      in CellStatus::SUVIVE
        return 1
      in CellStatus::DEPOPULATION
        return 0
      in CellStatus::OVERPOPULATION
        return 0
      in CellStatus::DEAD
        return 0
      end
    end

    def next_map
      new_map = @array.clone
      @array.each_index do |x_i|
        @array[x_i].each_index do |y_i|
          status = next_gen x_i, y_i
          new_map[x_i][y_i] = apply status
        end
      end
      @array = new_map
    end

    def show
      @array.each do |a|
        a.each do |cell|
          print "#{cell == 1 ? "■ " : "□ "}"
        end
        print "\n"
      end
      puts ""
    end
  end

  class Game
    def initialize(x : Int32, y : Int32)
      @map = Map.new(x, y)
    end

    def run
      while true
        @map.next_map
        @map.show
        sleep(0.1)
      end
    end
  end
end
