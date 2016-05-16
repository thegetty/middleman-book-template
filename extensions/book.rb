require_relative "book/helpers.rb"
require_relative "book/book_chapter.rb"
require_relative "book/epub.rb"

module Book
  class BookExtension < Middleman::Extension
    self.defined_helpers = [Book::Helpers]

    option :ebook_cover, false, "Name of an optional cover image"
    option :output_filename, "book", "Filename of resulting .pdf, .epub, etc"
    option :output_dir, "dist", "Directory to output PDF and EPUB files"
    option :pdf_output_path, "dist/book.pdf", "Where to write generated PDF"
    option :epub_output_path, "dist/epub/", "Where to write generated EPUB files"
    option :prince_cli_flags, "--no-artificial-fonts", "Flags for Prince cli"

    expose_to_template :chapters, :title, :author
    expose_to_application :chapters

    attr_reader :chapters, :title, :author, :info, :cover
    attr_accessor :manifest, :navmap

    def initialize(app, options_hash = {}, &block)
      super
      @info     = @app.data.book
      @title    = info.title.main
      @author   = info.author_as_it_appears
      @cover    = options.ebook_cover
      @chapters = []
      @manifest = []
      @navmap   = []

      app.after_build do |builder|
        book = app.extensions[:book]
        book.generate_pdf! if environment? :pdf
        book.generate_epub! if environment? :epub
      end
    end

    def manipulate_resource_list(resources)
      generate_chapters!(resources)
      resources
    end

    def generate_epub!
      epub_file   = File.join(options.output_dir, "#{options.output_filename}.epub")
      working_dir = File.join(options.output_dir, "epub")

      FileUtils.rm(epub_file) if File.exist?(epub_file)
      epub = Epub.new(self, chapters, working_dir)
      epub.build(app.sitemap)

      puts `epzip #{working_dir} #{epub_file}`
    end

    def generate_pdf!
      pdf_file = "#{options.output_dir}/#{options.output_filename}.pdf"
      pagelist = generate_pagelist
      flags    = options.prince_cli_flags

      puts `prince #{pagelist} -o #{pdf_file} #{flags}`
    end

    private

    def generate_pagelist
      arg_string  = ""
      baseurl     = @app.config.build_dir + "/"
      chapters.each { |c| arg_string += baseurl + c.destination_path + " " }
      arg_string
    end

    def generate_chapters!(resources)
      resources.find_all { |p| p.data.sort_order }.each do |p|
        source, path, metadata = p.source_file, p.destination_path, p.metadata
        chapter = Book::Chapter.new(@app.sitemap, path, source, self)
        chapter.add_metadata(metadata)
        resources.delete p
        resources.push chapter
        @chapters.push chapter
      end

      # Keep chapters from duplicating themselves endlessly on each livereload
      @chapters.uniq! { |p| p.data.sort_order }
      @chapters.sort_by! { |p| p.data.sort_order }
    end
  end

  ::Middleman::Extensions.register(:book, BookExtension)
end
