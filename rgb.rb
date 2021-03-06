#!/usr/bin/env ruby
require 'rmagick'

def img_to_rgb file_src, io_dst
  img = Magick::Image.read(file_src).first
  w = img.columns
  h = img.rows
  io_dst.puts "RGB"
  io_dst.puts "#{w} #{h}"
  h.times do |y|
    # x, y, columns, rows -> array
    io_dst.puts img.export_pixels(0, y, w, 1, 'RGB').join(' ')
  end
end

def rgb_to_img io_src, file_dst
  format = io_src.readline.chomp
  raise 'wrong format' unless format == 'RGB'
  _, w, h = /^(\d+) (\d+)/.match(io_src.readline).to_a
  raise 'wrong format' unless w && h
  w = w.to_i
  h = h.to_i

  img = Magick::Image.new(w, h)

  h.times do |y|
    pixels = io_src.readline.split(' ').map(&:to_i)
    # x, y, columns, rows, format, array
    img.import_pixels(0, y, w, 1, 'RGB', pixels)
  end

  img.write(file_dst)
end


# CLI

case ARGV.shift
when 'img-to-rgb'
  raise 'rgb img-to-rgb: two args needed: src.img dst.rgb' unless ARGV.length == 2
  img_to_rgb ARGV[0], ARGV[1] == '-' ? STDOUT : File.open(ARGV[1], 'w')
when 'rgb-to-img'
  raise 'rgb rgb-to-img: two args needed: src.rgb dst.img' unless ARGV.length == 2
  rgb_to_img ARGV[0] == '-' ? STDIN : File.open(ARGV[0], 'r'), ARGV[1]
else
  raise 'usage: rgb dump source.img - | process | rgb load - dest.img'
end
