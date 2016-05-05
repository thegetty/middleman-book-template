module Book
  module Helpers
    # Determine if current page is a chapter (i.e. a Sitemap::resource w/sort_order)
    # By default it checks the value of current_page; can accept any resource object as well
    # @return [Boolean]
    # def page_is_chapter?
    #   return false unless current_page.data.sort_order
    #   true
    # end

    # Determine if there is a chapter before the current page
    # @return Middleman::Sitemap::Resource of the previous page
    def prev_chapter_path
      return false unless current_page.respond_to?(:prev_chapter)
      current_page.prev_chapter
    end

    # Determine if there is a chapter after the current page
    # @return Middleman::Sitemap::Resource of the next page
    def next_chapter_path
      return false unless current_page.respond_to?(:next_chapter)
      current_page.next_chapter
    end
  end
end
