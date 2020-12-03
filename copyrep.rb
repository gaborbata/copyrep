#!/usr/bin/env ruby

=begin
MIT License

Copyright (c) 2020 Gabor Bata

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
=end

require 'erb'

ENCODING = 'UTF-8'
UTF8_BOM = "\xEF\xBB\xBF"
INCLUDE_FILE_NAME = true
COPYRIGHT_TEMPLATE = File.read('copyright.erb', :encoding => ENCODING)
COPYRIGHT_PATTERN = "Copyright(.+?)All rights reserved"

CONFIG_BY_EXTENSION = {
  java: {
    enabled:     true,
    begin:       '/**',
    end:         '*/',
    line:        '',
    regexp:      /(\/\*(.+?)#{COPYRIGHT_PATTERN}(.+?)\*\/\s*?)(\S.*)/im,
    preprocess:  nil,
    postprocess: nil
  },
  js: {
    enabled:     true,
    begin:       '/*',
    end:         '*/',
    line:        '',
    regexp:      /(\/\*(.+?)#{COPYRIGHT_PATTERN}(.+?)\*\/\s*?)(\S.*)/im,
    preprocess:  nil,
    postprocess: nil
  },
  ts: {
    enabled:     true,
    begin:       '/*',
    end:         '*/',
    line:        '',
    regexp:      /(\/\*(.+?)#{COPYRIGHT_PATTERN}(.+?)\*\/\s*?)(\S.*)/im,
    preprocess:  nil,
    postprocess: nil
  },
  html: {
    enabled:     true,
    begin:       '<!--',
    end:         '-->',
    line:        '',
    regexp:      /(<!--(.+?)#{COPYRIGHT_PATTERN}(.+?)-->\s*?)(\S.*)/im,
    preprocess:  nil,
    postprocess: lambda do |contents|
      # HTML doctype should be in the first line of the file
      doctype_pattern = /^<!DOCTYPE html.*?>$/im
      match_data = contents.match(doctype_pattern)
      contents = match_data[0].strip + "\n" + contents.sub(match_data[0], '') if match_data
      return contents
    end
  },
  rb: {
    enabled:     false,
    begin:       '=begin',
    end:         '=end',
    line:        '',
    regexp:      /(=begin(.+?)#{COPYRIGHT_PATTERN}(.+?)=end\s*?)(\S.*)/im,
    preprocess:  nil,
    postprocess: nil
  },
  sh: {
    enabled:     true,
    begin:       '',
    end:         '',
    line:        '# ',
    regexp:      nil,
    preprocess:  lambda do |contents|
      buffer = ''
      contents.each_line do |line|
        if line.start_with?('#')
          buffer += line
        elsif !buffer.empty?
          buffer.match(/#{COPYRIGHT_PATTERN}/im) ? break : buffer = ''
        end
      end
      return contents.sub(buffer.strip, '')
    end,
    postprocess: lambda do |contents|
      # shebang should be in the first line of the file
      shebang_pattern = /#!\/.*bin.+sh/
      match_data = contents.match(shebang_pattern)
      contents = match_data[0].strip + "\n" + contents.sub(match_data[0], '') if match_data
      return contents.gsub(/\n{3,}/, "\n\n")
    end
  }
}

DIRECTORY_BLOCK_LIST = [
  'target', 'coverage', 'node_modules', 'bower_modules', 'reports', '3rdparty', 'oxygen-webhelp'
]

def replace_header(source_dir)
  source_dir = '.' if source_dir.nil? || source_dir.empty?
  raise "Not a directory: #{source_dir}" unless Dir.exist?(source_dir)
  CONFIG_BY_EXTENSION.each do |extension, config|
    next unless config[:enabled]
    header_template = ERB.new(COPYRIGHT_TEMPLATE.strip + "\n", nil, '-')
    counter = 0
    puts "Search #{extension} files in #{source_dir} directory..."
    Dir.glob("#{source_dir}/**/*.#{extension}").sort.each do |file|
      begin
        next if DIRECTORY_BLOCK_LIST.any? do |dir| file.split(File::SEPARATOR).include?(dir) end
        contents = File.read(file, :encoding => ENCODING).gsub("\r\n", "\n").gsub("\r", "\n").gsub(UTF8_BOM, '')
        next if contents.length == 0
        contents = config[:preprocess].call(contents) if config[:preprocess]
        match_data = config[:regexp] ? contents.match(config[:regexp]) : nil
        header = header_template.result_with_hash({ config: config, file_name: INCLUDE_FILE_NAME ? File.basename(file) : nil})
        contents = match_data ? contents.sub(match_data[1], header) : header.concat(contents)
        contents = config[:postprocess].call(contents) if config[:postprocess]
        File.write(file, contents, :encoding => ENCODING)
        counter += 1
      rescue => error
        puts "ERROR: Could not update #{file} due to: #{error}"
      end
    end
    puts "Processed #{counter} #{extension} files"
  end
end

if ARGV.length != 1
  puts 'Usage: copyrep <source_dir>'
  puts "\n(supported file types: #{CONFIG_BY_EXTENSION.keys.map { |ext| ext.to_s }.join(', ') })"
else
  replace_header(ARGV[0])
end
