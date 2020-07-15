require "./game_of_life.cr"
module GameOfLife
    game = Game.new 30,30
    game.run
end