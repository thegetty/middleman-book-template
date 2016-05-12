require "fileutils"
require "nokogiri"
require "haml"
require "time"

module Book
  class Epub
    attr_reader :book, :chapters, :template_path, :output_path, :metadata

    # Pass in an array of chapter objects on initialization
    # Pass in a reference to the parent Book extension that created the epub object
    def initialize(book, chapters, output_path)
      @book        = book
      @chapters    = chapters
      @output_path = output_path
    end

    # Run this process to build the complete epub file
    def build(sitemap)
      build_epub_dir
      copy_images(sitemap)
      build_chapters
      build_opf
    end

    # Load a template from the book/templates directory
    # Returns a Haml::Engine object ready to render
    def load_template(file)
      path = "extensions/book/templates/" + file
      Haml::Engine.new(File.read(path), :format => :xhtml)
    end

    private

    def clean_directory(dirname)
      valid_start_chars = /[A-z]/
      valid_start_chars.freeze
      return false unless dirname.chr.match(valid_start_chars)
      FileUtils.rm_rf(dirname) if Dir.exist?(dirname)
      Dir.mkdir(dirname)
    end

    def build_epub_dir
      oebps_subdirs = %w(assets assets/images assets/stylesheets assets/fonts)
      # TODO: Make sure to deal with mimetype file here
      Dir.chdir(output_path) do
        FileUtils.rm_rf(".")
        ["META-INF", "OEBPS"].each { |dir| clean_directory(dir) }
        Dir.chdir("OEBPS") do
          oebps_subdirs.each { |dir| clean_directory(dir) }
        end
      end
    end

    # Copy image resources from the Middleman sitemap into the epub package
    # and add their information to the parent Book object's @manifest
    def copy_images(sitemap)
      resources = sitemap.resources
      images = resources.select { |r| r.path.match("assets/images/*") }
      images.reject! { |r| r.path.to_s == "assets/images/.keep" }

      Dir.chdir(output_path + "OEBPS/assets/images") do
        images.each_with_index do |image, index|
          item = { :href => image.file_descriptor.relative_path.basename,
                   :id => "img_#{index}",
                   :media_type => image.content_type }
          File.open(item[:href], "w") { |f| f.puts image.render }
          @book.manifest << item
        end
      end
    end

    def build_chapters
      Dir.chdir(output_path + "OEBPS/") do
        chapters.each do |c|
          File.open("#{c.title.slugify}.html", "w") { |f| f.puts c.format_for_epub }
        end
      end
    end

    def build_opf
      template = load_template("content.opf.haml")
      Dir.chdir(output_path + "OEBPS/") do
        File.open("content.opf", "w") { |f| f.puts template.render(Object.new, :book => book) }
      end
    end
  end
end
