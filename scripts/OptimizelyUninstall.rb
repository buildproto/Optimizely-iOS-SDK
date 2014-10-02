script_name = File.basename(__FILE__)

begin
    require 'nokogiri'
rescue LoadError
    abort "You don't have nokogiri gem installed\n
            run 'gem install nokogiri' to install nokogiri"
end

def test_file_read_write(file_path)
    contents = File.read(file_path)
    doc = Nokogiri.XML(contents)
    File.open(file_path, 'w') { |file| file.write(doc) }
end

def old_format(file_path)
    contents = File.read(file_path)
    doc = Nokogiri.XML(contents)
    count = 0
    doc.xpath('//array//object//string[text()="optimizelyId"]').each do |node|
        node.parent().remove()
        count = count + 1
    end
    File.open(file_path, 'w') { |file| file.write(doc) }
    return count
end

def new_format(file_path)
    contents = File.read(file_path)
    doc = Nokogiri.XML(contents)
    count = 0
    doc.xpath('//userDefinedRuntimeAttribute[@keyPath="optimizelyId"]').each do | node |
        node.remove()
        count = count + 1
    end
    File.open(file_path, 'w') { |file| file.write(doc) }
    return count
end

def remove_optimizely(file_path)
    if not File.file?(file_path)
        abort "#{file_path} doesn't exists. Aborting..."
    end

    accepted_formats = [".xib", ".storyboard"]
    if not accepted_formats.include?(File.extname(file_path))
        abort "#{file_path} is not a xib or storyboard file. Aborting..."
    end

    begin
        test_file_read_write(file_path)
    rescue
        abort "#{script_name} cannot read/write #{file_path}. Aborting..."
    end

    count = old_format(file_path)
    count = count + new_format(file_path)
    print "#{count} optimizelyId removed from #{file_path}"
end

usage_string = "Usage: ruby #{script_name} <xib/storyboard filepath> \n"

if ARGV.length != 1
    print usage_string
    abort "Error: Xib or Storyboard file path is required. Aborting...\n\n"
end

remove_optimizely(ARGV[0])
