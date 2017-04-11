defmodule Pan.Parser.Analyzer do
  alias Pan.Parser.Iterator
  alias Pan.Parser.Helpers
  require Logger

  defdelegate dm(left, right), to: Pan.Parser.Helpers, as: :deep_merge

#wrappers to dive into
  def call(map, "tag", [:rss,     _, value]), do: Iterator.parse(map, "tag", value)
  def call(map, "tag", [:channel, _, value]), do: Iterator.parse(map, "tag", value)


# simple tags to include in podcast
  def call(_, "tag", [:title,             _, []]), do: %{}
  def call(_, "tag", [:title,             _, [value]]), do: %{title: value}
  def call(_, "tag", [:"itunes:author",   _, []]), do: %{}
  def call(_, "tag", [:author,            _, [value]]), do: %{author: String.slice(value, 0, 255)}
  def call(_, "tag", [:"googleplay:author", _, [value]]), do: %{author: String.slice(value, 0, 255)}
  def call(_, "tag", [:"itunes:author",   _, [value]]), do: %{author: String.slice(value, 0, 255)}
  def call(_, "tag", [:"itunes:summary",  _, []]),      do: %{}
  def call(_, "tag", [:"itunes:summary",  _, [value | _]]), do: %{summary: value}
  def call(_, "tag", [:link,              _, []]), do: %{}
  def call(_, "tag", [:link,              _, [value]]), do: %{website: value}
  def call(_, "tag", [:"itunes:explicit", _, [value]]), do: %{explicit: Helpers.boolify(value)}
  def call(_, "tag", [:explicit,          _, [value]]), do: %{explicit: Helpers.boolify(value)}
  def call(_, "tag", [:lastBuildDate,     _, [value]]) do
    %{last_build_date: Helpers.to_naive_datetime(value)}
  end
  def call(_, "tag", [:"dc:date", _, [value]]) do
    %{last_build_date: Helpers.to_naive_datetime(value)}
  end
  def call(_, "tag", [:pubDate, _, []]), do: %{}
  def call(_, "tag", [:pubDate, _, [value]]) do
    %{last_build_date: Helpers.to_naive_datetime(value)}
  end


# image with fallback to itunes:image
  def call(map, "tag", [:image, _, value]), do: Iterator.parse(map, "image", value)
  def call(_, "image", [:title, _, _]), do: %{}
  def call(_, "image", [:title, _, [value]]), do: %{image_title: value}
  def call(_, "image", [:url,   _, []]), do: %{}
  def call(_, "image", [:url,   _, [value]]), do: %{image_url: value}
  def call(map, "image", [:link,        _, _]), do: map
  def call(map, "image", [:description, _, _]), do: map
  def call(map, "image", [:width,       _, _]), do: map
  def call(map, "image", [:height,      _, _]), do: map

  def call(map, "image", [:"itunes:image", attr, _]) do
    if map[:image_url], do: map,
                        else: %{image_url: attr[:href],
                                image_title: attr[:href]}
  end

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
  def call(_, "tag", [:generator, _, []]), do: %{}
  def call(_, "tag", [:generator, _, [value]]), do: %{feed: %{feed_generator: value}}


# the links are a mixture of the two above
  def call(_, "tag", [:"atom:link", attr, _]) do
    case attr[:rel] do
      "self"      -> %{feed: %{self_link_title: attr[:title],
                            self_link_url: attr[:href]}}
      "current"   -> %{feed: %{self_link_title: attr[:title],
                            self_link_url: attr[:href]}}
      "next"      -> %{feed: %{next_page_url: attr[:href]}}
      "prev"      -> %{feed: %{prev_page_url: attr[:href]}}
      "prev-archive" -> %{feed: %{prev_page_url: attr[:href]}}
      "previous"  -> %{feed: %{prev_page_url: attr[:href]}}
      "first"     -> %{feed: %{first_page_url: attr[:href]}}
      "last"      -> %{feed: %{last_page_url: attr[:href]}}
      "hub"       -> %{feed: %{hub_link_url: attr[:href]}}
      "search"    -> %{}
      "related"   -> %{}
      "via"       -> %{}
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
  def call(_, "tag", [:"rawvoice:donate", attr, []]), do: %{payment_link_title: attr[:href],
                                                            payment_link_url: attr[:href]}


  def call(_, "tag", [:"atom10:link", attr, _]) do
    case attr[:rel] do
      "self"  -> %{feed: %{self_link_title: attr[:title],
                           self_link_url:   attr[:href]}}
      "hub" -> %{}
    end
  end


# tags to ignore
  def call(map, "tag", [tag_atom, _, _]) when tag_atom in [
    :"feedpress:locale", :"fyyd:verify", :"itunes:block", :"itunes:keywords", :"media:thumbnail",
    :"media:keywords", :"media:category", :category, :site, :docs, :"feedburner:info", :logo,
    :"media:credit", :"media:copyright", :"media:rating", :"media:description", :"copyright",
    :"feedburner:feedFlare", :"geo:lat", :"geo:long", :"creativeCommons:license", :"clipper:id",
    :"feedburner:emailServiceId", :"feedburner:feedburnerHostname", :managingEditor,
    :"sy:updatePeriod", :"sy:updateFrequency", :"wfw:commentRss", :"rawvoice:subscribe",
    :webMaster, :ttl, :"itunes:new-feed-url", :"googleplay:description", :"googleplay:email",
    :"googleplay:category", :"rawvoice:rating", :"rawvoice:location", :"rawvoice:frequency",
    :"ppg:seriesDetails", :"ppg:systemRef", :"ppg:network", :cloud, :"googleplay:image",
    :"googleplay:author", :"googleplay:explicit", :feed, :webmaster, :ilink, :ffmpeg, :domain,
    :lame, :broadcastlimit, :"itunes:link", :"channelExportDir", :"atom:id", :"sy:updateBase",
    :"openSearch:totalResults", :"openSearch:startIndex", :"openSearch:itemsPerPage", :"html",
    :"managingeditor", :"ard:programInformation", :"dc:creator", :"itunes:complete", :feedType,
    :changefreq, :"dc:title", :"feedburner:browserFriendly", :"itunesowner", :textInput,
    :"podcastRF:originStation", :"itunes:explicit", :meta, :"dc:rights", :skipDays, :a, :p, :br, :b,
    :"sc:totalAvailable", :skipHours, :keywords, :script, :"googleplay:block", :guid,
    :"manageEditor", :"itunes:name", :"amp:logo", :"itunes:catago", :"xhtml:meta", :"avms:id",
    :"blogChannel:blogRoll", :"blogChannel:blink", :"thespringbox:skin", :"admin:generatorAgent",
    :"feedpress:podcastId", :summary, :rating, :Category, :"amp:background"
  ], do: map

  def call(_, "episode", [tag_atom, _, _]) when tag_atom in [
    :"googleplay:description", :"googleplay:image", :"googleplay:explicit", :"googleplay:block",
    :"frn:id", :"frn:title", :"frn:language", :"frn:art", :"frn:radio", :"frn:serie", :"frn:laenge",
    :"frn:licence", :"frn:last_update", :"itunes:keywords", :"post-id", :author, :"itunes:explicit",
    :category, :"dc:creator", :comments, :"feedburner:origLink", :"itunes:image", :"dc:modifieddate",
    :"feedburner:origEnclosureLink", :"wfw:commentRss", :"slash:comments", :"itunes:block",
    :"itunes:order", :"ppg:canonical", :"cba:productionDate", :"cba:broadcastDate", :payment,
    :"cba:containsCopyright", :"media:thumbnail", :image, :source, :"media:description", :programid,
    :poddid, :"dcterms:modified", :"dcterms:created", :toPubDate, :audioId, :"atom:updated",
    :"thr:total", :"ard:visibility", :"series:name", :"rawvoice:poster", :"georss:point",
    :"copyright", :"ard:programInformation", :"sc:chapters", :"xhtml:body", :"itunesu:category",
    :"wfw:content", :"wfw:comment", :"creativeCommons:license", :"image_link", :itemDate, :timestamp,
    :"media:keywords", :"media:rights", :"ppg:enclosureLegacy", :"ppg:enclosureSecure",
    :"podcastRF:businessReference", :"podcastRF:magnetothequeID", :"podcastRF:stepID", :explicit,
    :"media:title",:"media:credit", :"dc:subject", :"dc:identifier", :"georss:featurename",
    :"georss:box", :"gd:extendedProperty", :"media:content", :"rawvoice:metamark", :"media:player",
    :"itunes:category", :"fyyd:episodeID", :"fyyd:podcastID", :"fyyd:origPubdate", :"geo:lat",
    :"geo:long", :"rawvoice:isHD", :"podcast:type", :"podcast:description", :"media:rating",
    :"podfm:nodownload", :"podfm:downloadCount", :script, :"rte-days", :"rawvoice:embed",
    :"lastBuildDate", :"merriam:shortdef", :"dc:title", :div, :"rawvoice:webm", :"subTitleLink",
    :"app:edited", :"media:text", :"ecc:description", :guide, :"dc:description", :"itunes:keyword",
    :"media:group", :"rawvoice:donate", :"podcast:title", :"media:copyright", :"dc:type",
    :"itunes:length", :"podcast:name", :"blip:user", :"username", :"dc:copyright", :"pingback:server",
    :"pingback:target", :"trackback:ping", :filename, :"blip:userid", :"blip:safeusername",
    :"blip:showpath", :"blip:show", :"blip:showpage", :"blip:picture", :"blip:posts_id",
    :"blip:item_id", :"blip:item_type", :"blip:rating", :"blip:datestamp", :"blip:language",
    :"blip:adChannel", :"blip:categories", :"blip:license", :"blip:puredescription", :"dc:rights",
    :"blip:thumbnail_src", :"blip:", :"blip:embedUrl", :"blip:embedLookup", :"blip:runtime",
    :"blip:adminRating", :"blip:core_value", :"blip:core", :"blip:recommendable", :"avms:id",
    :"blip:recommendations", :"yv:adInfo", :"blip:smallThumbnail", :"clipper:id"
  ], do: %{}


  def call(_, "image", [tag_atom, _, _]) when tag_atom in [
    :guid
  ], do: %{}


# We expect several language tags
  def call(_, "tag", [:language, _, _]), do: %{}
  def call(_, "tag", [tag_atom, _, [value]]) when tag_atom in [:language, :"dc:language"] do
    uuid = String.to_atom(UUID.uuid1())
    %{languages: %{uuid => %{shortcode: value}}}
  end


# We expect one owner
  def call(map, "tag", [:"itunes:owner",    _, value]), do: Iterator.parse(map, "owner", value)
  def call(map, "tag", [:owner,             _, value]), do: Iterator.parse(map, "owner", value)
  def call(map, "tag", [:"itunes:email",    _, value]), do: Iterator.parse(map, "owner", value)
  def call(_, "owner", [:"itunes:name",     _, []]), do: %{}
  def call(_, "owner", [:"itunes:name",     _, [value]]), do: %{name: String.slice(value, 0, 255)}
  def call(_, "owner", [:name,              _, [value]]), do: %{name: String.slice(value, 0, 255)}
  def call(_, "owner", [:"itunes:email",    _, []]), do: %{}
  def call(_, "owner", [:"itunes:email",    _, [value]]), do: %{email: value}
  def call(_, "owner", [:email,             _, [value]]), do: %{email: value}
# FIXME: HAS20170130 shwould be pulled out of itunes owner
  def call(_, "owner", [:"panoptikum:pid",  _, [value]]), do: %{pid: value}


# Parsing categories infintely deep
  def call(_, "tag", [:"itunes:category", attr, []]) do
    %{categories: %{UUID.uuid1() => %{title: attr[:text], parent: nil}}}
  end
  def call(_, "tag", [:"itunes:category", [], [value]]) do
    %{categories: %{UUID.uuid1() => %{title: value, parent: nil}}}
  end
  def call(_, "tag", [:"itunes:category", attr, value]) do
    Iterator.parse(%{categories: %{UUID.uuid1() => %{title: attr[:text], parent: nil}}}, "category", value, attr[:text])
  end

  def call("category", [:"itunes:category", attr, []], parent_title) do
    %{categories: %{UUID.uuid1() => %{title: attr[:text], parent: parent_title}}}
  end

  def call("category", [:"itunes:category", attr, value], parent_title) do
    Iterator.parse(%{categories: %{UUID.uuid1() => %{title: attr[:text], parent: parent_title}}}, "category", value, attr[:text])
  end


# Episodes
  def call(map, "tag", [:item, _, value]), do: Iterator.parse(map, "episode", value, UUID.uuid1())
  def call(map, "episode", [:item, _, value]), do: Iterator.parse(map, "episode", value, UUID.uuid1())

  def call(_, "episode", [:title, _, []]), do: %{title: "emtpy"}
  def call(_, "episode", [:title, _, [value]]), do: %{title:       String.slice(value, 0, 255)}
  def call(_, "episode", [:"itunes:title", _, []]), do: %{title: "emtpy"}
  def call(_, "episode", [:"itunes:title", _, [value]]), do: %{title:       String.slice(value, 0, 255)}

  def call(_, "episode", [:link, _, []]), do: %{}
  def call(_, "episode", [:link, _, [value]]), do: %{link:        String.slice(value, 0, 255)}
  def call(_, "episode", [:guid, _, [value]]), do: %{guid:        String.slice(value, 0, 255)}
  def call(_, "episode", [:guid, _, _]), do: %{}
  def call(_, "episode", [:contentId, _, [value]]), do: %{guid:   String.slice(value, 0, 255)}

  def call(_, "episode", [:description, _, []]), do: %{}
  def call(_, "episode", [:description, _, [value | _]]), do: %{description: HtmlSanitizeEx2.basic_html_reduced(value)}
  def call(_, "episode", [:"itunes:description", _, []]), do: %{}
  def call(_, "episode", [:"itunes:description", _, [value | _]]), do: %{description: HtmlSanitizeEx2.basic_html_reduced(value)}

  def call(_, "episode", [:"content:encoded", _, []]), do: %{}
  def call(_, "episode", [:"content:encoded", _, [value]]), do: %{shownotes: HtmlSanitizeEx2.basic_html_reduced(value)}
  def call(_, "episode", [:content, _, []]), do: %{}
  def call(_, "episode", [:content, _, [value]]), do: %{shownotes: HtmlSanitizeEx2.basic_html_reduced(value)}
  def call(_, "episode", [:shownotes, _, []]), do: %{}
  def call(_, "episode", [:shownotes, _, [value]]), do: %{shownotes: HtmlSanitizeEx2.basic_html_reduced(value)}

  def call(_, "episode", [:"itunes:summary",  _, []]), do: %{}
  def call(_, "episode", [:"itunes:summary",  _, [value | _]]), do: %{summary: HtmlSanitizeEx2.basic_html_reduced(value)}
  def call(_, "episode", [:summary,           _, [value]]), do: %{summary: HtmlSanitizeEx2.basic_html_reduced(value)}
  def call(_, "episode", [:"atom:summary",  _, []]), do: %{}
  def call(_, "episode", [:"atom:summary",  _, [value | _]]), do: %{summary: HtmlSanitizeEx2.basic_html_reduced(value)}

  def call(_, "episode", [:"itunes:subtitle", _, []]), do: %{}
  def call(_, "episode", [:"itunes:subtitle", _, [value]]), do: %{subtitle: String.slice(value, 0, 255)}
  def call(_, "episode", [:subtitle,          _, [value]]), do: %{subtitle: String.slice(value, 0, 255)}
  def call(_, "episode", [:"itunes:subtitle", _, [value | _]]), do: %{subtitle: String.slice(value, 0, 255)}

  def call(_, "episode", [:"itunes:author", _, []]), do: %{}
  def call(_, "episode", [:"itunes:author", _, [value]]), do: %{author: String.slice(value, 0, 255)}
  def call(_, "episode", [:"googleplay:author", _, [value]]), do: %{author: String.slice(value, 0, 255)}
  def call(_, "episode", [:"dc:publisher", _, [value]]), do: %{author: String.slice(value, 0, 255)}

  def call(_, "episode", [:"itunes:duration", _, []]), do: %{}
  def call(_, "episode", [:"itunes:duration", _, [value]]), do: %{duration: value}
  def call(_, "episode", [:duration, _, []]), do: %{}
  def call(_, "episode", [:duration, _, [value]]), do: %{duration: value}

  def call(_, "episode", [:pubDate,           _, [value]]) do
    %{publishing_date: Helpers.to_naive_datetime(value)}
  end
  def call(_, "episode", [:"dc:date",         _, [value]]) do
    %{publishing_date: Helpers.to_naive_datetime(value)}
  end
  def call(_, "episode", [:pubDateShort,         _, [value]]) do
    %{publishing_date: Helpers.to_naive_datetime(value)}
  end

  def call(_, "episode", [:"atom:link", attr, _]) do
    case attr[:rel] do
      "http://podlove.org/deep-link" ->
        %{deep_link: String.slice(attr[:href], 0, 255)}
      "payment" ->
        %{payment_link_title: attr[:title],
          payment_link_url: String.slice(attr[:href], 0, 255)}
      "alternate" ->
        %{}
    end
  end


# Enclosures a.k.a. Audiofiles
  def call(_, "episode", [:enclosure, attr, _]) do
    enclosure_map = %{url:    String.slice(attr[:url], 0, 255),
                      length: String.slice(attr[:length], 0, 255),
                      type:   String.slice(attr[:type], 0, 255),
                      guid:   String.slice(attr[:"bitlove:guid"], 0, 255)}
    uuid = String.to_atom(UUID.uuid1())
    %{enclosures: %{uuid => enclosure_map}}
  end


# Chapters
  def call(_, "episode", [tag_atom, _, value]) when tag_atom in [:"psc:chapters", :chapters] do
    Iterator.parse(%{}, "chapter", value)
  end


# We expect several contributors
  def call(map, "tag", [:"atom:contributor", _, value]) do
    Iterator.parse(map, "contributor", value, UUID.uuid1())
  end


# Episode contributors
  def call(_, "episode", [:"atom:contributor", _, value]) do
    contributor_uuid = String.to_atom(UUID.uuid1())
    Iterator.parse(%{contributors: %{contributor_uuid => %{}}}, "episode-contributor", value, contributor_uuid)
  end
  def call(_, "episode", [:"dc:contributor", _, [value]]) do
    contributor_uuid = String.to_atom(UUID.uuid1())
    %{contributors: %{contributor_uuid => %{name: value, uri: value}}}
  end


# Show debugging information for unknown tags on console
  def call(_, mode, [tag, attr, value]) do
    Logger.warn "=== Tag unknown: ==="
    Logger.warn "Mode: #{mode}"
    Logger.warn ~s(Tag: :"#{tag}")
    Logger.warn "Attr: #{inspect attr}"
    Logger.warn "Value: #{inspect value}"
    {:error, "tag unknown"}
  end


# Now the namespaces:
  def call("chapter", [tag_atom, attr, _]) when tag_atom in [:"psc:chapter", :chapter] do
    chapter_uuid = String.to_atom(UUID.uuid1())
    %{chapter_uuid => %{start: attr[:start], title: String.slice(attr[:title], 0, 255)}}
  end

  def call("contributor", [:"atom:name",       _, [value]]), do: %{name: value}
  def call("contributor", [:"atom:uri",        _, [value]]), do: %{uri:  value}
  def call("contributor", [:"panoptikum:pid",  _, [value]]), do: %{pid:  value}


  def call("episode-contributor", [:"atom:name",       _, [value]]), do: %{name:  value}
  def call("episode-contributor", [:"atom:uri",        _, [value]]), do: %{uri:   value}
  def call("episode-contributor", [:"atom:email",      _, [value]]), do: %{email: value}
# FIXME: HAS20170130 should be pulled out of itunes owner
  def call("episode-contributor", [:"panoptikum:pid",  _, [value]]), do: %{pid:   value}
end