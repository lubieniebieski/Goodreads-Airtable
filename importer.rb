# frozen_string_literal: true

require 'logger'
require 'goodreads'
require 'airrecord'
require_relative 'goodreads_client'
require_relative 'book'

class Importer
  USER_ID = ENV['USER_ID']
  READ    = 'read'
  TO_READ = 'to-read'

  def self.import_from_goodreads
    existing_books = Book.all
    shelf = get_shelf(TO_READ)
    logger.info("Starting shelf: #{TO_READ}")
    import_from_shelf(shelf, existing_books)
    logger.info("Starting shelf: #{READ}")
    shelf = get_shelf(READ)
    import_from_shelf(shelf, existing_books, true)
  end

  def self.import_from_shelf(shelf, existing_books, mark_read = false)
    books = shelf.books
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

  def self.get_shelf(shelf_name)
    GoodreadsClient::Client.shelf(USER_ID, shelf_name)
  end
end

Airrecord.api_key = ENV['AIRTABLE_KEY']
Importer.import_from_goodreads
