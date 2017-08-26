require 'ruby_rhymes'
require 'gosu'


class Verse
  attr_accessor :lines, :rhymes, :words

  def initialize(lines)
    @lines = lines
    @rhymes = {}
    @rhymes_count = {}
    @lines.map! {|l| l.split.each {|x| x.gsub(/s/, "")}}
    @lines.each {|l| l.each{|w| add_rhyme(w.to_phrase.rhyme_key)}}
    @lines.map! do |l|
      l.map do |w|
        key = w.to_phrase.rhyme_key
        RhymeWord.new(w, key, (@rhymes_count[key] > 1 ? rhymes[key] : "ffffff"))
      end
    end
  end

  def add_rhyme(w)
    @rhymes[w] = rand_color if @rhymes[w].nil?
    @rhymes_count[w] = @rhymes_count[w].nil? ? 1 : @rhymes_count[w]+1
  end

  def rand_color
    "%06x" % (rand * 0xffffff)
  end
end

class Bar
  attr_accessor :words

  def initialize(words)
    @words = words
  end
end

class RhymeWord
  attr_accessor :word, :rhyme, :color

  def initialize(w, r, c)
    @word  = w
    @rhyme = r
    @color = convert_to_gosu_color(c)
  end

  def convert_to_gosu_color(c)
    c = Integer(c, 16)
    r = c >> 16
    g = c >> 8 & 0xFF
    b = c & 0xFF
    return Gosu::Color.argb(255,r,g,b)
  end
end

module ZOrder
  BACKGROUND, STARS, PLAYER, UI = *0..3
end

class Display < Gosu::Window
  def initialize(verse,size)
    super 640,480*2
    self.caption = "YOYOYO"
    @font = Gosu::Font.new(size)
    @verse = verse
  end

  def update()
  end

  def draw()
    indent = 20
    col = 1
    @verse.lines.each do |l|
      pad_hor = ((width-indent) - l.map {|w| @font.text_width(w.word)}.reduce(:+))/l.length
      l.each do |w|
        @font.draw(w.word, indent, col*@font.height, ZOrder::UI,
                   1.0,1.0, w.color)
        indent += @font.text_width(w.word)+pad_hor.abs
      end
      col += 1
      indent = 20
    end
  end
end

verse = Verse.new(File.read("ghost.txt").split("\n"))
game = Display.new(verse,20)
