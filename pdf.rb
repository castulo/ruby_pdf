#!/usr/bin/env ruby
require 'rmagick'
require 'optparse'

options = {}
OptionParser.new do |opt|
  opt.banner = "Usage: pdf.rb [options]"
  opt.on('--input Initial_PDF') { |o| options[:input] = o }
  opt.on('--output Final_PDF') { |o| options[:output] = o }
end.parse!

# convert PDF to JPG images
system( "pdftoppm #{options[:input]} #{options[:output]} -jpeg -gray -r 300 " )
images = Dir["#{options[:output]}-*.jpg"].sort

# Get the size of all the files combined 
size = 0
images.each do |page|
  size = size + File.size(page).to_f / 1000000
end

# if the size is no bigger than 3 MB then just write them to PDF
compression = Magick::JPEGCompression
image_list = Magick::ImageList.new(*images)
if size < 3 then

  image_list.write("#{options[:output]}.pdf")
  
# if the size is bigger then first compress them by saving them as JPG again
else
  
  image_list.each_with_index do |page, i|
    page.write("#{options[:output]}-#{i + 1}.jpg") { self.quality = 10 }
  end
  images = Dir["#{options[:output]}-*.jpg"].sort
  image_list = Magick::ImageList.new(*images)
  image_list.write("#{options[:output]}.pdf")

end 

# delete the temporary images
images.each do |png|
  File.delete(png)
end
