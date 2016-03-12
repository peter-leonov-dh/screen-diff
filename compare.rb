#!/usr/bin/env ruby

# raise 'three args needed: a b diff' unless ARGV.length == 3

def main
  system('convert a.png -compress none a.pgm')
  system('convert b.png -compress none b.pgm')
  system('diff -U10000 --minimal a.pgm b.pgm > diff.pgm')

  diff = File.readlines('diff.pgm')
  raise 'empty diff' if diff.empty?

  head = diff.shift(3)
  raise 'wrong diff header' unless head[0]['---'] && head[1]['+++'] && head[2]['@@']
  raise 'wrong format' unless diff.shift['P2']

  size_a = diff.shift
  raise 'TODO: do nothing for same size images' if size_a[0] == ' '
  size_b = diff.shift
  raise 'wrong sizes diff' unless size_a[0] == '-' && size_b[0] == '+'
  size_rex = /.(\d+) (\d+)/
  width_a = size_rex.match(size_a)[1].to_i
  width_b = size_rex.match(size_b)[1].to_i
  raise "different widths: #{width_a} and #{width_b}" if width_a != width_b
  width = width_a

  colors = diff.shift

  a, b = parse(width, diff)

  write 'da.pgm', width, colors, a
  write 'db.pgm', width, colors, b

  system('convert da.pgm da.png')
  system('convert db.pgm db.png')
end


def parse width, diff
  spacer = '255 ' * width + "\n"
  a = []
  b = []
  
  loop do
    line = diff.shift or break
    if line[0] == ' '
      a << line[1..-1]
      b << line[1..-1]
    elsif line[0] == '-'
      
    elsif line[0] == '+'
      a << spacer
      b << line[1..-1]
    end
  end
  
  return a, b
end

def write name, width, colors, lines
  File.open(name, 'w') do |f|
    f.puts 'P2'
    f.puts "#{width} #{lines.size}"
    f.print colors
    lines.each { |line| f.print line }
  end
end

main

# compare a.png b.png png:- | montage -geometry +4+0 a.png - b.png diff.png