class Author < Airrecord::Table
  self.base_key = ENV['AIRTABLE_BASE_KEY']
  self.table_name = 'Authors'

  def create_from_goodreads(author)
    self['Name'] = author.name
    save
  end
end
