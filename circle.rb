GTK.reset
=begin
The myth of dragonruby circle primitives brought to life.

main attractions:
- `rx` & `ry` radius properties which are aliases to
  `w / 2` & `h / 2` respectively
- `:circle` 1280x1280 sprite availabe (after at least 1 Circle instance
  is created) that can be used like the default `:pixel`. sure, it's
  a little rough around the edges (literally), but it only has like 720 edges
  to work with and also now you don't need to have an unnecessary
  10kb circle.png (smallest i could make a 1280x1280 circle.png file)
  to the project so cut it some slack ¯\_(ツ)_/¯
- sprites are cut into shape like with triangle primitives,
  except the ellipses don't require extra properties to be initialized
  beyond what rects need to initialize before they work properly
- (WIP) GTK::Geometry methods work with circles
=end

class Circle
  attr_sprite
  @@circle_rt_exists = false
  @@instances = 0

  def self.instances() = @@instances

  def initialize **args
    @@instances += 1

    # generic white circle rt that can be used as is like `:pixel`, or
    # used for blendmoding (samples/07_advanced_rendering/13_lighting)
    unless @@circle_rt_exists
      @@circle_rt_exists = true
      circle = $args.outputs[:circle]
      circle.w = 1280
      circle.h = 1280
      # changing up to `1440.times` and `angle: i / 16` smooths it out
      # any more seems negligible
      circle.sprites << 360.times.map do |i|
        {
          x: 187,
          y: 187, # (1280 - sqrt(640**2 * 2)) / 2 (centers the rendered square)
          w: 905, # sqrt(640**2 * 2) (note to self: pythagorean)
          h: 905,
          path: :pixel,
          angle: i / 4,
        }
      end
    end # :circle rt creation
    
    # errors might start flying if these aren't set on init
    @x = @y = @w = @h = 0

    # `@path` is actually the render target and the actual sprite dir
    # is stored in @path_dir (assigned in `path=` method)
    @path = :"circle#{@@instances}"

    # `<<` implemented to handle edge cases & let the class have the ability
    # to gain new properties after instantiation
    self << args
  end

  def rx()    = @w / 2
  def ry()    = @h / 2
  def rx=(rx) = @w = rx * 2
  def ry=(ry) = @h = ry * 2

  # where the rendering magic happens
  # blend modes do the work of cutting out the corners
  def path=(path)
    # puts "path setter reached"
    output = $args.outputs[@path]
    output.w = @w
    output.h = @h
    output.sprites.clear # not sure if this is necessary
    output.sprites << [{
                        x: 0,
                        y: 0,
                        w: @w,
                        h: @h,
                        path: :circle,
                      }, {
                        x: 0,
                        y: 0,
                        w: @w,
                        h: @h,
                        path: path,
                        blendmode_enum: 4,
                      }]
    @path_dir = path
  end

  # make the class quack the sprite path instead of the render target
  # for some reason though, using the circle in `outputs.sprites` uses
  # uses the actual `@path` value instead of this method... dr voodoo
  def path
    # puts "path getter reached"
    @path_dir
  end

  # simulate dynamic property creation like with hashes
  # `self.class.send` overwrites the `path` & `path=` methods so skip it
  # same goes for [rx, ry, rx=, ry=]
  # since doing `foo.<new property> = bar` on the class throws an error,
  # this gives the class the ability to have new properties without error
  # by doing `foo << { <new property>: bar }` instead
  def << args
    args.each do |k, v|
      case k
      when :path, :path=
        self.path = v
        next
      when :rx, :rx=
        self.rx = v
        next
      when :ry, :ry=
        self.ry = v
        next
      end
      self.class.send :attr_accessor, k.to_sym
      instance_variable_set :"@#{k}", v
    end
  end
end # Circle

class Hash
  def to_circle() = Circle.new(**self)
end

# TODO: literally all other methods
# https://github.com/DragonRuby/dragonruby-game-toolkit-contrib/blob/main/dragon/geometry.rb
module GTK
  module Geometry

    # TODO: tolerance, anchor_x|y, ellipses with different radii on each axis
    # `intersect_rect?` code is undocumented so I'm just guessing how it works
    # based on `inside_rect?` (documented in the docs but not the github repo)
    def intersect_rect? outer, tolerance = 0.1
      Geometry.intersect_rect? self, outer, tolerance
    end

    def self.intersect_rect? rect_1, rect_2, tolerance = 0.1
      return nil unless rect_1 && rect_2

      if rect_1.is_a?(Circle) && rect_2.is_a?(Circle)
        return false
      elsif rect_1.is_a?(Circle)
        return false
      elsif rect_2.is_a?(Circle)
        return false
      else
        super
      end
    end
  end # Geometry
end # GTK
