class StoredFile < ActiveRecord::Base
  mount_uploader :file, ArtifactFileUploader
  belongs_to :artifact

  before_save :generate_file_list
  before_save :save_file_format

  def save_file_format
    if file_changed?
      self.format = file.file.try(:extension)
    end
    true
  end

  # How to get file list of all different types?
  def generate_file_list
    ext = ['zip', 'rar', '7z', 'lzma', 'tar.gz']

    if file_changed?
      self.compressed = ext.include?(file.file.try(:extension))
    end
    true
  end

end