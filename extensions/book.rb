require_relative "book/helpers.rb"
require_relative "book/book_chapter.rb"

module Book
  class BookExtension < Middleman::Extension
    self.defined_helpers = [Book::Helpers]

    option :pdf_output_path, "dist/book.pdf", "Where to write generated PDF"
    option :prince_cli_flags, "--no-artificial-fonts", "Flags for Prince cli"

    expose_to_template :chapters, :title, :author
    expose_to_application :chapters

    attr_reader :chapters
    attr_reader :info

    def initialize(app, options_hash = {}, &block)
      super
      @info     = @app.data.book
      @chapters = []

      app.after_build do |builder|
        book = app.extensions[:book]
        book.generate_pdf if environment? :pdf
      end
    end

    def manipulate_resource_list(resources)
      generate_chapters!(resources)
      resources
    end

    def author
      info.author_as_it_appears
    end

    def title
      info.title.main
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
