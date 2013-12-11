module PrismicHelper

  def url_to_doc(doc, ref)
    document_path(id: doc.id, slug: doc.slug, ref: ref)
  end
  def link_to_doc(doc, ref, html_options={}, &blk)
    link_to(url_to_doc(doc, ref), html_options, &blk)
  end

  def display_doc(doc, ref)
    doc.as_html(link_resolver(ref)).html_safe
  end

  def link_resolver(maybe_ref)
    Prismic::LinkResolver.new(maybe_ref) do |doc|
      case doc.link_type
      when "homepage"
        root_path(ref: maybe_ref)
      when "article" # This type is special: the URL is built depending on the document's prismic.io bookmark
        case doc.id
        when api.bookmark("tour")
          tour_path(ref: maybe_ref)
        when api.bookmark("pricing")
          pricing_path(ref: maybe_ref)
        when api.bookmark("about")
          about_path(ref: maybe_ref)
        when api.bookmark("faq")
          faq_path(ref: maybe_ref)
        else
          raise "Article of id #{doc.id} doesn't have a known bookmark"
        end
      when "argument"
        tour_path(ref: maybe_ref) + "#" + doc.id
      when "pricing"
        pricing_path(ref: maybe_ref) + "#" + doc.id
      when "author"
        about_path(ref: maybe_ref) + "#" + doc.id
      when "faq"
        faq_path(ref: maybe_ref) + "#" + doc.id
      when "blog"
        blogpost_path(doc.id, doc.slug, ref: maybe_ref)
      else
        raise "link_resolver doesn't know how to write URLs for #{doc.link_type} type."
      end
    end
  end

  def privileged_access?
    connected? || PrismicService.access_token
  end

  def connected?
    !!@access_token
  end

  def current_ref
    @ref
  end

  def master_ref
    @api.master_ref.ref
  end

  def api
    @api
  end

end
