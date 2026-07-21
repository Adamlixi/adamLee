# Backport the Jekyll 4.3+ fix for non-ASCII filenames.
#
# Jekyll 4.2.x's URL.unescape_path calls path.encode("utf-8") without
# first tagging the encoding, which raises
# Encoding::UndefinedConversionError when path has high bytes tagged
# as ASCII-8BIT. This fires for any static file whose name contains
# UTF-8 (e.g. images/截图2024-01-23.png), surfaced via Jekyll::Cleaner
# trying to compute the destination URL of every source file.
#
# Fix: force the encoding tag to UTF-8 before re-encoding. The bytes
# are already correct UTF-8 on disk; we just need to tell Ruby.

require "jekyll"

module Jekyll
  class URL
    def self.unescape_path(path)
      path = path.dup.force_encoding("UTF-8")
      return path unless path.include?("%")

      Addressable::URI.unencode(path)
    end
  end
end