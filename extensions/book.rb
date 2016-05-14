require_relative "book/helpers.rb"
require_relative "book/book_chapter.rb"
require_relative "book/epub.rb"
require "time"

module Book
  class BookExtension < Middleman::Extension
    self.defined_helpers = [Book::Helpers]

    option :cover, false, "Name of an optional cover image"
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
      @cover    = options.cover
      @chapters = []
      @manifest = []
      @navmap   = []

      app.after_build do |builder|
        book = app.extensions[:book]
        book.generate_pdf if environment? :pdf
        book.generate_epub if environment? :epub
      end
    end

    def manipulate_resource_list(resources)
      generate_chapters!(resources)
      resources
    end

    def generate_epub
      # TODO: get rid of hard-coded file names, control via options
      FileUtils.rm("dist/book.epub") if File.exist?("dist/book.epub")
      epub = Epub.new(self, chapters, options.epub_output_path)
      epub.build(app.sitemap)
      puts `epzip #{options.epub_output_path} dist/book.epub`
    end

    def generate_pdf
      pagelist = generate_pagelist
      output   = options.pdf_output_path
      flags    = options.prince_cli_flags
      puts `prince #{pagelist} -o #{output} #{flags}`
    end

    def generate_pagelist
      arg_string  = ""
      baseurl     = @app.config.build_dir + "/"
      chapters.each { |c| arg_string += baseurl + c.destination_path + " " }
      arg_string
    end

    private

    def generate_chapters!(resources)
      contents = resources.find_all { |p| p.data.sort_order }
      contents.sort_by { |p| p.data.sort_order }
      contents.each do |p|
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
