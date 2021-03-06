require 'digest/sha1'

class Inkan
  attr_accessor :credit, :comment, :comment_suffix
  
  def self.legitimate?(file)
    File.open(file) do |file|
      file_content = file.read
      seal, content = if file_content[/\A#!/]
        hashbang, seal, remaining_content = file_content.split("\n", 3)
        [seal, "#{hashbang}\n#{remaining_content}"]
      else
        file_content.split("\n", 2)
      end

      !seal[/\s#{sha(content || '')}\s*$/].nil?
    end
  end
  
  def self.seal(file)
    new(file).tap {|inkan| yield inkan }.seal
  end
  
  def self.render
    new(nil).tap {|inkan| yield inkan }.render
  end
  
  def self.sha(content)
    Digest::SHA1.hexdigest(content)
  end
  
  def initialize(file)
    @file = file
    
    # Set Defaults
    @credit         = 'Generated by Inkan'
    @comment        = '#'
    @comment_suffix = ''
  end
  
  def print(string)
    file_content << string
  end
  
  def puts(string)
    file_content << string << "\n"
  end
  
  def seal
    File.open(@file, 'w') do |f|
      f.print render
    end
  end
  
  def render
    if file_content[/\A#!/]
      hashbang, remaining_content = file_content.split("\n", 2)
      "#{hashbang}\n#{render_seal}\n#{remaining_content}"
    else
      "#{render_seal}\n#{file_content}"
    end
  end
  
  private
  
  def render_seal
    "#{comment} #{credit}. #{sha} #{comment_suffix}"
  end
  
  def sha
    self.class.sha(file_content)
  end
  
  def file_content
    @file_content ||= ''
  end
end
