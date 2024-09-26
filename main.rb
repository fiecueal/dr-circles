require "app/circle.rb"
# require "app/test.rb"

class Main
  attr_gtk

  def initialize args
    @args = args

    $circle  = Circle.new(x: 0,   y: 0,   w: 300, h: 300, path: "sprites/square/red.png")
    $square  =           {x: 640, y: 0,   w: 300, h: 300, path: "sprites/square/red.png"}
    $ellipse = Circle.new(x: 640, y: 600, w: 640, h: 120, path: "sprites/square/red.png")
  end


  def tick args
    @args = args

    $circle.angle  = Kernel.tick_count
    $square.angle  = Kernel.tick_count
    $ellipse.angle = Kernel.tick_count

    if    inputs.right then $circle.x += 5
    elsif inputs.left  then $circle.x -= 5
    elsif inputs.up    then $circle.y += 5
    elsif inputs.down  then $circle.y -= 5
    end

    # test `Geometry.` syntax & circle to rect
    if Geometry.intersect_rect? $circle, $square
      $circle.path = "sprites/square/blue.png"
      $square.path = "sprites/square/blue.png"
    # test `instance.` syntax & circle to circle(ellipse)
    elsif $circle.intersect_rect? $ellipse
      $circle.path  = "sprites/square/green.png"
      $ellipse.path = "sprites/square/green.png"
    else
      $circle.path  = "sprites/square/red.png"
      $square.path  = "sprites/square/red.png"
      $ellipse.path = "sprites/square/red.png"
    end

    outputs.sprites << [
                         $circle,
                         $square,
                         $ellipse,
                       ]
  end
end

def tick args
  args.state.main ||= Main.new args
  args.state.main.tick args
end

GTK.reset
