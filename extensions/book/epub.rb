require "fileutils"
require "nokogiri"
require "haml"
require "time"

module Book
  class Epub
    attr_reader :book, :chapters, :template_path, :output_path, :metadata

    ItemTag = Struct.new :id, :href, :media_type, :properties do
      def initialize(*)
        super
        self.properties ||= nil
      end
    end

    NavPoint = Struct.new :id, :play_order, :src, :text

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
      copy_fonts
      build_container
      build_cover_page
      build_toc_nav
      build_chapters
      build_epub_css
      build_toc_ncx
      build_page_from_template("com.apple.ibooks.display-options.xml", "META-INF/")
      build_page_from_template("content.opf")
    end

    # Load a template from the book/templates directory
    # Returns a Haml::Engine object ready to render
    def load_template(file)
      path = "extensions/book/templates/" + file
      Haml::Engine.new(File.read(path), :format => :xhtml)
    end

    private

    def build_page_from_template(filename, dir = "OEBPS/")
      template = load_template("#{filename}.haml")
      Dir.chdir(output_path + dir ) do
        File.open(filename, "w") { |f| f.puts template.render(Object.new, :book => book) }
      end
    end

    def clean_directory(dirname)
      valid_start_chars = /[A-z]/
      valid_start_chars.freeze
      return false unless dirname.chr.match(valid_start_chars)
      FileUtils.rm_rf(dirname) if Dir.exist?(dirname)
      Dir.mkdir(dirname)
    end

    def build_epub_dir
      oebps_subdirs = %w(assets assets/images assets/stylesheets assets/fonts)
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
    # TODO: streamline this method, it's too complex
    def copy_images(sitemap)
      resources = sitemap.resources
      images = resources.select { |r| r.path.match("assets/images/*") }
      images.reject! { |r| r.path.to_s == "assets/images/.keep" }

      Dir.chdir(output_path + "OEBPS/assets/images") do
        images.each_with_index do |image, index|
          filename = image.file_descriptor.relative_path.basename
          item = ItemTag.new("img_#{index}",
                             image.file_descriptor.relative_path,
                             image.content_type)

          if image.file_descriptor.relative_path.basename.to_s == book.cover
            item.properties = "cover-image"
          end

          File.open(filename, "w") { |f| f.puts image.render }
          @book.manifest << item
        end
      end
    end

    def copy_fonts
      fonts = Dir.glob("extensions/book/fonts/*.otf")
      fonts.each do |font|
        path = Pathname.new(font)
        FileUtils.cp("#{path}", "#{output_path}/OEBPS/assets/fonts/#{path.basename}")
        @book.manifest << ItemTag.new("#{path.basename}", "assets/fonts/#{path.basename}", "application/x-font-otf" )
      end
    end

    # Various Build Methods
    # These methods write one or more files at a specific location

    def build_container
      template = load_template("container.xml.haml")
      Dir.chdir(output_path + "META-INF/") do
        File.open("container.xml", "w") { |f| f.puts template.render }
      end
    end

    def build_cover_page
      return false unless book.cover
      build_page_from_template("cover.xhtml")
      @book.manifest << ItemTag.new("coverpage", "cover.xhtml", "application/xhtml+xml")
      @book.navmap << NavPoint.new("coverpage", 0, "cover.xhtml", "Cover")
    end

    def build_chapters
      Dir.chdir(output_path + "OEBPS/") do
        chapters.each_with_index do |c, index|
          File.open("#{c.title.slugify}.xhtml", "w") { |f| f.puts c.format_for_epub }

          item     = c.generate_item_tag
          navpoint = c.generate_navpoint

          navpoint.play_order = index + 2 # start after cover, toc
          navpoint.id = "np_#{index}"

          @book.navmap << navpoint
          @book.manifest << item
        end
      end
    end

    def build_epub_css
      # TODO: Allow custom user css to be appended to this file
      template = File.read("extensions/book/templates/epub.css")
      Dir.chdir(output_path + "OEBPS/assets/stylesheets") do
        File.open("epub.css", "w") { |f| f.puts template }
      end
      @book.manifest << ItemTag.new("epub.css", "assets/stylesheets/epub.css", "text/css")
    end

    def build_toc_ncx
      build_page_from_template("toc.ncx")
      @book.manifest << ItemTag.new("toc.ncx", "toc.ncx", "application/x-dtbncx+xml")
    end

    def build_toc_nav
      build_page_from_template("toc.xhtml")
      @book.manifest << ItemTag.new("toc", "toc.xhtml", "application/xhtml+xml", "nav")
      @book.navmap << NavPoint.new("toc", 1, "toc.xhtml", "Contents")
    end
  end
end
