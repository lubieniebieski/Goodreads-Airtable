# frozen_string_literal: true

require 'logger'
require 'goodreads'
require 'airrecord'
require_relative 'goodreads_client'
require_relative 'book'

class Importer
  USER_ID = ENV['USER_ID']
  READ = 'read'
  TO_READ = 'to-read'
  PER_PAGE = 50

  def self.import_from_goodreads
    existing_books = Book.all
    shelf_books = get_shelf_books(TO_READ)
    logger.info("Starting shelf: #{TO_READ}")
    import_from_shelf_books(shelf_books, existing_books)
    logger.info("Starting shelf: #{READ}")
    shelf_books = get_shelf_books(READ)
    import_from_shelf_books(shelf_books, existing_books, true)
  end

  def self.import_from_shelf_books(books, existing_books, mark_read = false)
    books_length = books.length
    books.each_with_index do |shelf_book, idx|
      book = shelf_book.book
      existing_book = find_existing_book(existing_books, book)
      personal_rating = shelf_book.rating.to_i
      logger.info("#{idx + 1}/#{books_length} - #{book.title}")
      if existing_book
        existing_book.create_from_goodreads(book, mark_read, personal_rating)
      else
        Book.new('Title' => book.title).create_from_goodreads(book, mark_read, personal_rating)
      end
    end
  end

  def self.find_existing_book(existing_books, book)
    existing_books.find { |other| other['Title'] == book.title_without_series }
  end

  def self.logger
    @logger ||= Logger.new($stdout)
  end

  def self.get_shelf_books(shelf_name)
    contents = []
    page = 1
    total = get_shelf_via_pagination(shelf_name, page).total
    while contents.size < total
      logger.info("Fetching page #{page}/#{(total / PER_PAGE).ceil + 1}")
      contents += get_shelf_via_pagination(shelf_name, page).books
      page += 1
    end
    contents.shuffle
  end

  def self.get_shelf_via_pagination(shelf_name, page)
    GoodreadsClient::Client.shelf(USER_ID, shelf_name, per_page: PER_PAGE, page: page)
  end
end

Airrecord.api_key = ENV['AIRTABLE_KEY']
Importer.import_from_goodreads
