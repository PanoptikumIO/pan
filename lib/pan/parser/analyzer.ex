defmodule Pan.Parser.Analyzer do
  alias Pan.Parser.Iterator
  alias Pan.Parser.Helpers
  defdelegate dm(left, right), to: Pan.Parser.Helpers, as: :deep_merge

#wrappers to dive into
  def call(map, "tag", [:rss,     _, value]), do: Iterator.parse(map, "tag", value)
  def call(map, "tag", [:channel, _, value]), do: Iterator.parse(map, "tag", value)


# simple tags to include in podcast
  def call(_, "tag", [:title,             _, [value]]), do: %{title: value}
  def call(_, "tag", [:"itunes:author",   _, []]), do: %{}
  def call(_, "tag", [:"itunes:author",   _, [value]]), do: %{author: value}
  def call(_, "tag", [:"itunes:summary",  _, []]),      do: %{}
  def call(_, "tag", [:"itunes:summary",  _, [value]]), do: %{summary: value}
  def call(_, "tag", [:link,              _, [value]]), do: %{website: value}
  def call(_, "tag", [:"itunes:explicit", _, [value]]), do: %{explicit: Helpers.boolify(value)}
  def call(_, "tag", [:lastBuildDate,     _, [value]]) do
    %{last_build_date: Helpers.to_ecto_datetime(value)}
  end


# image with fallback to itunes:image
  def call(map, "tag", [:image, _, value]), do: Iterator.parse(map, "image", value)
  def call(_, "image", [:title, _, [value]]), do: %{image_title: value}
  def call(_, "image", [:url,   _, [value]]), do: %{image_url: value}
  def call(map, "image", [:link,        _, _]), do: map
  def call(map, "image", [:description, _, _]), do: map
  def call(map, "image", [:width,       _, _]), do: map
  def call(map, "image", [:height,      _, _]), do: map

  def call(map, "tag", [:"itunes:image", attr, _]) do
    if map[:image_url], do: map,
                        else: %{image_url: attr[:href],
                                image_title: attr[:href]}
  end

  def call(map, "tag", [:"itunes:image", _, [value]]) do
    if map[:image_url], do: map,
                        else: %{image_url: value}
  end


# Description with fallback to itunes:subtitle
def call(_, "tag", [:description, _, []]), do: %{}
  def call(_, "tag", [:description, _, [value]]), do: %{description: value}

  def call(_, "tag", [:"itunes:subtitle", _, []]), do: %{}
  def call(map, "tag", [:"itunes:subtitle", _, [value]]) do
    if map[:description], do: %{},
                          else: %{description: value}
  end


# simple tags to include into nested structure
  def call(_, "tag", [:generator, _, [value]]), do: %{feed: %{ feed_generator: value}}


# the links are a mixture of the two above
  def call(_, "tag", [:"atom:link", attr, _]) do
    case attr[:rel] do
      "self"      -> %{feed: %{ self_link_title: attr[:title],
                            self_link_url: attr[:href]}}
      "next"      -> %{feed: %{ next_page_url: attr[:href]}}
      "prev"      -> %{feed: %{ prev_page_url: attr[:href]}}
      "previous"  -> %{feed: %{ prev_page_url: attr[:href]}}
      "first"     -> %{feed: %{ first_page_url: attr[:href]}}
      "last"      -> %{feed: %{ last_page_url: attr[:href]}}
      "hub"       -> %{feed: %{ hub_link_url: attr[:href]}}
      "search"    -> %{}
      "related"   -> %{}
      "alternate" ->
        uuid = String.to_atom(UUID.uuid1())
        alternate_feed_map = %{uuid => %{title: attr[:title], url: attr[:href]}}
        %{feed: %{alternate_feeds: alternate_feed_map}}
      "payment" -> %{payment_link_title: attr[:title],
                     payment_link_url: String.slice(attr[:href], 0, 255)}
    end
  end

  def call(_, "tag", [:"rawvoice:donate", attr, [value]]), do: %{payment_link_title: value,
                                                                 payment_link_url: attr[:href]}


  def call(_, "tag", [:"atom10:link", attr, _]) do
    case attr[:rel] do
      "self"  -> %{feed: %{ self_link_title: attr[:title],
                            self_link_url: attr[:href]}}
      "hub" -> %{}
    end
  end


# tags to ignore
  def call(map, "tag", [:"feedpress:locale", _, _]), do: map
  def call(map, "tag", [:"fyyd:verify", _, _]), do: map
  def call(map, "tag", [:"itunes:block", _, _]), do: map
  def call(map, "tag", [:"itunes:keywords", _, _]), do: map
  def call(map, "tag", [:"media:thumbnail", _, _]), do: map
  def call(map, "tag", [:"media:keywords", _, _]), do: map
  def call(map, "tag", [:"media:category", _, _]), do: map
  def call(map, "tag", [:category, _, _]), do: map
  def call(map, "tag", [:site, _, _]), do: map
  def call(map, "tag", [:docs, _, _]), do: map
  def call(map, "tag", [:"feedburner:info", _, _]), do: map
  def call(map, "tag", [:"media:credit", _, _]), do: map
  def call(map, "tag", [:"media:copyright", _, _]), do: map
  def call(map, "tag", [:"media:rating", _, _]), do: map
  def call(map, "tag", [:"media:description", _, _]), do: map
  def call(map, "tag", [:"copyright", _, _]), do: map
  def call(map, "tag", [:"feedburner:feedFlare", _, _]), do: map
  def call(map, "tag", [:"geo:lat", _, _]), do: map
  def call(map, "tag", [:"geo:long", _, _]), do: map
  def call(map, "tag", [:"creativeCommons:license", _, _]), do: map
  def call(map, "tag", [:"feedburner:emailServiceId", _, _]), do: map
  def call(map, "tag", [:"feedburner:feedburnerHostname", _, _]), do: map
  def call(map, "tag", [:managingEditor, _, _]), do: map
  def call(map, "tag", [:pubDate, _, _]), do: map
  def call(map, "tag", [:"sy:updatePeriod", _, _]), do: map
  def call(map, "tag", [:"sy:updateFrequency", _, _]), do: map
  def call(map, "tag", [:"wfw:commentRss", _, _]), do: map
  def call(map, "tag", [:"rawvoice:subscribe", _, _]), do: map
  def call(map, "tag", [:webMaster, _, _]), do: map
  def call(map, "tag", [:ttl, _, _]), do: map
  def call(map, "tag", [:"itunes:new-feed-url", _, _]), do: map
  def call(map, "tag", [:"googleplay:description", _, _]), do: map
  def call(map, "tag", [:"googleplay:email", _, _]), do: map
  def call(map, "tag", [:"googleplay:category", _, _]), do: map
  def call(map, "tag", [:"rawvoice:rating", _, _]), do: map
  def call(map, "tag", [:"rawvoice:location", _, _]), do: map
  def call(map, "tag", [:"rawvoice:frequency", _, _]), do: map
  def call(map, "tag", [:"ppg:seriesDetails", _, _]), do: map
  def call(map, "tag", [:"ppg:systemRef", _, _]), do: map
  def call(map, "tag", [:"ppg:network", _, _]), do: map
  def call(map, "tag", [:cloud, _, _]), do: map
  def call(map, "tag", [:"googleplay:image", _, _]), do: map
  def call(map, "tag", [:"googleplay:author", _, _]), do: map
  def call(map, "tag", [:"googleplay:explicit", _, _]), do: map
  def call(map, "tag", [:feed, _, _]), do: map
  def call(map, "tag", [:webmaster, _, _]), do: map
  def call(map, "tag", [:ilink, _, _]), do: map
  def call(map, "tag", [:ffmpeg, _, _]), do: map
  def call(map, "tag", [:domain, _, _]), do: map
  def call(map, "tag", [:lame, _, _]), do: map
  def call(map, "tag", [:broadcastlimit, _, _]), do: map
  def call(map, "tag", [:"itunes:link", _, _]), do: map
  def call(map, "tag", [:"channelExportDir", _, _]), do: map
  def call(map, "tag", [:"atom:id", _, _]), do: map
  def call(map, "tag", [:"openSearch:totalResults", _, _]), do: map
  def call(map, "tag", [:"openSearch:startIndex", _, _]), do: map
  def call(map, "tag", [:"openSearch:itemsPerPage", _, _]), do: map
  def call(map, "tag", [:"html", _, _]), do: map


  def call(_, "episode", [:"itunes:image", _, _]), do: %{}
  def call(_, "episode", [:"itunes:keywords", _, _]), do: %{}
  def call(_, "episode", [:"post-id", _, _]), do: %{}
  def call(_, "episode", [:author, _, _]), do: %{}
  def call(_, "episode", [:"itunes:explicit", _, _]), do: %{}
  def call(_, "episode", [:category, _, _]), do: %{}
  def call(_, "episode", [:"dc:creator", _, _]), do: %{}
  def call(_, "episode", [:comments, _, _]), do: %{}
  def call(_, "episode", [:"media:content", _, _]), do: %{}
  def call(_, "episode", [:"feedburner:origLink", _, _]), do: %{}
  def call(_, "episode", [:"feedburner:origEnclosureLink", _, _]), do: %{}
  def call(_, "episode", [:"wfw:commentRss", _, _]), do: %{}
  def call(_, "episode", [:"slash:comments", _, _]), do: %{}
  def call(_, "episode", [:"itunes:block", _, _]), do: %{}
  def call(_, "episode", [:"itunes:order", _, _]), do: %{}
  def call(_, "episode", [:"ppg:canonical", _, _]), do: %{}
  def call(_, "episode", [:"cba:productionDate", _, _]), do: %{}
  def call(_, "episode", [:"cba:broadcastDate", _, _]), do: %{}
  def call(_, "episode", [:"cba:containsCopyright", _, _]), do: %{}
  def call(_, "episode", [:"media:thumbnail", _, _]), do: %{}
  def call(_, "episode", [:"googleplay:description", _, _]), do: %{}
  def call(_, "episode", [:"googleplay:image", _, _]), do: %{}
  def call(_, "episode", [:"googleplay:explicit", _, _]), do: %{}
  def call(_, "episode", [:"googleplay:block", _, _]), do: %{}
  def call(_, "episode", [:image, _, _]), do: %{}
  def call(_, "episode", [:source, _, _]), do: %{}
  def call(_, "episode", [:"media:description", _, _]), do: %{}
  def call(_, "episode", [:programid, _, _]), do: %{}
  def call(_, "episode", [:poddid, _, _]), do: %{}
  def call(_, "episode", [:"dcterms:modified", _, _]), do: %{}
  def call(_, "episode", [:"dcterms:created", _, _]), do: %{}
  def call(_, "episode", [:toPubDate, _, _]), do: %{}
  def call(_, "episode", [:audioId, _, _]), do: %{}
  def call(_, "episode", [:"atom:updated", _, _]), do: %{}
  def call(_, "episode", [:"thr:total", _, _]), do: %{}
  def call(_, "episode", [:"ard:visibility", _, _]), do: %{}


# We expect several language tags
  def call(_, "tag", [:language, _, [value]]) do
    uuid = String.to_atom(UUID.uuid1())
    %{languages: %{uuid => %{shortcode: value}}}
  end


# We expect several contributors
  def call(map, "tag", [:"atom:contributor", _, value]) do
    Iterator.parse(map, "contributor", value, UUID.uuid1())
  end

  def call("contributor", [:"atom:name", _, [value]]), do: %{name: value}
  def call("contributor", [:"atom:uri",  _, [value]]), do: %{uri: value}


# We expect one owner
  def call(map, "tag", [:"itunes:owner", _, value]), do: Iterator.parse(map, "owner", value)
  def call(_, "owner", [:"itunes:name",   _, []]), do: %{}
  def call(_, "owner", [:"itunes:name",   _, [value]]), do: %{name: value}
  def call(_, "owner", [:"itunes:email",  _, []]), do: %{}
  def call(_, "owner", [:"itunes:email",  _, [value]]), do: %{email: value}


# Parsing categories infintely deep
  def call(_, "tag", [:"itunes:category", attr, []]) do
    {:ok, category} = Pan.Parser.Category.find_or_create(attr[:text], nil)
    %{categories: %{category.id => true}}
  end
  def call(_, "tag", [:"itunes:category", [], [value]]) do
    {:ok, category} = Pan.Parser.Category.find_or_create(value, nil)
    %{categories: %{category.id => true}}
  end
  def call(_, "tag", [:"itunes:category", attr, value]) do
    {:ok, category} = Pan.Parser.Category.find_or_create(attr[:text], nil)
    Iterator.parse(%{categories: %{category.id => true}}, "category", value, category.id)
  end

  def call("category", [:"itunes:category", attr, []], parent_id) do
    {:ok, category} = Pan.Parser.Category.find_or_create(attr[:text], parent_id)
    %{categories: %{category.id => true}}
  end

  def call("category", [:"itunes:category", attr, value], parent_id) do
    {:ok, category} = Pan.Parser.Category.find_or_create(attr[:text], parent_id)
    Iterator.parse(%{categories: %{category.id => true}}, "category", value, category.id)
  end


# Episodes
  def call(map, "tag", [:item, _, value]), do: Iterator.parse(map, "episode", value, UUID.uuid1())

  def call(_, "episode", [:title,             _, [value]]), do: %{title:       String.slice(value, 0, 255)}
  def call(_, "episode", [:link,              _, [value]]), do: %{link:        String.slice(value, 0, 255)}
  def call(_, "episode", [:guid,              _, [value]]), do: %{guid:        String.slice(value, 0, 255)}
  def call(_, "episode", [:guid,              _, _]), do: %{}
  def call(_, "episode", [:description,       _, []]), do: %{}
  def call(_, "episode", [:description,       _, [value]]), do: %{description: HtmlSanitizeEx2.basic_html_reduced(value)}
  def call(_, "episode", [:"content:encoded", _, []]), do: %{}
  def call(_, "episode", [:"content:encoded", _, [value]]), do: %{shownotes:   HtmlSanitizeEx2.basic_html_reduced(value)}
  def call(_, "episode", [:"itunes:summary",  _, []]), do: %{}
  def call(_, "episode", [:"itunes:summary",  _, [value]]), do: %{summary:     HtmlSanitizeEx2.basic_html_reduced(value)}
  def call(_, "episode", [:"itunes:subtitle", _, []]), do: %{}
  def call(_, "episode", [:"itunes:subtitle", _, [value]]), do: %{subtitle:    String.slice(value, 0, 255)}
  def call(_, "episode", [:"itunes:author",   _, []]), do: %{}
  def call(_, "episode", [:"itunes:author",   _, [value]]), do: %{author:      String.slice(value, 0, 255)}
  def call(_, "episode", [:"itunes:duration", _, []]), do: %{}
  def call(_, "episode", [:"itunes:duration", _, [value]]), do: %{duration:    value}

  def call(_, "episode", [:pubDate,           _, [value]]) do
    %{publishing_date: Helpers.to_ecto_datetime(value)}
  end

  def call(_, "episode", [:"atom:link", attr, _]) do
    case attr[:rel] do
      "http://podlove.org/deep-link" -> %{deep_link: String.slice(attr[:href], 0, 255)}
      "payment" ->                      %{payment_link_title: attr[:title],
                                          payment_link_url: String.slice(attr[:href], 0, 255)}
    end
  end


# Enclosures a.k.a. Audiofiles
  def call(_, "episode", [:enclosure, attr, _]) do
    enclosure_map = %{url: attr[:url], length: attr[:length], type: attr[:type], guid: attr[:"bitlove:guid"]}
    uuid = String.to_atom(UUID.uuid1())
    %{enclosures: %{uuid => enclosure_map}}
  end


# Chapters
  def call(_, "episode", [:"psc:chapters", _, value]) do
    Iterator.parse(%{}, "chapter", value)
  end

  def call("chapter", [:"psc:chapter", attr, _]) do
    chapter_uuid = String.to_atom(UUID.uuid1())
    %{chapter_uuid => %{start: attr[:start], title: String.slice(attr[:title], 0, 255)}}
  end


# Episode contributors
  def call(_, "episode", [:"atom:contributor", _, value]) do
    contributor_uuid = String.to_atom(UUID.uuid1())
    Iterator.parse(%{contributors: %{contributor_uuid => %{}}}, "episode-contributor", value, contributor_uuid)
  end

  def call("episode-contributor", [:"atom:name", _ , [value]]), do: %{name: value}
  def call("episode-contributor", [:"atom:uri",  _ , [value]]), do: %{uri: value}


# Show debugging information for unknown tags on console
  def call(_, mode, [tag, attr, value]) do
    IO.puts "\n\e[96m === Tag unknown: ==="
    IO.puts "Mode: " <> mode
    IO.puts "Tag: " <> to_string(tag)
    IO.puts "Attr: "
    IO.inspect attr
    IO.puts "Value: "
    IO.inspect value
    IO.puts " =================\e[0m"

    case mode do
      "episode" ->
        IO.puts ~s/def call(_, "episode", [:"/ <> to_string(tag) <> ~s/", _, _]), do: %{}/
      "tag" ->
        IO.puts ~s/def call(map, "tag", [:"/ <> to_string(tag) <> ~s/", _, _]), do: map/
    end
    raise "Tag unknown"
  end
end
