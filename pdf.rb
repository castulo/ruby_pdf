#!/usr/bin/env ruby
require 'rmagick'
require 'optparse'

options = {}
OptionParser.new do |opt|
  opt.banner = "Usage: pdf.rb [options]"
  opt.on('--input Initial_PDF') { |o| options[:input] = o }
  opt.on('--output Final_PDF') { |o| options[:output] = o }
end.parse!

# read the pdf
initial_pdf = Magick::Image::read(options[:input]) { self.quality = 100 }

# convert all pages to 300 dpi in resolution and grayscale
pdf_pages = Array.new
index = 0
initial_pdf.each do |page|
  #page.density = '300'
  #page.trim!
  #page = page.sharpen(0, 3.0)
  #grey_page = page.quantize(number_colors=256, colorspace=Magick::GRAYColorspace)
  page = grey_page.write("#{index}.png") { self.quality = 100 }
  pdf_pages << "#{index}.png"
  index += 1
end

# write the final pdf
final_pdf = Magick::ImageList.new(*pdf_pages) { self.quality = 100 }
size_kb = final_pdf.filesize.to_f / 1000
puts "File size: #{size_kb} Kb"
final_pdf.write(options[:output]) { self.quality = 100 }

# delete the temporary files
#pdf_pages.each do |pdf|
#  File.delete(pdf)
#end
