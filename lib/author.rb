class Author < Airrecord::Table
  self.base_key = ENV['AIRTABLE_BASE_KEY']
  self.table_name = 'Authors'

  def self.create_from_goodreads(author)
    create('Name' => author.name, 'Goodreads URL' => author.link)
  end
end
