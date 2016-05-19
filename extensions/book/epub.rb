require "fileutils"
require "nokogiri"
require "haml"
require "time"

require_relative "./template_utils.rb"
require_relative "./xml_structs.rb"

module Book
  class Epub
    include TemplateUtils
    include XMLStructs
    attr_reader :book, :chapters, :template_path, :working_dir, :metadata

    def initialize(book, chapters, working_dir)
      @book        = book
      @chapters    = chapters
      @working_dir = working_dir
    end

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
      build_page_from_template("com.apple.ibooks.display-options.xml", "META-INF")
      build_page_from_template("content.opf")
    end

    private

    def build_epub_dir
      clean_directory(working_dir)
      oebps_subdirs = %w(assets assets/images assets/stylesheets assets/fonts)
      Dir.chdir(working_dir) do
        FileUtils.rm_rf(".")
        ["META-INF", "OEBPS"].each { |dir| clean_directory(dir) }
        Dir.chdir("OEBPS") do
          oebps_subdirs.each { |dir| clean_directory(dir) }
        end
      end
    end

    def copy_images(sitemap)
      images = sitemap.resources.select { |r| r.path.match("assets/images/*") }
      images.reject! { |r| r.path.to_s == "assets/images/.keep" }

      Dir.chdir(working_dir + "/OEBPS/assets/images") do
        images.each_with_index do |image, index|
          add_image_to_manifest(image, index)
          filename = image.file_descriptor.relative_path.basename
          File.open(filename, "w") { |f| f.puts image.render }
        end
      end
    end

    def add_image_to_manifest(image, index)
      relative_path = image.file_descriptor.relative_path
      item = ItemTag.new("img_#{index}", relative_path, image.content_type)
      item.properties = "cover-image" if relative_path.basename.to_s == book.cover
      @book.manifest << item
    end

    def copy_fonts
      fonts = Dir.glob("extensions/book/fonts/*.otf")
      fonts.each do |font|
        path = Pathname.new(font)
        FileUtils.cp(path.to_s, "#{working_dir}/OEBPS/assets/fonts/#{path.basename}")
        @book.manifest << ItemTag.new(path.basename.to_s, "assets/fonts/#{path.basename}", "application/x-font-otf" )
      end
    end

    def build_container
      template = load_template("container.xml.haml")
      Dir.chdir(File.join(working_dir, "META-INF")) do
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
      Dir.chdir(File.join(working_dir, "OEBPS")) do
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
      Dir.chdir(File.join(working_dir, "/OEBPS/assets/stylesheets")) do
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
