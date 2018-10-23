#!/usr/bin/env ruby

# The purpose of this script is to convert a PDF provided by a user
# so it has the following properties:
#  - 300 dpi of resolution
#  - file max size of 3Mb
#  - gray scale
#
# The script receives two arguments:
#  --input: this parameter is used to specify the initial PDF that we
# want to convert
#  --output: the file where the converted PDF will be saved

require 'rmagick'

# The script needs the two arguments above o work, and initially the script was
# intended to be used from the command line. But if the script is now to be
# used within a rails app, it does not need the optparse gem since rails can
# specify those arguments through a web page

require 'optparse'

# Parse options from command line
options = {}
OptionParser.new do |opt|
  opt.banner = "Usage: pdf.rb [options]"
  opt.on('--input Initial_PDF') { |o| options[:input] = o }
  opt.on('--output Final_PDF') { |o| options[:output] = o }
end.parse!
options[:output].slice! ".pdf"

# It is easier to manipulate properties of an image that of a PDF, PDFs are harder
# to manipulate, so we will convert the PDF to a sequence of JPG images here. For
# this we use the 'pdftoppm' program that is part of the poppler tools. This program
# will allow us to convert the initial PDF to a series of JPEG images with a resolution
# of 300 dpi and in scale of gray.
# Here are guides on how to install this tool:
#  - Install on ubuntu: https://gist.github.com/Dayjo/618794d4ff37bb82ddfb02c63b450a81
#  - Install on Mac: http://macappstore.org/poppler/
#
# pdftoppm does not have a ruby gem, so to be able to run it we use the "system" command
# which will run the program in the native OS.
system( "pdftoppm #{options[:input]} #{options[:output]} -jpeg -gray -r 300 " )

# At this point we should have the PDF converted as images in the location
# specified by the output variable, each page from the original PDF will be
# an image. So if we had for example one PDF with 3 pages we will now have:
# my_pdf-1.jpg, my_pdf-2.jpg and my_pdf-3.jpg

quality = 100
loop do 
  
  # add all images to a list
  images = Dir["#{options[:output]}-*.jpg"].sort
  image_list = Magick::ImageList.new(*images) 
  
  # Get the size of all the files combined, we will use this to make sure our
  # converted PDF does not exceed the 3 Mb of size once merged
  size = 0
  images.each do |page|
    size = size + File.size(page).to_f / 1000000
  end
  
  break if size < 3
    
  # if the size is bigger than 3MB, then first compress them by
  # saving them as JPG again with lower quality.
  # we start with a quality of 100% and start reducing the quality by 10%
  # each time until the file is smaller than 3 MB
  quality = quality > 10 ? quality - 10 : 10
  image_list.each_with_index do |page, i|
    page.write("#{options[:output]}-#{i + 1}.jpg") { self.quality = quality }
  end
    
end

# at this point we should have a list of images (one image per PDF page)
# and the sum of all those images should not be bigger than 3 Mb
# so we are ready to write the final PDF, we need to sort the list again
# so pages are in order and we use image magick to convert the list of images
# back to a PDF file
images = Dir["#{options[:output]}-*.jpg"].sort
image_list = Magick::ImageList.new(*images) 
image_list.write("#{options[:output]}.pdf")

# since we don't need the the temporary images used for the PDF transformation
# we can now remove all those images.
images.each do |png|
  File.delete(png)
end

# All this files can be generated and stored temporarily in the server running rails,
# and as soon as the user downloads the final PDF into its computer we can remove the
# PDFs from the server.

