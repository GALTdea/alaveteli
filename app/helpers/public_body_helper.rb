module PublicBodyHelper

  # Public: The reasons a request can't be made to a PublicBody
  # The returned reasons are ordered by priority. For example, if the body no
  # longer exists there is no reason to ask for its contact details if we don't
  # have an email for it.
  #
  # public_body - Instance of a PublicBody
  #
  # Returns an Array
  def public_body_not_requestable_reasons(public_body)
    reasons = []

    if public_body.defunct?
      reasons.push _('This authority no longer exists, so you cannot make a request to it.')
    end

    if public_body.not_apply?
      reasons.push _('Freedom of Information law does not apply to this authority, so you cannot make a request to it.')
    end

    unless public_body.has_request_email?
      # Make the authority appear requestable to encourage users to help find
      # the authroty's email address
      msg = link_to _("Make a request to this authority"),
                      new_request_to_body_path(:url_name => public_body.url_name),
                      :class => "link_button_green"

      reasons.push(msg)
    end

    reasons.compact
  end

end
