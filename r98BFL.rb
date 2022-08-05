require 'gtk3'
require 'numo/narray'

def pal98togpal(pal98)
#  p pal98
  for colnum in 0..15 do
    cn3 = colnum * 3
    @gpal[colnum, 0] = pal98.byteslice(cn3).ord << 4 | pal98.byteslice(cn3).ord
    @gpal[colnum, 1] = pal98.byteslice(cn3 + 1).ord << 4 | pal98.byteslice(cn3 + 1).ord
    @gpal[colnum, 2] = pal98.byteslice(cn3 + 2).ord << 4 | pal98.byteslice(cn3 + 2).ord
  end
end

def betaopen(filename, ext1, ext2)
  begin
    File.open(filename + "." + ext1, "rb")
  rescue
    File.open(filename + "." + ext2, "rb")
  end
end


#p ARGV

base = File.basename(ARGV[0], ".*")
dir = File.dirname(ARGV[0])
filename = dir + "/" + base

@gpal = Numo::UInt8.zeros(16, 3)
begin
  file = File.open(filename + ".rgb", "rb")
rescue
  file = File.open(filename + ".RGB", "rb")
end
pal98togpal(file.read)

r1 = betaopen(filename, "r1", "R1")
g1 = betaopen(filename, "g1", "G1")
b1 = betaopen(filename, "b1", "B1")
e1 = betaopen(filename, "e1", "E1")

data = Numo::UInt8.zeros(400, 640, 3)
data.reshape!(400 * 640, 3)
#p data

for i in 0..(32000 - 1) do
  rb = r1.readbyte
  gb = g1.readbyte
  bb = b1.readbyte
  eb = e1.readbyte
  7.downto(0) do |j|
    0.upto(2) do |k|
      data[i * 8 + 7 - j, k] = @gpal[eb[j] << 3 | gb[j] << 2 | rb[j] << 1 | bb[j], k]
    end
  end
end

window = Gtk::Window.new
window.set_size_request(650, 410)

image = Gtk::Image.new

pixbuf = GdkPixbuf::Pixbuf.new(data: data.to_string, width: 640,  height: 400, has_alpha: false)
image.pixbuf = pixbuf

fixed = Gtk::Fixed.new
fixed.put(image, 5, 5)
window.add(fixed)

window.show_all
window.signal_connect("destroy") { Gtk.main_quit }
Gtk.main
