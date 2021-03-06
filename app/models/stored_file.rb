require './lib/file_extractors/file_extractor'

class StoredFile < ActiveRecord::Base
  mount_uploader :file, ArtifactFileUploader
  belongs_to :artifact

  before_save :save_file_format
  after_save :enqueue_fetch_metadata

  serialize :file_list, Array

  def path
    file.try(:path)
  end

  def name
    file.file.try(:filename)
  end

  def increment_download_count
    increment!(:download_count)
    artifact.update_column(:download_count, artifact.download_count + 1)
  end

  def save_file_format
    if file_changed?
      self.format = file.file.try(:extension).try(:downcase)
      self.compressed = StoredFile.compressed_formats.include?(format.downcase)
    end
    true
  end

  def fetch_metadata_from_file
    xt = FileExtractor.get_extractor(self.file.path, self.format)

    if xt.present?
      attrs = {}
      # TODO: metadata for different files
      # attrs[:metadata] = xt.get_data

      # Getting file for kinds of files which are packages or compressed
      attrs[:file_list] = xt.file_list

      self.update_attributes attrs
    end
  end

  private

  def self.compressed_formats
    ['zip', 'rar', '7z', 'lzma', 'tar.gz']
  end

  def enqueue_fetch_metadata
    if self.file_changed?
      Resque.enqueue(FileExtractorWorker, self.id)
    end
  end

end