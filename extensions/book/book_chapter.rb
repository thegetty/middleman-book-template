module Book
  class Chapter < Middleman::Sitemap::Resource
    attr_reader :book, :title, :author, :rank

    # Pass in a reference to the parent Book extension for later use
    def initialize(store, path, source, book)
      super(store, path, source)
      @book   = book
      @title  = data.title
      @author = data.author || @book.author
      @rank   = data.sort_order
    end

    def body
      render layout: false
    end

    def next_chapter
      @book.chapters.select { |p| p.rank > rank }.min_by(&:rank)
    end

    def prev_chapter
      @book.chapters.select { |p| p.rank < rank }.max_by(&:rank)
    end

    def format_for_epub
      doc = Nokogiri::XML((render :layout => "epub_chapter"))

      # change absolute image src locations to relative
      images = doc.css("img")
      images.each do |image|
        image["src"] = image["src"][1..-1] if image["src"].start_with? "/"
      end

      doc.to_xml
    end
  end
end
