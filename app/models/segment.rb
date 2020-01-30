class Segment
  include ActiveModel::Model
  include ActiveModel::Attributes
  attribute :speaker_label, :string
  attribute :start_time, :float
  attribute :end_time, :float
  attribute :items

  class Item
    include ActiveModel::Model
    include ActiveModel::Attributes
    attribute :start_time, :float
    attribute :end_time, :float
    attribute :content, :string

    def as_json *args
      attributes.as_json(*args)
    end
  end

  def self.parse result
    segments = result&.dig("results", "speaker_labels", "segments")
    if segments
      items = (result&.dig("results", "items") || []).map do |i|
        Item.new(
          start_time: i["start_time"].to_f,
          end_time: i["end_time"].to_f,
          content: i.dig("alternatives", 0, "content")
        )
      end
      segments.map do |seg|
        speaker = (seg["speaker_label"].split('_').last.to_i + 'a'.ord).chr
        range = (seg["start_time"].to_f ... seg["end_time"].to_f)
        xs = items.filter { |i| range.include? i.start_time }
        if xs.present?
          Segment.new(
            speaker_label: speaker,
            start_time: range.first,
            end_time: range.last,
            items: xs
          )
        end
      end.compact
    else
      items = (result&.dig("results", "items") || []).map do |i|
        Item.new(
          start_time: i["start_time"].to_f,
          end_time: i["end_time"].to_f,
          content: i.dig("alternatives", 0, "content")
        )
      end
      if items.present?
        [Segment.new(
          speaker_label: 'a',
          start_time: items.first.start_time,
          end_time: items.last.start_time,
          items: items
        )]
      end.to_a
    end
  end

  def as_json *args
    attributes.as_json(*args)
  end
end
