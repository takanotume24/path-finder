require "./path_finder.cr"

module ForestFire
  start_x = ARGV[0].to_i
  start_y = ARGV[1].to_i
  goal_x = ARGV[2].to_i
  goal_y = ARGV[3].to_i
  one_frame = if ARGV[3]?
                ARGV[3] == "true"
              else
                false
              end

  start = Point.new(start_x, start_y)
  goal = Point.new(goal_x, goal_y)
  game = Game.new "test.csv", start, goal, one_frame
  game.run
end
