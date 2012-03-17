#!/usr/bin/env ruby -w

class HBEncoder
  def self.encode(path, type = 'mkv')
    (files = Dir[File.join(File.expand_path(path), "**", "*.mkv")].sort).each_with_index do |file, i|
      begin
        puts "hello"
        output_file = "#{File.join(File.dirname(file), File.basename(file, type))}m4v"
        puts "Skipping #{file} as destination exists" and next if File.exists?(output_file) 
        puts "Encoding file #{i + 1} or #{files.size}..."
        hb_cmd = "HandBrakeCLI -i '#{file}' -o '#{output_file}' --preset=\"High Profile\""
        puts "CMD: #{hb_cmd}"
        res = `#{hb_cmd} 2>/dev/null`
      rescue SignalException => e
        print "Cleaning up..."
        File.unlink(output_file)
        puts "...done"
        return -1
      end
    end
  end
end

raise "Usage: Encode <path>" unless ARGV.size == 1
path = ARGV.first
HBEncoder.encode(path)

