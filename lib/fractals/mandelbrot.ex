defmodule FractalExplorer.Fractal.Mandelbrot do
  use GenServer

  alias Scenic.Utilities.Texture
  alias Scenic.Cache.Dynamic.Texture, as: Cache
  import IEx

  # @max_iter   Bitwise.<<<(1, 16)
  @max_iter   Bitwise.<<<(1, 12)
  # @max_iter   1000
  # @max_iter   255
  @max_iter   10


  #============================================================================
  # external, client api

  #============================================================================
  # internal, server api

  def start_link( size ), do: GenServer.start_link(__MODULE__, size )
  def init( size ) do
    config = %{
      size: size,
      center: {0.0,0.0},
      resolution: 1
    }
    send(self(), :render)
    { :ok, config }
  end

  #--------------------------------------------------------
  # simple render on demand
  def handle_info( :render, config ) do
    generate( config )
    {:noreply, config}
  end

  #--------------------------------------------------------
  # render the fractal into a static set of pixels
  # you would replace this entire thing with something that just grabs the completed
  # image off the video card
  def generate( %{size: {w,h} = size, center: center, resolution: resolution} ) do
    # options are :g, :ga, :rgb, :rgba
    {:ok, pixels} = Texture.build( :g, w, h )
    pixels

    # iterate over each pixel and calculate it's value - this is slow
    pixels = Enum.reduce(0..(h - 1), pixels, fn(py, pixels) ->
      pixels = Enum.reduce(0..(w - 1), pixels, fn(px, pixels) ->
        Texture.put!( pixels, px, py,
          calculate_pixel( px, py, size, center, resolution )
        )
      end)
      # updating the cache every line to show some progress
      Cache.put( to_string(__MODULE__), pixels, :global )
      # IO.write(".")
      pixels
    end)
    # IO.puts("done")
  end

  #--------------------------------------------------------
  # px,py are the pixel coordinates.
  def calculate_pixel( px, py, {w,h}, {cx,cy}, resolution ) do

    x = (px / w) * resolution
    y = (py / h) * resolution

    # calculate the color from iterations
    k = iterate( x, y )

    # color depends on the number of iterations
    255 - trunc(k * 255.0 / @max_iter)
  end

  defp iterate( x, y ), do: do_iterate( x * 1.0, y * 1.0, 0.0, 0.0, 0 )
  defp do_iterate( _, _, _, _, @max_iter ), do: @max_iter
  defp do_iterate( x, y, u, v, count ) do
    u2 = u * u
    v2 = v * v
    if u2 + v2 > 4.0 do
      count
    else
      v = 2.0 * u * v + y
      u = (u*u) - (v*v) + x
      do_iterate( x, y, u, v, count + 1 )
    end
  end


end

















