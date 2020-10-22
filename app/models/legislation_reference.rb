##
# Detect legislation references in a string value.
#
# Example:
#
# LegislationReference.match('Section 12(1)') => [
#   #<LegislationReference @type="Section", @items=["12", "1"]>
# ]
#
class LegislationReference
  TYPE = /([a-z]+)/i
  ELEMENT = /([a-z0-9]+)/i
  BRACKETED_ELEMENT = /\(#{ELEMENT}\)/
  DECIMAL_ELEMENT = /\.#{ELEMENT}/
  SUB_ELEMENTS = /#{BRACKETED_ELEMENT}|#{DECIMAL_ELEMENT}/
  ALL_ELEMENTS = /#{ELEMENT}|#{SUB_ELEMENTS}/

  SPACE_OR_DOT = /\s*|\.\s*/
  AND_SEPARATOR = /&(?:amp;)?/
  OR_SEPARATOR = /,\s*|\s*or\s*/i

  REGEXP = /
    #{TYPE}
    #{SPACE_OR_DOT}?
    (
      (?:
        #{ELEMENT}
        (?:
          \s*
          (?:#{SUB_ELEMENTS})+
          (?:#{AND_SEPARATOR}#{ALL_ELEMENTS})*
        )?
        #{OR_SEPARATOR}?
      )+
    )
  /x

  def self.match(text)
    matches = text.scan(REGEXP).map(&method(:parse_type_and_matches))
    matches.flatten.reject(&:blank?).uniq(&:to_s)
  end

  def self.parse_type_and_matches(capture)
    type = parse_type(capture[0])
    return unless type

    matches = parse_matches(capture[1])

    matches.inject([]) do |references, ref|
      elements = ref.split('.').map(&:strip)

      if elements.first.blank? && references.last
        elements = references.last.elements[0...-1] + elements[1..-1]
      end

      references << new(type: type, elements: elements)
      references
    end
  end
  private_class_method :parse_type_and_matches

  def self.parse_matches(string)
    string.
      # convert:
      # 1. &amps; into &
      # 2. subordinate elements into decimal to distinguish from the main
      #    element
      gsub(/#{AND_SEPARATOR}\.?/, '&.').
      # convert bracketed elements into decimal elements
      gsub(/\.?#{BRACKETED_ELEMENT}/, '.\1').
      # split at separators into an array
      split(/#{AND_SEPARATOR}|#{OR_SEPARATOR}/)
  end
  private_class_method :parse_matches

  def self.parse_type(type)
    case type.downcase
    when 's', 'section'
      'Section'
    when 'art', 'article'
      'Article'
    when 'para', 'paragraph'
      'Paragraph'
    when 'reg', 'regulation'
      'Regulation'
    end
  end
  private_class_method :parse_type

  attr_reader :type, :elements

  def initialize(type:, elements:)
    @type = type
    @elements = elements
  end

  ##
  # Return the reference in decimal form
  #
  def to_s
    base = "#{type} #{main_element}"
    return base if sub_elements.empty?
    base + "(#{sub_elements.join(')(')})"
  end

  private

  def main_element
    elements[0]
  end

  def sub_elements
    elements[1..-1]
  end
end
