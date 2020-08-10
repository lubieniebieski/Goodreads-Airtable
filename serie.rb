class Serie < Airrecord::Table
  self.base_key = ENV['AIRTABLE_BASE_KEY']
  self.table_name = 'Series'

  # Create a Book record from a Goodreads API request
  def create_from_goodreads(series)
    self['Title'] = series.title
    self.save
  end
end
