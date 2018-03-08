#!/usr/bin/env ruby
require 'rmagick'
require 'optparse'

# Parse options from command line
options = {}
OptionParser.new do |opt|
  opt.banner = "Usage: pdf.rb [options]"
  opt.on('--input Initial_PDF') { |o| options[:input] = o }
  opt.on('--output Final_PDF') { |o| options[:output] = o }
end.parse!
options[:output].slice! ".pdf"

# convert PDF to JPG images
system( "pdftoppm #{options[:input]} #{options[:output]} -jpeg -gray -r 300 " )

quality = 100
loop do 
  
  images = Dir["#{options[:output]}-*.jpg"].sort
  image_list = Magick::ImageList.new(*images) 
  
  # Get the size of all the files combined 
  size = 0
  images.each do |page|
    size = size + File.size(page).to_f / 1000000
  end
  
  break if size < 3
    
  # if the size is bigger than 3MB, then first compress them by
  # saving them as JPG again with lower quality
  quality = quality > 10 ? quality - 10 : 10
  image_list.each_with_index do |page, i|
    page.write("#{options[:output]}-#{i + 1}.jpg") { self.quality = quality }
  end
    
end

# write the final PDF
images = Dir["#{options[:output]}-*.jpg"].sort
image_list = Magick::ImageList.new(*images) 
image_list.write("#{options[:output]}.pdf")

# delete the temporary images
images.each do |png|
  File.delete(png)
end
