require "./path_finder.cr"

module PathFinder
  path = ARGV[0]
  start_x = ARGV[1].to_i
  start_y = ARGV[2].to_i
  goal_x = ARGV[3].to_i
  goal_y = ARGV[4].to_i
  one_frame = if ARGV[3]?
                ARGV[3] == "true"
              else
                false
              end

  start = Point.new(start_x, start_y)
  goal = Point.new(goal_x, goal_y)
  game = Game.new path, start, goal, one_frame
  game.run
end
